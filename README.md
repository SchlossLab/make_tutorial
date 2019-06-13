# Snakemake Tutorial for Make Users

This repository was forked from a tutorial on how to use [GNU Make](https://www.gnu.org/software/make/). It provides a parallel implementation in [Snakemake](https://snakemake.readthedocs.io/en/stable/index.html), a Python-based workflow management system.

The [tutorial](http://www.riffomonas.org/tutorials/make/#1) is part of [Pat](https://github.com/pschloss)'s Reproducible Research in Microbial Informatics series. If you aren't interested in the motivation from a microbiology perspective, you can skip ahead to around [slide 15](http://www.riffomonas.org/tutorials/make/#22). The tutorial focuses on replicating an analysis performed by FiveThirtyEight to [predict someone's age using their name](http://fivethirtyeight.com/features/how-to-tell-someones-age-when-all-you-know-is-her-name/).

## Datasets

The analysis draws names from two sources within the Social Security Administration:
* [Life tables](http://www.ssa.gov/oact/NOTES/as120/LifeTables_Tbl_7.html)
* [Name frequency](https://www.ssa.gov/oact/babynames/limits.html)

## Dependencies

All dependencies are listed in [`env.yaml`](env.yaml). You can install them manually using your preferred package manager(s), or use [`conda`](https://docs.conda.io/projects/conda/en/latest/index.html).

### Conda

If you don't already have `conda` installed, you can [download either Anaconda or Miniconda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/download.html) -- your preference. Anaconda3 includes everything, while Miniconda3 is faster to install. Be sure to pick the Python 3 version of the installer for your OS.

Download & install for 64-bit macOS:
```
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
bash Miniconda3-latest-MacOSX-x86_64.sh
```

Create an environment called `predict-age` with the dependencies we need:
```
conda env create -f env.yaml
```
Or give the environment whatever name you want using the flag `--name` or `-n`.

Activate the environment before running any code:
```
conda activate predict-age
```

See the [`conda` documentation](https://docs.conda.io/projects/conda/en/latest/user-guide/index.html) for more information.
