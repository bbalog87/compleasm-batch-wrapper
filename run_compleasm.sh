#!/bin/bash

# === Compleasm Batch Runner Script ===
#  This script runs Compleasm on multiple genome FASTA files and generates a summary TSV.
#
# Usage:
#   ./run_compleasm.sh -i <input_directory> [-l <lineage> | --autolineage] [-o <output_directory>] [-t <threads>]
#
# Required arguments:
#   -i, --input         Path to folder containing genome assemblies in FASTA format
#
# You must provide one of:
#   -l, --lineage       BUSCO lineage name (e.g., enterobacterales, bacteria, etc.)
#   --autolineage       Let Compleasm automatically select the best lineage (requires SEPP)
#
# Optional arguments:
#   -o, --output        Output directory for Compleasm results [default: compleasm_out]
#   -t, --threads       Number of CPU threads [default: 8]
#   --clean             After summary generation, delete all per-sample folders (keeps master summary & lineages)
#   -h, --help          Show this help message and exit
#
# Example:
#   ./run_compleasm.sh -i ./assemblies -l enterobacterales -o klebsiella_results -t 16
#   ./run_compleasm.sh -i ./assemblies --autolineage -o results -t 16
#

# === Default values ===
INPUT_DIR=""
LINEAGE=""
AUTOLINEAGE=false
OUTPUT_DIR="compleasm_out"
N_THREADS=8
CLEAN=false

# === Parse arguments ===
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--input) INPUT_DIR="$(realpath "$2")"; shift ;;
        -l|--lineage) LINEAGE="$2"; shift ;;
        --autolineage) AUTOLINEAGE=true ;;
        -o|--output) OUTPUT_DIR="$(realpath "$2")"; shift ;;
        -t|--threads) N_THREADS="$2"; shift ;;
        -h|--help)
            grep '^#' "$0" | cut -c 4-
            exit 0
            ;;
        *)
            echo "[ERROR] Unknown parameter: $1"
            grep '^#' "$0" | cut -c 4-
            exit 1
            ;;
    esac
    shift
done

# === Validate required arguments ===
if [ -z "$INPUT_DIR" ] || [ ! -d "$INPUT_DIR" ]; then
    echo "[ERROR] Input directory (-i/--input) is required and must exist."
    grep '^#' "$0" | cut -c 4-
    exit 1
fi

if [ -z "$LINEAGE" ] && [ "$AUTOLINEAGE" = false ]; then
    echo "[ERROR] You must provide either --lineage <name> or --autolineage."
    grep '^#' "$0" | cut -c 4-
    exit 1
fi

if [ -n "$LINEAGE" ] && [ "$AUTOLINEAGE" = true ]; then
    echo "[ERROR] Provide either --lineage or --autolineage, not both."
    grep '^#' "$0" | cut -c 4-
    exit 1
fi

# === Create output and lineage directories ===
mkdir -p "$OUTPUT_DIR"
LINEAGE_DIR="$OUTPUT_DIR/lineages"
mkdir -p "$LINEAGE_DIR"

# === Download lineage if using manual lineage ===
if [ -n "$LINEAGE" ] && [ ! -d "$LINEAGE_DIR/$LINEAGE" ]; then
    echo "[INFO] Downloading BUSCO lineage: $LINEAGE"
    compleasm download "$LINEAGE" -L "$LINEAGE_DIR"
fi

# === Run Compleasm on each genome ===
for genome in "$INPUT_DIR"/*.fasta "$INPUT_DIR"/*.fa "$INPUT_DIR"/*.fna; do
    [ -e "$genome" ] || continue  # Skip if no files found
    basename=$(basename "$genome" | sed 's/\.[^.]*$//')
    echo "[INFO] Processing $basename"

    if [ "$AUTOLINEAGE" = true ]; then
        compleasm run -a "$genome" \
                      -o "$OUTPUT_DIR/$basename" \
                      --autolineage \
                      --sepp_execute_path $(which run_sepp.py) \
                      -t $N_THREADS
    else
        compleasm run -a "$genome" \
                      -o "$OUTPUT_DIR/$basename" \
                      -l "$LINEAGE" \
                      -L "$LINEAGE_DIR" \
                      -t $N_THREADS
    fi
done

echo "[INFO] Compleasm analyses completed."

# === Generate single summary file for all samples ===
SUMMARY_TSV="$OUTPUT_DIR/compleasm_summary.tsv"
echo -e "Sample\tComplete (%)\tSingle-Copy (%)\tDuplicated (%)\tFragmented (%)\tMissing (%)\tTotal BUSCOs" > "$SUMMARY_TSV"

for summary in "$OUTPUT_DIR"/*/summary.txt; do
    [ -f "$summary" ] || continue
    sample=$(basename "$(dirname "$summary")")
    complete=$(grep -Po '(?<=C:)[0-9.]+' "$summary")
    single=$(grep -Po '(?<=S:)[0-9.]+' "$summary")
    duplicated=$(grep -Po '(?<=D:)[0-9.]+' "$summary")
    fragmented=$(grep -Po '(?<=F:)[0-9.]+' "$summary")
    missing=$(grep -Po '(?<=M:)[0-9.]+' "$summary")
    total=$(grep -Po '(?<=N:)[0-9]+' "$summary")
    echo -e "$sample\t$complete\t$single\t$duplicated\t$fragmented\t$missing\t$total" >> "$SUMMARY_TSV"
done


# === Cleanup per-sample folders if requested ===
if [ "$CLEAN" = true ]; then
    echo "[INFO] Cleaning up per-sample folders (excluding lineages)..."
    find "$OUTPUT_DIR"/* -maxdepth 0 -type d ! -name lineages -exec rm -r {} +
    echo "[INFO] Cleanup complete."
fi

echo "[INFO] Final Compleasm summary created: $SUMMARY_TSV"
