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
