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
        zip=temp(f"{raw}/names.zip"),
        data=expand("{raw}/yob{year}.txt", raw=raw, year=years),
        pdf=f"{raw}/NationalReadMe.pdf"
    shell:
        """
        curl -Lo {output.zip} https://www.ssa.gov/oact/babynames/names.zip
        unzip -u -d {raw} {output.zip}
        """

rule cat_files:
    input:
        data=rules.download.output.data,
        R="code/concatenate_files.R"
    output:
        "data/processed/all_names_alldata-{use_all_data}.csv"
    benchmark:
        "logfiles/benchmarks/cat_files_alldata-{use_all_data}.tsv"
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
        "logfiles/benchmarks/interpolate_mortality.tsv"
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
        "logfiles/benchmarks/get_name_counts_alldata-{use_all_data}.tsv"
    script:
        '{input.R}'

rule render_report:
    input:
        csv=rules.get_name_counts.output,
        rmd='family_report.Rmd',
        plotr="code/plot_functions.R",
        render="code/render_report.R"
    output:
        'family_report_alldata-{use_all_data}.html'
    benchmark:
        'logfiles/benchmarks/render_report_alldata-{use_all_data}.tsv'
    script:
        "{input.render}"

rule clean:
    shell:
        "rm -rf data/raw/*.txt data/raw/*.pdf data/raw/*.zip data/processed/*.csv *.html family_report_*files/"
