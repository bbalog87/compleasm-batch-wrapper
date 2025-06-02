# Overview

This script automates running [Compleasm](https://github.com/huangnengCSU/compleasm) on multiple genome assemblies (FASTA format) to assess genome completeness using BUSCO lineages. 
It supports manual lineage selection and auto-detection (via SEPP). It also generates a single summary table with results for all input genomes.


## About Compleasm

Compleasm is a tool designed to assess the completeness of genome assemblies based BUSCO lineages. Developed by [Neng Huang and [Heng Li](https://doi.org/10.1093/bioinformatics/btad595) the Department of Data Sciences at Dana-Farber Cancer Institute and the Department of Biomedical Informatics at Harvard Medical School, Compleasm offers a faster and more accurate alternative to traditional methods like BUSCO.

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

```./run_compleasm.sh -i <input_directory> [-l <lineage> | --autolineage] [-o <output_directory>] [-t <threads>]```

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
A **single summary file** is generated: <br>
✅ compleasm_summary.tsv in the output directory <br>
✅ Contains one header and one row per genome <br>
✅ The first column is the basename of the genome FASTA file:


```
Sample	Complete (%)	Single-Copy (%)	Duplicated (%)	Fragmented (%)	Missing (%)	Total BUSCOs
genome1	98.2	97.0	1.2	1.0	0.8	440
genome2	95.5	93.8	1.7	2.5	2.0	440

```

## ⚠️ Note on Lineage Autodetection

While Compleasm supports automatic lineage detection using the  ``` --autolineage ``` option (requires SEPP), this feature **may not always select the most appropriate lineage for your specific genomes**.<br>

For best results, it is **recommended to manually specify the lineage** using the  ``` -l <lineage>``` option. <br>
For example, for *Salmonella* or *Klebsiella* genomes, use:

```
-l enterobacterales
```
You can list available BUSCO lineages by running: <br>

```
compleasm list

```

## Compleasm Command Reference

For advanced options, here’s the ```compleasm run --help output```

```
usage: compleasm run [-h] -a ASSEMBLY_PATH -o OUTPUT_DIR [-t THREADS]
                     [-l LINEAGE] [-L LIBRARY_PATH] [--odb ODB]
                     [--specified_contigs SPECIFIED_CONTIGS [SPECIFIED_CONTIGS ...]]
                     [--outs OUTS]
                     [--miniprot_execute_path MINIPROT_EXECUTE_PATH]
                     [--hmmsearch_execute_path HMMSEARCH_EXECUTE_PATH]
                     [--autolineage] [--retrocopy]
                     [--sepp_execute_path SEPP_EXECUTE_PATH]
                     [--min_diff MIN_DIFF] [--min_identity MIN_IDENTITY]
                     [--min_length_percent MIN_LENGTH_PERCENT]
                     [--min_complete MIN_COMPLETE] [--min_rise MIN_RISE]

optional arguments:
  -h, --help            Show this help message and exit.
  -a ASSEMBLY_PATH      Input genome file in FASTA format.
  -o OUTPUT_DIR         The output folder.
  -t THREADS            Number of threads to use.
  -l LINEAGE            Specify the name of the BUSCO lineage to be used.
                        (e.g. eukaryota, primates, saccharomycetes etc.)
  -L LIBRARY_PATH       Folder path to download lineages or already downloaded
                        lineages. If not specified, a folder named
                        "mb_downloads" will be created on the current running
                        path by default to store the downloaded lineage files.
  --odb ODB             OrthoDB version, default: odb12.
  --specified_contigs   Specify the contigs to be evaluated, e.g. chr1 chr2.
  --outs OUTS           Output if score at least FLOAT*bestScore [0.99].
  --miniprot_execute_path Path to miniprot executable.
  --hmmsearch_execute_path Path to hmmsearch executable.
  --autolineage         Automatically search for the best matching lineage.
  --retrocopy           Separate retrocopy genes from duplicated genes.
  --sepp_execute_path   Path to run_sepp.py executable.
  --min_diff MIN_DIFF   Threshold for best vs second-best matching.
  --min_identity MIN_IDENTITY The identity threshold for valid mapping results.
  --min_length_percent  The fraction of protein for valid mapping results.
  --min_complete MIN_COMPLETE The length threshold for complete gene.
  --min_rise MIN_RISE   Minimum length threshold for duplication vs single/frag.
```


## Reference
- Huang, N., & Li, H. (2023). Compleasm: a faster and more accurate reimplementation of BUSCO. Bioinformatics, 39(10), btad595. https://doi.org/10.1093/bioinformatics/btad595
