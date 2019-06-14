configfile: "config/config_default.yaml"

start = config['start']
end = config['end']
use_all_data = config['use_all_data']

rule render_report:
    input:
        csv="data/processed/total_and_living_name_counts.csv",
        rmd='family_report.Rmd',
        plotr="code/plot_functions.R"
    output:
        'family_report.html'
    shell:
        """
        R -e "library(rmarkdown); render('{input.rmd}', params = list(csv_file='{input.csv}', plot_code='{input.plotr}'))"
        """

rule download:
    output:
        temp("data/raw/names.zip")
    shell:
        "curl -Lo data/raw/names.zip https://www.ssa.gov/oact/babynames/names.zip"

rule unzip:
    input:
        "data/raw/names.zip"
    output:
        expand("data/raw/yob{year}.txt", year=range(start, end))
    shell:
        "unzip -u -d data/raw/ data/raw/names.zip"

rule concatenate_files:
    input:
        data=expand("data/raw/yob{year}.txt", year=range(start, end)),
        R="code/concatenate_files.R"
    output:
        "data/processed/all_names.csv"
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
    script:
        "{input.R}"

rule get_name_counts:
    input:
        living="data/processed/alive_2016_annual.csv",
        names="data/processed/all_names.csv",
        R='code/get_total_and_living_name_counts.R'
    output:
        "data/processed/total_and_living_name_counts.csv"
    script:
        '{input.R}'

rule clean:
    shell:
        """
        rm -f data/raw/*.txt
        rm -f data/raw/*.pdf
        rm -f data/raw/*.zip
        rm -f data/processed/*.csv
        rm -f family_report.html
        """
