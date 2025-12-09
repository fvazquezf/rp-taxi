import os
import re
import glob

# Configuration
REF_DIR = "extaxi"           # Directory with solXX.txt
GEN_DIR = "results"          # Directory with solution_XX.txt

def parse_solution(filepath):
    """
    Parses a solution file to extract metrics.
    Returns: (max_state, total_actions, status)
    """
    try:
        with open(filepath, 'r') as f:
            content = f.read()
    except FileNotFoundError:
        return 0, 0, "MISSING"

    # Check for UNSAT or errors
    if "UNSATISFIABLE" in content:
        return 0, 0, "UNSAT"
    
    # Extract the maximum State number (Plan Length)
    # Looks for "State <number>:"
    states = re.findall(r'State\s+(\d+):', content)
    if not states:
        return 0, 0, "NO_PLAN"
    
    max_state = max(map(int, states))
    
    # Count total actions (move, pick, drop, wait)
    # We exclude the 'State X:' lines and counts occurrences of action predicates
    actions = re.findall(r'(move|pick|drop|wait)\(', content)
    total_actions = len(actions)
    
    return max_state, total_actions, "OK"

def main():
    print(f"{'Instance':<10} | {'Metric':<10} | {'Reference':<10} | {'Yours':<10} | {'Diff':<10}")
    print("-" * 60)

    # Find all reference files like sol01.txt, sol10.txt
    ref_files = sorted(glob.glob(os.path.join(REF_DIR, "sol*.txt")))
    
    for ref_path in ref_files:
        # Extract number (e.g., "01" from "sol01.txt")
        basename = os.path.basename(ref_path)
        match = re.search(r'sol(\d+)\.txt', basename)
        if not match: continue
        
        num = match.group(1)
        
        # Construct path to corresponding generated file
        # Expected format: results/solution_01.txt
        gen_path = os.path.join(GEN_DIR, f"solution_{num}.txt")
        
        # Parse both
        ref_len, ref_acts, ref_status = parse_solution(ref_path)
        gen_len, gen_acts, gen_status = parse_solution(gen_path)
        
        # --- Compare Length (Time Steps) ---
        len_diff = gen_len - ref_len
        len_mark = " (MATCH)" if len_diff == 0 else f" ({len_diff:+d})"
        if gen_status != "OK": len_mark = f" ({gen_status})"
        
        print(f"dom{num:<7} | {'Length':<10} | {ref_len:<10} | {gen_len:<10} | {len_mark:<10}")
        
        # --- Compare Total Actions (Cost) ---
        act_diff = gen_acts - ref_acts
        act_mark = " (MATCH)" if act_diff == 0 else f" ({act_diff:+d})"
        if gen_status != "OK": act_mark = ""

        print(f"{'':<10} | {'Actions':<10} | {ref_acts:<10} | {gen_acts:<10} | {act_mark:<10}")
        print("-" * 60)

if __name__ == "__main__":
    main()