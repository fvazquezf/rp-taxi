import sys

def parse_grid(filename):
    """
    Reads the ASCII grid file and returns the dimensions and content.
    """
    try:
        with open(filename, 'r') as f:
            lines = [line.rstrip('\n') for line in f]
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
        sys.exit(1)

    # Determine dimensions
    rows = len(lines)
    cols = len(lines[0]) if rows > 0 else 0
    
    return rows, cols, lines

def generate_facts(rows, cols, grid):
    """
    Generates ASP facts based on the grid content.
    """
    facts = []
    
    # 1. Domain Dimensions
    facts.append(f"% Grid Dimensions")
    facts.append(f"row(1..{rows}).")
    facts.append(f"col(1..{cols}).")
    facts.append("")

    # 2. Static Elements (Walls and Stations)
    walls = []
    stations = []
    
    # 3. Dynamic Elements (Taxis and Passengers)
    # We use 'init' to wrap their starting positions.
    taxis = []
    passengers = []

    for r, line in enumerate(grid):
        for c, char in enumerate(line):
            # 1-based indexing for ASP
            x, y = r + 1, c + 1
            
            if char == '#':
                walls.append(f"wall({x},{y}).")
            elif char == 'X':
                stations.append(f"station({x},{y}).")
            elif 'a' <= char <= 'z':
                # It's a passenger
                passengers.append(f"passenger({char}).")
                passengers.append(f"init(passenger_at({char},{x},{y})).")
            elif '1' <= char <= '9':
                # It's a taxi
                taxis.append(f"taxi({char}).")
                taxis.append(f"init(at({char},{x},{y})).")
            # '.' is treated as empty space and ignored

    # Append formatted sections
    if walls:
        facts.append("% Walls")
        facts.extend(walls)
        facts.append("")
    
    if stations:
        facts.append("% Stations")
        facts.extend(stations)
        facts.append("")

    if taxis:
        facts.append("% Taxis")
        facts.extend(taxis)
        facts.append("")

    if passengers:
        facts.append("% Passengers")
        facts.extend(passengers)
        facts.append("")

    return "\n".join(facts)

def main():
    # Usage check as described in problem.txt
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
    
    print(f"Successfully encoded '{input_file}' to '{output_file}'.")

if __name__ == "__main__":
    main()