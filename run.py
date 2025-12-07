import sys
import subprocess
import os

# ==========================================
# PART 1: Domain Encoding Logic
# ==========================================

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

def create_domain_lp(input_file, output_file):
    print(f"[1/3] Encoding '{input_file}' into '{output_file}'...")
    
    rows, cols, grid = parse_grid(input_file)
    asp_code = generate_facts(rows, cols, grid)
    
    with open(output_file, 'w') as f:
        f.write(asp_code)
    print("      Encoding complete.")

# ==========================================
# PART 2: Solver Execution
# ==========================================

def run_solver(taxi_lp, domain_lp, solution_file):
    print(f"[2/3] Running Telingo on '{taxi_lp}' and '{domain_lp}'...")
    
    # Command: telingo taxi.lp results/domain_XX.lp
    command = ["telingo", taxi_lp, domain_lp]
    
    try:
        with open(solution_file, "w") as outfile:
            subprocess.run(command, stdout=outfile, stderr=subprocess.PIPE, check=True)
        print(f"      Solution saved to '{solution_file}'.")
    except subprocess.CalledProcessError as e:
        # Exit codes 10 (SAT), 20 (UNSAT), 30 (UNKNOWN) are valid for solvers
        if e.returncode in [10, 20, 30]: 
            print(f"      Solver finished (Exit code {e.returncode}). Output saved.")
        else:
            print(f"Error running Telingo: {e.stderr.decode()}")
            sys.exit(1)
    except FileNotFoundError:
        print("Error: 'telingo' executable not found. Please install it or check your PATH.")
        sys.exit(1)

# ==========================================
# PART 3: Visualization
# ==========================================

def run_visualization(draw_script, domain_txt, solution_file):
    print(f"[3/3] Launching visualization...")
    print(f"      Input: {domain_txt}")
    print(f"      Plan:  {solution_file}")
    
    # Command: python3 drawtaxi.py extaxi/domXX.txt results/solution_XX.txt
    command = [sys.executable, draw_script, domain_txt, solution_file]
    
    try:
        subprocess.run(command, check=True)
    except Exception as e:
        print(f"Error running visualization: {e}")

# ==========================================
# MAIN EXECUTION
# ==========================================

def main():
    if len(sys.argv) != 2:
        print("Usage: python run_taxi.py <number>")
        print("Example: python run_taxi.py 01")
        return

    # Configuration
    instance_num = sys.argv[1]
    input_dir = "extaxi"
    output_dir = "results"
    
    # Ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)
    
    # Construct File Paths
    # Input: extaxi/dom01.txt
    input_domain_txt = os.path.join(input_dir, f"dom{instance_num}.txt")
    
    # Output: results/domain_01.lp
    generated_lp = os.path.join(output_dir, f"domain_{instance_num}.lp")
    
    # Output: results/solution_01.txt
    solution_file = os.path.join(output_dir, f"solution_{instance_num}.txt")
    
    # Static files (assumed to be in the current root directory)
    taxi_encoding = "taxi.lp"
    draw_script = "drawtaxi.py"

    # Step 1: Generate domain_XX.lp from extaxi/domXX.txt
    create_domain_lp(input_domain_txt, generated_lp)

    # Step 2: Run Telingo using the specific numbered files
    run_solver(taxi_encoding, generated_lp, solution_file)

    # Step 3: Draw Result using the paths to the extaxi and results folders
    run_visualization(draw_script, input_domain_txt, solution_file)

if __name__ == "__main__":
    main()