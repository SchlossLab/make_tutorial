configfile: "config/config_default.yaml"

raw = config['raw_dir']
processed = config['processed_dir']
start_year = config['start_year']
end_year = config['end_year']
use_all_data = config['use_all_data']

years = range(start_year, end_year+1)

rule target:
    input:
        f'family_report_alldata-{use_all_data}.html'

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
        f"{processed}/all_names_alldata-{{use_all_data}}.csv"
    benchmark:
        "logfiles/benchmarks/cat_files_alldata-{use_all_data}.tsv"
    params:
        use_all_data="{use_all_data}"
    script:
        '{input.R}'

rule interpolate:
    input:
        csv=f"{raw}/alive_2016_per_100k.csv",
        R='code/interpolate_mortality.R'
    output:
        f"{processed}/alive_2016_annual.csv"
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
        f"{processed}/total_and_living_name_counts_alldata-{{use_all_data}}.csv"
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
    params:
        start_year=start_year,
        end_year=end_year
    benchmark:
        'logfiles/benchmarks/render_report_alldata-{use_all_data}.tsv'
    script:
        "{input.render}"

rule clean:
    shell:
        "rm -rf {raw}/*.txt {raw}/*.pdf {raw}/*.zip {processed}/*.csv *.html family_report_*files/"
