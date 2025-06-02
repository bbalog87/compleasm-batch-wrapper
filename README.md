# Overview

This script automates running [Compleasm](https://github.com/huangnengCSU/compleasm) on multiple genome assemblies (FASTA format) to assess genome completeness using BUSCO lineages. 
It supports manual lineage selection and auto-detection (via SEPP). It also generates a single summary table with results for all input genomes.

## Installation
1️⃣ Install Compleasm (via Conda/Mamba)

To install Compleasm with `mamba`, run:

```bash
mamba create -n compleasm_env -c conda-forge -c bioconda compleasm
conda activate compleasm_env
```

2️⃣ Install SEPP (for --autolineage support)
```bash
mamba install -c bioconda sepp
```
## Lineage Detection Modes

Compleasm supports two modes for selecting a lineage:
| Mode           | How to Use      | Requirements                                     | Notes                                         |
| -------------- | --------------- | ------------------------------------------------ | --------------------------------------------- |
| Manual         | `-l <lineage>`  | None beyond Compleasm                            | E.g., `-l enterobacterales`<br>                   |
| Auto-detection | `--autolineage` | Requires SEPP <br> (`mamba install -c bioconda sepp`) | Automatically finds the best-matching lineage |

## Usage

```b./run_compleasm.sh -i <input_directory> [-l <lineage> | --autolineage] [-o <output_directory>] [-t <threads>]```

## Arguments
| Argument          | Type    | Required      | Description                                                          |
| ----------------- | ------- | ------------- | -------------------------------------------------------------------- |
| `-i`, `--input`   | Path    | Yes           | Directory containing genome assemblies in `.fasta`, `.fna` or `.fa` format.  |
| `-l`, `--lineage` | String  | Conditional\* | BUSCO lineage name (e.g., `enterobacterales`, `bacteria`, etc.).     |
| `--autolineage`   | Flag    | Conditional\* | Let Compleasm auto-select the best-matching lineage (SEPP required). |
| `-o`, `--output`  | Path    | No            | Output directory for Compleasm results (default: `compleasm_out`).   |
| `-t`, `--threads` | Integer | No            | Number of CPU threads (default: `8`).                                |
| `-h`, `--help`    | Flag    | No            | Show help message and exit.                                          |


* You **must** specify either  `-l` **or**  `--autolineage` (not both).
  
## Example Commands
Run Compleasm with **manual lineage:**
```bash
./run_compleasm.sh -i ./assemblies -l enterobacterales -o klebsiella_results -t 16
```
Run Compleasm with **auto-detection** (SEPP required):
```bash
./run_compleasm.sh -i ./assemblies --autolineage -o results -t 16
```
## Output

For each input genome:
- Compleasm outputs results in a subdirectory within the output folder.
-  Example:
```
klebsiella_results/
├── genome1/
│   ├── summary.txt
├── genome2/
│   ├── summary.txt
```
