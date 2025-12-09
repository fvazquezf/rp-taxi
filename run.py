import sys
import subprocess
import os

# ==========================================
# CONFIGURATION
# ==========================================
# Paths to your scripts
ENCODER_SCRIPT = "encode.py"
SOLVER_SCRIPT = "taxi.lp"
VISUALIZER_SCRIPT = "drawtaxi.py"

# Directories
INPUT_DIR = "extaxi"
OUTPUT_DIR = "results"

def ensure_paths():
    """Checks if necessary files and directories exist."""
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)
    
    required_files = [ENCODER_SCRIPT, SOLVER_SCRIPT, VISUALIZER_SCRIPT]
    for f in required_files:
        if not os.path.exists(f):
            print(f"Error: Required script '{f}' not found in the current directory.")
            sys.exit(1)

# ==========================================
# STEP 1: ENCODING
# ==========================================
def run_encoder(input_path, domain_lp_path):
    print(f"[1/3] Encoding '{input_path}'...")
    
    # Calls: python3 encode.py <input> <output>
    cmd = [sys.executable, ENCODER_SCRIPT, input_path, domain_lp_path]
    
    try:
        subprocess.run(cmd, check=True)
        print(f"      Generated '{domain_lp_path}'")
    except subprocess.CalledProcessError as e:
        print(f"Error running encoder: {e}")
        sys.exit(1)

# ==========================================
# STEP 2: SOLVING
# ==========================================
def run_solver(taxi_lp, domain_lp, solution_path):
    print(f"[2/3] Solving with Telingo...")
    
    # Calls: telingo taxi.lp domain_XX.lp
    # Note: We do not add extra formatting options so that drawtaxi.py can read the "State X:" lines.
    cmd = ["telingo", taxi_lp, domain_lp]
    
    try:
        with open(solution_path, "w") as outfile:
            # check=True will raise an error for exit codes != 0. 
            # We catch this below because Telingo returns 10/20/30 on success.
            subprocess.run(cmd, stdout=outfile, stderr=subprocess.PIPE, check=True)
        print(f"      Solution saved to '{solution_path}'")
        
    except subprocess.CalledProcessError as e:
        # Telingo/Clingo exit codes: 10 (SAT), 20 (UNSAT), 30 (UNKNOWN)
        if e.returncode in [10, 20, 30]: 
            print(f"      Solver finished (Exit code {e.returncode}). Output saved.")
        else:
            print(f"Error running Telingo: {e.stderr.decode()}")
            sys.exit(1)
    except FileNotFoundError:
        print("Error: 'telingo' executable not found. Please install it or check your PATH.")
        sys.exit(1)

# ==========================================
# STEP 3: VISUALIZATION
# ==========================================
def run_visualizer(domain_txt, solution_txt):
    print(f"[3/3] Visualizing solution...")
    
    # Calls: python3 drawtaxi.py <domain_txt> <solution_txt>
    cmd = [sys.executable, VISUALIZER_SCRIPT, domain_txt, solution_txt]
    
    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running visualizer: {e}")

# ==========================================
# MAIN
# ==========================================
def main():
    if len(sys.argv) != 2:
        print("Usage: python3 run.py <instance_number>")
        print("Example: python3 run.py 01")
        sys.exit(1)

    instance_id = sys.argv[1]
    
    # Define file names
    input_domain_txt = os.path.join(INPUT_DIR, f"dom{instance_id}.txt")
    output_domain_lp = os.path.join(OUTPUT_DIR, f"domain_{instance_id}.lp")
    output_solution_txt = os.path.join(OUTPUT_DIR, f"solution_{instance_id}.txt")

    # validation
    ensure_paths()
    if not os.path.exists(input_domain_txt):
        print(f"Error: Input file '{input_domain_txt}' does not exist.")
        sys.exit(1)

    # Execute Pipeline
    run_encoder(input_domain_txt, output_domain_lp)
    run_solver(SOLVER_SCRIPT, output_domain_lp, output_solution_txt)
    run_visualizer(input_domain_txt, output_solution_txt)

if __name__ == "__main__":
    main()