args <- commandArgs(trailingOnly = TRUE)

# Set repo
r = getOption("repos")
r["CRAN"] = "http://cran.us.r-project.org"
options(repos = r)

# Package names
packages <- c("ggplot2", "plyr", "Hmisc", "gridExtra", "ggsci", "data.table", "dplyr")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Packages loading
invisible(lapply(packages, library, character.only = TRUE))

# Set ouput file name
gene <- args[1]
outpng <- paste(gene, "_DT_ZT_timecourse.png", sep = "")

# Load single gene from the complete dataset

if(grepl("^darwin", R.version$os) == TRUE){
match_line <- as.numeric(system(paste("gzcat iceplant_TPM_DT_ZT.tab.gz | grep -n ", gene, " | cut -f1 -d:", sep = ""), intern = T))
} else {
match_line <- as.numeric(system(paste("zcat iceplant_TPM_DT_ZT.tab.gz | grep -n ", gene, " | cut -f1 -d:", sep = ""), intern = T))
}

# create input for plot
headers <- read.csv(gzfile("iceplant_TPM_DT_ZT.tab.gz"), sep = "\t", nrows = 1, header = T)
total_tpm <- read.csv(gzfile("iceplant_TPM_DT_ZT.tab.gz"), sep = "\t", skip = match_line-1, nrows = 1, header = F)
colnames(total_tpm) <- colnames(headers)

# Melt data for plotting and separate treatment and time variables
total_tpm <- as.data.table(total_tpm)
total_tpm <- melt(total_tpm,
                  id.vars = "Geneid",
                  variable.name = "Rep",
                  value.name = "TPM")

total_tpm <- total_tpm %>% mutate(Treatment = gsub("[ZD]T[0-9]{2}_rep[1-3]", "", total_tpm$Rep)) %>%
                           mutate(Temp1 = gsub("^[UD]S", "", total_tpm$Rep))
total_tpm <- total_tpm %>% mutate(Time = gsub("_rep[1-3]", "", total_tpm$Temp1)) %>%
                           mutate(Replicate = gsub("[ZD]T[0-9]{2}_", "", total_tpm$Temp1))

# Compute average, min, and max for replicates
suppressWarnings(suppressMessages(
  tpm <- total_tpm %>% group_by(Treatment, Time) %>%
                           summarise(Avg_TPM = mean(TPM), n = n())
))
suppressWarnings(suppressMessages(
  Mintpm <- total_tpm %>% group_by(Treatment, Time) %>%
                         summarise(Min_TPM = min(TPM), n = n())
))
suppressWarnings(suppressMessages(
  Maxtpm <- total_tpm %>% group_by(Treatment, Time) %>%
                         summarise(Max_TPM = max(TPM), n = n())
))

tpm <- merge(tpm, Mintpm)
tpm <- merge(tpm, Maxtpm)

# Plot data and save
plot <- ggplot(tpm, aes(x=Time,y=Avg_TPM,colour=Treatment,group=Treatment, face="bold")) + 
annotate("rect", xmin="DT12", xmax="DT24", ymin=-Inf, ymax=Inf, fill="grey", alpha=0.3) + 
theme(panel.grid.major = element_line(colour = "#999999")) + 
theme_bw() + 
geom_point(size=2, alpha = 0.7) + 
geom_errorbar(aes(ymin=Min_TPM,ymax=Max_TPM),width=.1, alpha=0.6) + 
geom_line(size = 1) + theme_bw(base_size = 7) + labs(x = "Timecourse", y = "Transcripts Per Million (TPM)", title=gene) + 
labs(colour="Conditions") +
theme(legend.position = "bottom") +
theme(legend.position = c(.9, .85), legend.direction = 'horizontal') +
theme(legend.text = element_text(size=4),legend.title=element_text(size=4)) +
scale_colour_manual(values = c("#DC0000B2","#00A087B2")) +
theme(axis.text.x=element_text(angle=90, size=7))

# save print(plot)
print(paste("Writing plot to:", outpng, sep = " "))
ggsave (plot, file=outpng, width=18, height=7, units="cm")


