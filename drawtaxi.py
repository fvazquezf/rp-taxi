import pygame
import sys

# Configuration
cellsize = 65
walls = []
taxis = {}
person_at = []
taxi_at = []
free = {}
goals = []
domain = []
delay = 200 # This is now fallback or initial delay
inc = {'u': (-1, 0), 'd': (1, 0), 'l': (0, -1), 'r': (0, 1)}
font = 0

def drawcell(p, s):
    img = pygame.image.load("picstaxi/" + s + ".png").convert()
    screen.blit(img, (p[1] * cellsize, p[0] * cellsize))

def drawgrid(screen, n, m):
    screen.fill(pygame.Color('white'))
    for w in walls: drawcell(w, "building")
    for i in range(n):
        for j in range(m):
            if taxi_at[i][j] != ' ':
                if person_at[i][j] == ' ': drawcell((i, j), "free-taxi")
                elif free[taxi_at[i][j]]: drawcell((i, j), "taxi-person")
                else: drawcell((i, j), "occup-taxi")
                text_surface = font.render(str(taxi_at[i][j]), True, pygame.Color("black"))
                screen.blit(text_surface, dest=(j * cellsize + 55, i * cellsize + 2))
            elif person_at[i][j] != ' ': drawcell((i, j), "person")
            if person_at[i][j] != ' ':
                k = 14
                if taxi_at[i][j] != ' ' and not free[taxi_at[i][j]]: k = 36
                text_surface = font.render(person_at[i][j], True, pygame.Color("black"))
                screen.blit(text_surface, dest=(j * cellsize + k, i * cellsize + 2))
    for g in goals:
        pygame.draw.rect(screen, pygame.Color("yellow"), [g[1] * cellsize, g[0] * cellsize + 50, 65, 15], 0)
        font2 = pygame.font.Font(pygame.font.get_default_font(), 14)
        text_surface = font2.render("STATION", True, pygame.Color("black"))
        screen.blit(text_surface, dest=(g[1] * cellsize + 2, g[0] * cellsize + 51))
    for i in range(n):
        pygame.draw.line(screen, pygame.Color("gray"), (0, i * cellsize), (m * cellsize, i * cellsize), 1)
    for i in range(m):
        pygame.draw.line(screen, pygame.Color("gray"), (i * cellsize, 0), (i * cellsize, n * cellsize), 1)
    pygame.display.flip()

def move(t, d):
    i, j = taxis[t][0], taxis[t][1]
    taxi_at[i][j] = ' '
    if not free[t]: person_at[i][j] = ' '
    ni, nj = i + inc[d][0], j + inc[d][1]
    taxis[t][0], taxis[t][1] = ni, nj

def pick(t):
    free[t] = False; taxis[t][2] = person_at[taxis[t][0]][taxis[t][1]]

def drop(t):
    free[t] = True; taxis[t][2] = ' '

def wait_for_user():
    """Waits for Spacebar to continue or Q to quit."""
    print("Press SPACE for next step, or Q to quit...")
    while True:
        event = pygame.event.wait()
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_SPACE:
                return
            if event.key == pygame.K_q:
                pygame.quit()
                sys.exit()

def execute(actions):
    for a in actions:
        if len(a) < 5 or '(' not in a: continue
        act_type = a[0]
        try:
            params = a[a.find("(") + 1: a.find(")")]
            parts = params.split(',')
            taxi_id = parts[0]
            if act_type == 'm': # move
                direction = parts[1]
                move(taxi_id, direction)
            elif act_type == 'p': # pick
                pick(taxi_id)
            elif act_type == 'd': # drop
                drop(taxi_id)
        except Exception as e:
            print(f"Skipping malformed action '{a}': {e}")
            continue

    for t in taxis:
        taxi_at[taxis[t][0]][taxis[t][1]] = t
        if not free[t]: person_at[taxis[t][0]][taxis[t][1]] = taxis[t][2]
    
    drawgrid(screen, n, m)
    # Replaced automatic delay with manual wait
    wait_for_user() 

### Main program ####################
if len(sys.argv) != 3 and len(sys.argv) != 4:
    print("python drawtaxi.py <domainfile.txt> <solutionfile.txt> <delayMilisecs>")
    exit(0)
if len(sys.argv) == 4:
    delay = int(sys.argv[3])

try:
    with open(sys.argv[1], "r") as f: domain = f.readlines()
    with open(sys.argv[2], "r") as f: solution = f.readlines()
except FileNotFoundError as e:
    print(f"Error opening files: {e}")
    exit(1)

n = len(domain)
for i in range(n):
    domain[i] = list(domain[i][:-1])
m = len(domain[0])
person_at = [[' ' for i in range(m)] for j in range(n)]
taxi_at = [[' ' for i in range(m)] for j in range(n)]

# Visualization
pygame.init()
screen = pygame.display.set_mode([cellsize * m, cellsize * n])
screen.fill(pygame.Color("white"))
pygame.display.set_caption("Taxi routing (Press SPACE to Step)")
font = pygame.font.Font(pygame.font.get_default_font(), 16)

for i in range(n):
    for j in range(m):
        if domain[i][j] == '#': walls.append((i, j))
        elif domain[i][j] >= 'a' and domain[i][j] <= 'z': person_at[i][j] = domain[i][j]
        elif domain[i][j] >= '0' and domain[i][j] <= '9':
            taxis[domain[i][j]] = [i, j, ' ']; free[domain[i][j]] = True; taxi_at[i][j] = domain[i][j]
        if domain[i][j] == 'X': goals.append((i, j))

drawgrid(screen, n, m)

# Wait before starting the first step
print("Initial state loaded.")
wait_for_user()

plan = []
step = []
i = 0

# Skip to the first 'State' line
while i < len(solution):
    words = solution[i].split()
    if words and words[0] == 'State':
        break
    i += 1

## Processing the solution file
for l in solution[i:]:
    words = l.split()
    if not words: continue 
    
    if words[0] == 'State': 
        if step: plan.append(step); step = []
    else: 
        step = step + words

if step: plan.append(step)

for step in plan:
    execute(step)

# Keep window open at the end
print("Simulation finished. Press Q to quit.")
wait_for_user() 
pygame.quit()