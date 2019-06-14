# Baby name data is stored in a set of csv files, one per year, that contains
# the name, gender, and frequency. We need to concatenate the files into a
# single file that adds column headings and the year. Each file is stored in
# data/raw/ and is listed as `yob####.txt` where #### is the year, starting in
# 1880. The output file is data/processed/all_names.csv

if (exists("snakemake")) {
    name_files <- snakemake@input[["data"]]
	output_file <- snakemake@output[[1]]
    use_all_data <- as.logical(snakemake@params[["use_all_data"]])
} else {
    name_files <- list.files(path='data/raw', pattern="yob.*.txt", full.names=TRUE)
	output_file <- "data/processed/all_names.csv"
    use_all_data <- FALSE
}
print(paste0("use_all_data: ", use_all_data))
make_year_data_frame <- function(file_name=x){

	file <- read.csv(file=file_name, header=F, stringsAsFactors=FALSE)
	year <- gsub(".*yob(\\d\\d\\d\\d).txt", "\\1", file_name)
	file$V4 <- year
	return(file)

}

name_data_frames <- lapply(name_files, make_year_data_frame)
merged_names <- do.call(rbind, name_data_frames)
colnames(merged_names) <- c("name", "gender", "frequency", "year")

if (!use_all_data) {
    print("Not using all data")
    kids <- c("Sarah", "Mary", "Patrick", "Joseph", "John", "Ruth", "Jacob", "Peter", "Martha")
    merged_names <- merged_names[merged_names$name %in% kids,]
}

write.table(file=output_file, merged_names, sep=',',
						row.names=F, quote=F)
