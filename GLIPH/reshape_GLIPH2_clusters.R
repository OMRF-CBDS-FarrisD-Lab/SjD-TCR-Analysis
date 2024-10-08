#The following steps use the GLIPH2 output file (default: out_cluster.csv) to extract individual TCR sequences comprising each specificity group (motif) and annotate their abundances under the subject IDs of respective cases and/or controls they were detected in
#The resulting matrix contains rows of unique motifs (tagged by an 'index') and the corresponding abundance of case and/or control TCRs that comprise it  

#Open RStudio or start an R session on an HPC cluster and load the dplyr package
library(dplyr)

#Read the output csv file containing GLIPH2 clusters into a dataframe 'df'
#select only columns containing index, motif 'pattern' of specificity groups, 'Sample' ID, and 'frequency' i.e. abundance of TCRs and assign to a new dataframe df1
df <- read.csv("out_cluster.csv")
df1 <- df[, c('index', 'pattern', 'Sample', 'Freq')]

#'Group' the motifs with respect to (wrt) 3 columns: 'index', 'pattern', and 'Sample', meaning they are "fixed" in place and act as a combined unique identifier for each motif
#Then, sum up frquency in the 4th column for each 'group' i.e. frequency counts from multiple TCRs detected in the same individual (case or control) comprising a given motif are summed up and collapsed under respective 'Sample' IDs to provide total abundance of a motif in an individual   
df2 <- df1 %>% group_by(index, pattern, Sample) %>% summarize(counts = sum(Freq))

#Load the reshape package
library(reshape)

#reshape df2 into a grouped table by setting index as the id variable, sum of frequencies i.e. 'counts' as time variable, and 'Sample' as the value variable. 
#Direction is set to wide meaning resultant dataframe will be in a wide format 
#See ?reshape() for details

df2 %>% reshape(idvar = c("index", "pattern"), timevar = "counts", direction = "wide", v.names = "Sample")
  
#*v.names*: names of variables in the long format that correspond to multiple variables in the wide format  

#*timevar*: the variable in long format that differentiates multiple records from the same group or individual.  
#If more than one record matches, the first will be taken (with a warning) - Duplicates

#*idvar*: Names of one or more variables in long format that identify multiple records from the same group/individual. These variables may also be present in wide format.

#Load reshape2 package
library(reshape2)

#This line performs a cast operation on df2, where 'index' + 'pattern' (unique motif identifiers) are the rows, 'Sample' IDs are the columns, and the abundance values under columns are filled based on the sums calculated in df2.
df3 <- dcast(df2, index+pattern~Sample)

#Replace all void cells i.e. 'NA' values by '0' for ease of mathematical operations 
df3[is.na(df3)] <- 0


#Output the file into a csv or a tsv. This file provides motif abundance distribution across all cases and HCs
write.csv(df3, file = "reshaped_out_cluster.csv", row.names = FALSE)