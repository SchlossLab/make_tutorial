configfile: "config/config_default.yaml"

raw = config['raw_dir']
processed = config['processed_dir']
start_year = config['start_year']
end_year = config['end_year']
use_all_data = config['use_all_data']

rule target:
    input:
        f'family_report_alldata-{use_all_data}.html'

checkpoint download:
    output:
        zip=temp(f"{raw}/names.zip"),
        dir=directory(f"{raw}/years")
    shell:
        """
        curl -Lo {output.zip} https://www.ssa.gov/oact/babynames/names.zip
        unzip -u -d {output.dir} {output.zip}
        """

def get_year_filenames(wildcards):
    dir = checkpoints.download.get(**wildcards).output.dir
    years = glob_wildcards(f"{dir}/yob{{year}}.txt").year
    return expand("{dir}/yob{year}.txt", dir=dir, year=years)

rule cat_files:
    input:
        data=get_year_filenames,
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
        protected(f"{processed}/total_and_living_name_counts_alldata-{{use_all_data}}.csv")
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
        'family_report_alldata-{use_all_data}.html',
        temp(directory('family_report_alldata-{use_all_data}_files/'))
    params:
        start_year=start_year,
        end_year=end_year
    benchmark:
        'logfiles/benchmarks/render_report_alldata-{use_all_data}.tsv'
    script:
        "{input.render}"

rule clean:
    shell:
        "rm -rf {raw}/years/ {raw}/*.zip {processed}/*.csv *.html family_report_*files/"
