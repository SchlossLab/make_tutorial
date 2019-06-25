use_all_data="False"

rule download:
    output:
        zip="data/raw/names.zip",
        data=expand("data/raw/yob{year}.txt", year=range(1900, 2015))
    shell:
        """
        curl -Lo {output.zip} https://www.ssa.gov/oact/babynames/names.zip
        unzip -u -d data/raw/ {output.zip}
        """

rule cat_files:
    input:
        data=rules.download.output.data,
        R="code/concatenate_files.R"
    output:
        csv="data/processed/all_names.csv"
    params:
        use_all_data=use_all_data
    script:
        "{input.R}"

rule interpolate_mortality:
    input:
        csv="data/raw/alive_2016_per_100k.csv",
        R="code/interpolate_mortality.R"
    output:
        csv="data/processed/alive_2016_annual.csv"
    script:
        "{input.R}"

rule get_name_counts:
    input:
        living=rules.interpolate_mortality.output.csv,
        names=rules.cat_files.output.csv,
        R="code/get_total_and_living_name_counts.R"
    output:
        csv="data/processed/total_and_living_name_counts.csv"
    script:
        "{input.R}"

rule render_report:
    input:
        csv=rules.get_name_counts.output.csv,
        rmd="family_report.Rmd",
        plotr="code/plot_functions.R",
        render="code/render_report.R"
    output:
        "family_report.html"
    script:
        "{input.render}"
