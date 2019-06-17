# Snakemake Tutorial

2019-06-25

## Recreating the Makefile in Snakemake

### Writing rules

- Rule name
- Directives:
    - Input
    - Output
    - Shell, Script, or Run
    - Params
- Snakemake helper functions:
    - expand
    - temp
    - protected
    - directory
    - glob_wildcards

### Snakemake in R

Access anything from R or Python scripts via the `snakemake` object.

`concatenate_files.R`
```
if (exists("snakemake")) {
    name_files <- snakemake@input[["data"]]
	output_file <- snakemake@output[[1]]
    use_all_data <- as.logical(snakemake@params[["use_all_data"]])
} else {
    name_files <- list.files(path='data/raw', pattern="yob.*.txt", full.names=TRUE)
	output_file <- "data/processed/all_names.csv"
    use_all_data <- FALSE
}
```

### Command line options

```
-n --dryrun
-j --cores
-s
```

### Visualize the workflow

```
snakemake --dag | dot -Tsvg > dag.svg
open dag.svg
```

## Decorating the Snakefile

### Config

```
snakemake --configfile config/config_alldata.yaml
```

```
snakemake --config start_year=1950
```

### Target rule

Avoids specifying the target file(s) on the command line.

### Temporary files

Snakemake deletes the file after any running rules that depend on it.

### Directory as output

Normally snakemake expects all input & output to be files, not directories.
But sometimes you may want to specify a directory as output (such as for our checkpoint rule).

### Checkpoints

Special rules that force snakemake to re-evaluate the DAG.
Use a checkpoint when you don't know exactly how many output files a rule will produce.

### Wildcards

Use the `glob_wildcards` function to create wildcards from files that exist. Glob is greedy and will try to match anything it can, even across different directories.

### Rule dependencies

Refer to input or output files of other rules to avoid copy-pasting file paths.

### Benchmark

Snakemake will record the wall time, memory usage, etc. as a tab-delimited text file.

### Protected files

Snakemake throws an error if you try to overwrite a protected file.
You can only delete a protected file with `rm -f`.

## Running on Flux
