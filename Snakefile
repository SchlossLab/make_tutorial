configfile: "config/config_default.yaml"

start = config['start']
end = config['end']
use_all_data = config['use_all_data']

rule render_report:
    input:
        csv=f"data/processed/total_and_living_name_counts_alldata-{use_all_data}.csv",
        rmd='family_report.Rmd',
        plotr="code/plot_functions.R"
    output:
        f'family_report_alldata-{use_all_data}.html'
    benchmark:
        f'results/benchmarks/render_report_alldata-{use_all_data}.tsv'
    shell:
        """
        R -e "library(rmarkdown); render('{input.rmd}', output_file='{output}', params = list(csv_file='{input.csv}', plot_code='{input.plotr}'))"
        """

rule download:
    output:
        temp("data/raw/names.zip")
    benchmark:
        'results/benchmarks/download.tsv'
    shell:
        "curl -Lo data/raw/names.zip https://www.ssa.gov/oact/babynames/names.zip"

rule unzip:
    input:
        "data/raw/names.zip"
    output:
        expand("data/raw/yob{year}.txt", year=range(start, end+1))
    benchmark:
        'results/benchmarks/unzip.tsv'
    shell:
        "unzip -u -d data/raw/ data/raw/names.zip"

rule concatenate_files:
    input:
        data=expand("data/raw/yob{year}.txt", year=range(start, end+1)),
        R="code/concatenate_files.R"
    output:
        "data/processed/all_names_alldata-{use_all_data}.csv"
    benchmark:
        "results/benchmarks/concatenate_files_alldata-{use_all_data}.tsv"
    params:
        use_all_data=use_all_data
    script:
        '{input.R}'

rule interpolate_mortality:
    input:
        csv="data/raw/alive_2016_per_100k.csv",
        R='code/interpolate_mortality.R'
    output:
        "data/processed/alive_2016_annual.csv"
    benchmark:
        "results/benchmarks/interpolate_mortality.tsv"
    script:
        "{input.R}"

rule get_name_counts:
    input:
        living="data/processed/alive_2016_annual.csv",
        names="data/processed/all_names_alldata-{use_all_data}.csv",
        R='code/get_total_and_living_name_counts.R'
    output:
        "data/processed/total_and_living_name_counts_alldata-{use_all_data}.csv"
    benchmark:
        "results/benchmarks/get_name_counts_alldata-{use_all_data}.tsv"
    script:
        '{input.R}'

rule clean:
    shell:
        """
        rm -rf data/raw/*.txt data/raw/*.pdf data/raw/*.zip data/processed/*.csv *.html family_report_*files/
        """
