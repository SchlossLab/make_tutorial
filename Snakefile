raw = "data/raw"
processed = "data/processed"
start = 1900
end = 2015
use_all_data = False

years = range(start, end+1)

rule download:
    output:
        temp(f"{raw}/names.zip")
    shell:
        "curl -Lo {output} https://www.ssa.gov/oact/babynames/names.zip"

rule unzip:
    input:
        f"{raw}/names.zip"
    output:
        data=expand("{raw}/yob{year}.txt", raw=raw, year=years),
        pdf=f"{raw}/NationalReadMe.pdf"
    shell:
        "unzip -u -d {raw} {input}"

rule cat_files:
    input:
        data=expand("{raw}/yob{year}.txt", raw=raw, year=years),
        R="code/concatenate_files.R"
    output:
        f"{processed}/all_names.csv"
    params:
        use_all_data=use_all_data
    script:
        '{input.R}'

rule interpolate:
    input:
        csv=f"{raw}/alive_2016_per_100k.csv",
        R='code/interpolate_mortality.R'
    output:
        f"{processed}/alive_2016_annual.csv"
    script:
        "{input.R}"

rule get_name_counts:
    input:
        living=f"{processed}/alive_2016_annual.csv",
        names=f"{processed}/all_names.csv",
        R='code/get_total_and_living_name_counts.R'
    output:
        f"{processed}/total_and_living_name_counts.csv"
    script:
        '{input.R}'

rule render_report:
    input:
        csv=f"{processed}/total_and_living_name_counts.csv",
        rmd='family_report.Rmd',
        plotr="code/plot_functions.R",
        render="code/render_report.R"
    output:
        'family_report.html'
    script:
        "{input.render}"

rule clean:
    shell:
        "rm -rf {raw}/*.txt {raw}/*.pdf {raw}/*.zip {processed}/*.csv *.html family_report_*files/"
