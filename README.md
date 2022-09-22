# Ice plant transcriptome profiling tool
This repository provides a plotting tool for 72-hour time-course transcriptome profiling data of unstressed and drought stressed ice plant (*Mesembryanthemum crystallinum*). The experiment includes 24-hours of diel time followed by 48-hours of zeitgeber time with sampling every 4 hours. The provided data are in transcripts per million (TPM). The tool outputs a single plot (PNG) of the expression profile of the queried gene ID.

## Installation
```
git clone git@github.com:plantgenomicslab/Ice-plant-transcriptome-profiling.git
```
Be sure you have R (https://cran.r-project.org/) installed with the appropriate packages:
- ggplot2
- ggplot2
- plyr
- Hmisc
- extrafont
- gridExtra
- ggsci
- data.table
- dplyr

## Using the tool
To run the tool, you must navigate inside the clone repository. After running it you will see a new PNG file titled with the ice plant gene ID that you queried  
```
# Usage
Rscript plot_iceplant_expression.r [gene_id]

# For Example:
Rscript plot_iceplant_expression.r Mcr1G11970
```
