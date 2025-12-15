import sys

def parse_grid(filename):
    """Reads the ASCII grid file and returns dimensions and content."""
    try:
        with open(filename, 'r') as f:
            lines = [line.rstrip('\n') for line in f]
        rows = len(lines)
        cols = len(lines[0]) if rows > 0 else 0
        return rows, cols, lines
    except FileNotFoundError:
        print(f"Error: Input file '{filename}' not found.")
        sys.exit(1)

def generate_facts(rows, cols, grid):
    """Generates ASP facts based on the grid content."""
    facts = []
    
    facts.append("#program always.") 
    facts.append(f"row(1..{rows}). col(1..{cols}).")
    
    walls, stations, taxis, passengers = [], [], [], []
    
    for r, line in enumerate(grid):
        for c, char in enumerate(line):
            x, y = r + 1, c + 1
            if char == '#':
                walls.append(f"wall({x},{y}).")
            elif char == 'X':
                stations.append(f"station({x},{y}).")
            elif 'a' <= char <= 'z':
                passengers.append(f"passenger({char}).")
                passengers.append(f"init(passenger_at({char},{x},{y})).")
            elif '1' <= char <= '9':
                taxis.append(f"taxi({char}).")
                taxis.append(f"init(at({char},{x},{y})).")

    if walls: facts.append("\n% Walls\n" + "\n".join(walls))
    if stations: facts.append("\n% Stations\n" + "\n".join(stations))
    if taxis: facts.append("\n% Taxis\n" + "\n".join(taxis))
    if passengers: facts.append("\n% Passengers\n" + "\n".join(passengers))
    
    return "\n".join(facts)

def main():
    if len(sys.argv) != 3:
        print("Usage: python3 encode.py <input_file> <output_file>")
        print("Example: python3 encode.py dom01.txt domain.lp")
        return

    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    rows, cols, grid = parse_grid(input_file)
    asp_code = generate_facts(rows, cols, grid)
    
    with open(output_file, 'w') as f:
        f.write(asp_code)

if __name__ == "__main__":
    main()