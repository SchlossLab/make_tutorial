configfile: "config/config_default.yaml"

start = config['start']
end = config['end']
use_all_data = config['use_all_data']
#use_all_data_values = {"T", "F"}

rule target:
    input:
        f'family_report_alldata-{use_all_data}.html'
        #expand('family_report_alldata-{use_all_data}.html', use_all_data=use_all_data_values)

rule download:
    output:
        temp("data/raw/names.zip")
    benchmark:
        'results/benchmarks/download.tsv'
    shell:
        "curl -Lo {output} https://www.ssa.gov/oact/babynames/names.zip"

rule unzip:
    input:
        rules.download.output
    output:
        data=expand("data/raw/yob{year}.txt", year=range(start, end+1)),
        pdf="data/raw/NationalReadMe.pdf"
    benchmark:
        'results/benchmarks/unzip.tsv'
    shell:
        "unzip -u -d data/raw/ {input}"

rule cat_files:
    input:
        data=rules.unzip.output.data,
        R="code/concatenate_files.R"
    output:
        "data/processed/all_names_alldata-{use_all_data}.csv"
    benchmark:
        "results/benchmarks/cat_files_alldata-{use_all_data}.tsv"
    params:
        use_all_data="{use_all_data}"
    script:
        '{input.R}'

rule interpolate:
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
        living=rules.interpolate.output,
        names=rules.cat_files.output,
        R='code/get_total_and_living_name_counts.R'
    output:
        "data/processed/total_and_living_name_counts_alldata-{use_all_data}.csv"
    benchmark:
        "results/benchmarks/get_name_counts_alldata-{use_all_data}.tsv"
    script:
        '{input.R}'

rule render_report:
    input:
        csv=rules.get_name_counts.output,
        rmd='family_report.Rmd',
        plotr="code/plot_functions.R"
    output:
        'family_report_alldata-{use_all_data}.html'
    benchmark:
        'results/benchmarks/render_report_alldata-{use_all_data}.tsv'
    shell:
        """
        R -e "library(rmarkdown); render('{input.rmd}', output_file='{output}', params = list(csv_file='{input.csv}', plot_code='{input.plotr}'))"
        """

rule clean:
    shell:
        "rm -rf data/raw/*.txt data/raw/*.pdf data/raw/*.zip data/processed/*.csv *.html family_report_*files/"
