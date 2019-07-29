#################################################################################################
#################################################################################################
##                                                                                             ##
##                 R SCRIPT FOR ANALYSIS OF DATA IN COOPER & BARRY (2017)                      ##
##                                                                                             ##
#################################################################################################
#################################################################################################

## Reference:       Cooper, K.M., Barry, J. A big data approach to macrofaunal baseline
#                   assessment, monitoring and sustainable exploitation of the seabed. Scientific 
#                   Reports (2017). 

## Required Files:
#                   1.  C5922 FINAL SCRIPTV91.R (i.e. this script)
#                   2.  C5922DATASET13022017.csv (Raw data)
#                   3.  Dataset description.xlsx (Description of data in C5922DATASET13022017.csv)
#                   4.  PARTBAGG18112016.csv  (Faunal Aggregation data)
#                   5.  EUROPE.shp (European Coastline)
#                   6.  EuropeLiteScoWal.shp (European Coastline with UK boundaries)
#                   7.  Aggregates_Licence_20151112.shp (Aggregates Licensed extraction areas)
#                   8.  Aggregates_Application_20150813.shp (Aggregates Application areas)
#                   9.  HUMBERLICANDAPP.shp (Licensed Extraction and Application Areas - Humber)
#                   10. H_SIZ_PSD_POLYGONS_UNION_2014.shp (Humber SIZs)
#                   11. H_492_PIZ_APP.shp (Area 492 Application Area)
#                   12. ANGLIANLICANDAPP.shp (Licensed Extraction and Application Areas - Anglian)
#                   13. A_SIZ_PSD_POLYGONS_UNION.shp (Anglian SIZs)
#                   14. THAMESLICANDAPP.shp (Licensed Extraction and Application Areas - Thames)
#                   15. T_SIZ_PSD_POLYGONS_UNION_REV_2014.shp (Thames SIZs)
#                   16. T_501_1_2_SIZ_PSD.shp (Area 501 1/2 SIZ)
#                   17. EECLICANDAPP.shp (Licensed Extraction and Application Areas-East Channel)
#                   18. EC_SIZ_PSD_POLYGONS_UNION_REV.shp (East Channel SIZs)
#                   19. SCOASTLICANDAPP.shp (Licensed Extraction and Application Areas - South
#                       Coast)
#                   20. SC_SIZ_PSD_POLYGONS_UNION.shp (South Coast SIZs)
#                   21. BRISTOLCHANNELLICANDAPP.shp (Licensed Extraction and Application Areas -
#                       Bristol Channel)
#                   22. BC_SIZ2.shp (Bristol Channel/Severn Estuary SIZs)
#                   23. NORTHWESTLICANDAPP.shp(Licensed Extraction and Application Areas - 
#                       North West)
#                   24. NW_392_SIZ_PSD_LICENCE_EXISTING.shp (Area 392 SIZ)
#                   25. AREA_457_PSD.shp (Area 457 SIZ)
#                   26. GOODWIN LICENCE FINAL POLYGON.shp (Goodwin Sands Extraction area)
#                   27. GoodwinSIZ.shp (Goodwin Sands SIZ)
#                   28. DEFRADEMKC8.shp (Seabed bathymetry)

## Required folder structure:
#                   C:\C5922 FINAL\R
#                                 \DATA
#                                 \OUTPUTS

## Folder Contents:
#                   C:\C5922 FINAL\R (file 1)
#                   C:\C5922 FINAL\DATA (files 2-28)
#                   C:\C5922 FINAL\OUTPUTS (.png and .csv files resulting from script)

## Set working directory
setwd('C:/Users/kmc00/OneDrive - CEFAS/R_PROJECTS/C7777A')

## Script Structure:
#                   The script will generate the figures and content of tables in Cooper & Barry
#                   (2017). The script is divided into 8 sections (see below) and 68 individual 
#                   steps.  Each numbered step has a header box with a reference to the approriate
#                   section in the paper, a task description and a notes section. Note that steps
#                   33 and 54 are undertaken using the Primer 6 software.  The first section of the
#                   script deals with the creation of a dataset at the family level (Steps 1-6).
#                   This only needs to be done once, as the resulting file can be loaded during
#                   subsequent use of the script (i.e. start at step 7).

## Script Sections:
#                   A)  BUILD DATASET                 (Step 1:6)
#                   B)  LOAD DATASET                  (Step 7)
#                   C)  MAPPING LAYERS                (Step 8)
#                   D)  DATASET SUMMARY               (Step 9:15)
#                   E)  FAUNAL ANALYSIS               (Step 16:41)
#                   F)  SEDIMENT ANALYSIS             (Step 42:59)
#                   G)  GRAVEL/RICHNESS CHECK         (Step 60:65)
#                   H)  ASSESSING SEDIMENT CHANGE     (Step 66:68)

#################################################################################################
# # #                                  (A) BUILD DATASET                                    # # #
#################################################################################################

# The underlying dataset (C5922DATASET13022017.csv) used in this script is a station by variable 
# matrix, with faunal data at the level of species and above. As the data will be analysed at the
# family level it is first necessary to create a sample by variable matrix with faunal data at 
# the # family level. To do this the raw data are imported and converted to family level using an
# aggregatrion file. The large size of the raw data matrix means that it cannot be easily 
# manipulated in R. Therefore, following loading, the data is split into 2 chunks.  Each chunk is
# seperatley manipulated before the 2 resulting dataframes are combined to produce the single
# sample by variables (fauna at family level) matrix.

# Where family level dataset already created then proceed to Step 7

#################################################################################################
### STEP REF:       1                                                                         ###  
###                                                                                           ###
### PAPER SECTION:  ALL                                                                       ###
###                                                                                           ###
### TASK:           Load the raw dataset                                                      ###
#################################################################################################

## Load data (created using script in 'C5922 FINAL SCRIPT BUILD DATASETV8.R')
dataall2=read.csv("DATA/C5922DATASET13022017.csv", header=T,na.strings=c("NA", "-","?","<null>"),
                  stringsAsFactors=F,check.names=FALSE)

## View dataset
View(dataall2)

## Remove 1st column (repeat of row labels)
dataall2 = dataall2[,-1]

## View dataset
View(dataall2)# check 1st column removed

## Check dataset dimensions
dim(dataall2)# 33198 13587

## Check column order
options(max.print=1000000)# to see all column names
names(dataall2) # Structure: Faunal data (A & B) followed by other variables  

## Select only variables of interest
# 1:13450 Faunal data
# 13451 Order
# 13452 SampleCode
# 13453 SurveyName
# 13455 Latitude_WGS84
# 13456 Longitude_WGS84
# 13458 Gear
# 13460 Sieve
# 13461 Year
# 13462 Month
# 13465:13563 Sed data
# 13564 Sector
# 13565 Source
# 13569 PSASubSample
# 13572 Treatment
# 13575 Sal
# 13576 Temp
# 13577 Chla
# 13578 SPM
# 13579 Depth
# 13580 WOV
# 13581 AvCur
# 13582 Stress
# 13583 IncCol
# 13584 TopSieveEmpty
# 13585 Data
# 13586 Programme
# 13587 WentworthSuitability
dataall3=dataall2[,c(1:13450,13465:13563,13451:13453,13455:13456,13458,13460:13462,13564:13565,
                     13569,13572,13575:13587)]

## Check column names
names(dataall3)

## Check dataset dimensions
dim(dataall3) # 33198 (samples) 13575 (variables)

#################################################################################################
### STEP REF:       2                                                                         ###  
###                                                                                           ###
### PAPER SECTION:  ALL                                                                       ###
###                                                                                           ###
### TASK:           Split Raw dataset (selected variables) into sections A & B                ###
###                                                                                           ###
### NOTES:          The dataset is too large to manipulate as a whole, so it must be split    ###
###                 into2 chunks(A & B)                                                       ###
#################################################################################################

## Create a dataframe object 'dataparta' for Part A
dataparta=dataall3[1:21101,]# samples 1:21101

## Create a dataframe object 'datapartb' for Part B
datapartb=dataall3[21102:33198,]# samples 21102:33198

## Save parts A and B as .csv files
write.csv(dataparta,file = "DATA/dataparta.csv",row.names=TRUE)
write.csv(datapartb,file = "DATA/datapartb.csv",row.names=TRUE)

## Remove objects that are no longer required to free up memory
rm(dataall2,dataall3)
gc()
rm(dataparta,datapartb)
gc()

#################################################################################################
### STEP REF:       3                                                                         ###  
###                                                                                           ###
### PAPER SECTION:  ALL                                                                       ###
###                                                                                           ###
### TASK:           Generate a taxon matrix (family level) for Part A                         ###
###                                                                                           ###
### NOTES:          If you experience memory problems close R and other programmes and start  ###
###                 from Step 3 (having set the working directory)                            ###
#################################################################################################

## Load the data for Part A
dataparta=read.csv("DATA/dataparta.csv", header=T,na.strings=c("NA", "-", "?","<null>"),
                   stringsAsFactors=F)

## View df 'dataparta'
View(dataparta)

## Remove 1st column
dataparta$X=NULL

## Check dimensions of Part A - should be 21101 13575
dim(dataparta)# it is

## View names for df 'dataparta'
options(max.print=1000000)# to see all column names
names(dataparta)

## Select only the faunal data. Note that this includes columns for additional taxa from part B
# (all with zero abundance)
dataparta2=dataparta[,1:13450]

## View df 'dataparta2
View(dataparta2)

## Change NAs to 0. NAs occur for taxa relating to part B
dataparta2[is.na(dataparta2)] <- 0

## Transpose the faunal data (keep column names)
t_dataparta = setNames(data.frame(t(dataparta2[,-1])), dataparta2[,1])

## Bring in aggregation data. Note that Part A includes full taxon list, hence use of the Part B
# Aggregation file
agg=read.csv("DATA/PARTBAGG05022017.csv", header=T,
             na.strings=c("NA", "-","?","<null>"),stringsAsFactors=F,check.names=FALSE)

## View aggreation file
View(agg)
names(agg)
## Join the aggregation file to data
alla=cbind(agg,t_dataparta)

## Remove unwanted taxa
alla2 = subset(alla, Include=='Y')

## Identify dimensions of df 'alla2'
dim(alla2)# note the total number of columns

## View df 'alla2'
View(alla2)# identify the col nos for Family and samples

## Take only the Family and sample columns
alla2fam=alla2[,c(13,31:21131)]

## Remove objects that are no longer required to free up memory
rm(alla)
gc()
rm(alla2)
gc()
rm(t_dataparta)
gc()
rm(dataparta)
gc()
rm(dataparta2)
gc()

## Aggregate data (sum) by ScientificName_accepted for multiple samples
famabundPARTA=aggregate(. ~ ScientificName_accepted, alla2fam, sum)

## Remove objects that are no longer required to free up memory
rm(alla2fam)
gc()
rm(agg)
gc()

## Write file and close
write.csv(famabundPARTA,file = "DATA/speciesabundPARTA.csv",row.names=TRUE)

#################################################################################################
### STEP REF:       4                                                                         ###  
###                                                                                           ###
### PAPER SECTION:  ALL                                                                       ###
###                                                                                           ###
### TASK:           Generate a taxon matrix (family level) for Part B                         ###
#################################################################################################

## Load the data for Part B
datapartb=read.csv("DATA/datapartb.csv", header=T,na.strings=c("NA", "-", "?","<null>"),
                   stringsAsFactors=F)

## Remove 1st column
datapartb$X=NULL

## View names for df 'datapartb'
options(max.print=1000000)# to see all column names
names(datapartb)

## Select only the faunal data
datapartb2=datapartb[,1:13450]

## Transpose the data (keep column names)
t_datapartb = setNames(data.frame(t(datapartb2[,-1])), datapartb2[,1])

## Bring in aggregation data
agg=read.csv("DATA/PARTBAGG05022017.csv", header=T,na.strings=c("NA", "-", "?","<null>"),
             stringsAsFactors=F)

## Join aggregation file to data
allb=cbind(agg,t_datapartb)

## Remove unwanted taxa
allb2 = subset(allb, Include=='Y')
names(allb2)

## Take only the ScientificName_accepted col and the sample cols (NB Impossible to aggregate other factor cols)
allb2fam=allb2[,c(13,31:12127)]

## Remove objects that are no longer required to free up memory
rm(agg,allb,allb2,datapartb,datapartb2,t_datapartb)
gc()

## Sum by family for multiple samples
famabundPARTB=aggregate(. ~ ScientificName_accepted, allb2fam, sum)

## Remove objects that are no longer required to free up memory
rm(allb2fam)
gc()

## Write file
write.csv(famabundPARTB,file = "DATA/speciesabundPARTB.csv",row.names=TRUE)

## Remove objects that are no longer required to free up memory
rm(famabundPARTA,famabundPARTB)
gc()

#################################################################################################
### STEP REF:       5                                                                         ###  
###                                                                                           ###
### PAPER SECTION:  ALL                                                                       ###
###                                                                                           ###
### TASK:           Build species abundance matrix from Parts A & B                            ###
#################################################################################################

## Load data from Part A
famabundPARTA=read.csv("DATA/speciesabundPARTA.csv", header=T,na.strings=c("NA", "-","?","<null>"),
                       stringsAsFactors=F,check.names=FALSE)

## View df 'famabundPARTA'
View(famabundPARTA)

## Remove 1st column
famabundPARTA[1]=NULL

## Check dimensions of df 'famabundPARTA'
dim(famabundPARTA)#774 21102

## Load data from Part B
famabundPARTB=read.csv("DATA/speciesabundPARTB.csv", header=T,na.strings=c("NA", "-","?","<null>"),
                       stringsAsFactors=F,check.names=FALSE)

## Remove 1st column
famabundPARTB[1]=NULL

## View df 'famabundPARTB'
View(famabundPARTB)

## Check dimensions of df 'famabundPARTB'
dim(famabundPARTB)#774 12098

## Merge the dataframes 'famabundPARTA' and 'famabundPARTB'
total <- merge(famabundPARTA,famabundPARTB,by="ScientificName_accepted")

##Check dimensions of df 'total'
dim(total)#774 33199

## View df 'total'. Note samples as columns
View(total)

## Transpose df 'total' so samples as rows and variables as columns
t_total = setNames(data.frame(t(total[,-1])), total[,1])

## Check orientation of df 't_total'
View(t_total)

## Check names of df 't_total'
names(t_total)

## Change row names (sample codes) to a column
t_total <- cbind(Sample = rownames(t_total), t_total)
rownames(t_total) <- NULL

## Check new column (Sample) added and old row names (Sample codes)removed
View(t_total)# all correct

## Write file
write.csv(t_total,file = "DATA/t_total.csv",row.names=TRUE)

#################################################################################################
### STEP REF:       6                                                                         ###  
###                                                                                           ###
### PAPER SECTION:  ALL                                                                       ###
###                                                                                           ###
### TASK:           Add other data (sediments/metadata/other variables) to family abundance   ###
###                 matrix                                                                    ###
#################################################################################################

## Load required dfs
dataparta=read.csv("DATA/dataparta.csv", header=T,na.strings=c("NA", "-", "?","<null>"),
                   stringsAsFactors=F)
datapartb=read.csv("DATA/datapartb.csv", header=T,na.strings=c("NA", "-", "?","<null>"),
                   stringsAsFactors=F)

## Remove 1st columns of dfs 'dataparta' and 'datapartb'
dataparta$X=NULL
datapartb$X=NULL

## View names of df 'dataparta'
names(dataparta)
names(datapartb)

## Select only the non-faunal data (i.e. meta and sediment data)
dataparta2other=dataparta[,c(1,13451:13575)]
datapartb2other=datapartb[,c(1,13451:13575)]

## Join together df 'dataparta2other' and 'datapartb2other' (other variables -  parts A and B)
datapartab2other=rbind(dataparta2other,datapartb2other)

## Merge faunal (species) matrix with other variables
data <- merge(t_total,datapartab2other,by="Sample")

## Check dimensions of df 'data'
dim(data)# 33198 4147

## Check names of df 'data'
names(data)

## View df 'data'
View(data)

## Save df 'data' (Sample/variable matrix, Family level)
write.csv(data,file = "DATA/C5922DATASETSPECIES13022017.csv",row.names=TRUE)

## Remove objects that are no longer required to free up memory
rm(data,dataparta,dataparta2other,datapartab2other,datapartb,datapartb2other,famabundPARTA,
   famabundPARTB,t_total,total)
gc()

#################################################################################################
# # #                                  (B) LOAD DATASET                                     # # #
#################################################################################################

#################################################################################################
### STEP REF:       7                                                                         ###  
###                                                                                           ###
### PAPER SECTION:  ALL                                                                       ###
###                                                                                           ###
### TASK:           Load dataset                                                              ###
###                                                                                           ###
### NOTES:          The dataset is a sample by variable matrix. Variables include faunal taxa ###
###                 (species), sediment data, metadata and other explanatory variables         ###
#################################################################################################

## Read in data
data=read.csv("DATA/C5922DATASETSPECIES13022017.csv", header=T,na.strings=c("NA", "-","?","<null>"),
              stringsAsFactors=F,check.names=FALSE)

## Remove 1st col
data[1] <- NULL    

## Check dataset dimensions
dim(data)#33198 900

## View dataset
#View(data)

## Change variable data types (factors required for plotting).
data$Sieve = as.factor(data$Sieve)
data$Year2 = as.factor(data$Year)
data$Month = as.factor(data$Month)
data$Source = as.factor(data$Source)
data$Gear = as.factor(data$Gear)
data$Data = as.factor(data$Data)

## Number of Surveys
length(rle(sort(data$Survey))$values)# 777

## Number of samples by Survey
table(data$Survey)


#################################################################################################
# # #                                  (E) FAUNAL ANALYSIS                                  # # #
#################################################################################################

#################################################################################################
### STEP REF:       16                                                                        ###  
###                                                                                           ###
### PAPER SECTION:  METHODS \ Faunal data analysis \ Data subset                              ###
###                 RESULTS \ Faunal data analysis                                            ###
###                                                                                           ###
### TASK:           Prepare data for faunal analysis                                          ###
###                                                                                           ###
### NOTES:          Create a subset of comparable data for subsequent faunal analyses         ###
#################################################################################################

## Subset data by gear (all 0.1m2 grabs)
data2 = subset(data, Gear=="MHN" | Gear=="DG" | Gear=="VV" | Gear=="SM")

## Check dimensions of df 'data2'
dim(data2)# 32044 900

## subset by sieve size (1mm only)
data3 = subset(data2, Sieve=='1')

## Check dimensions of df 'data3'
dim(data3)# 27622 900

## Check names of df 'data3'to identify faunal data columns
names(data3) # 2:775

## Remove samples from the faunal data (df data3) where no fauna present
data4 = data3[ rowSums(data3[,2:4022])!=0, ]

## Check dimensions of df 'data4'
dim(data4)#27432 900
names(data4[1,1:10])
## Identify (usinig the .csv file) variables with no abundance
#write.csv(data4,file = "OUTPUTS/data4.csv",row.names=TRUE)

## Remove variables with no abund (got list from csv file). There will be taxa
# with no abund as some samples with taxa present have been deleted in gear step above  
data4.5 <- data4[-c(6,14,28,29,32,49,57,66,73,74,78,101,107,109,119,123,124,127,128,129,152,173,179,187,189,200,202,203,210,211,214,227,232,233,245,249,251,252,257,258,269,303,311,312,334,339,344,352,358,359,362,372,375,380,398,405,421,426,447,455,461,468,473,474,478,484,491,492,493,495,510,514,518,519,538,539,545,555,565,566,587,588,589,590,592,593,594,596,599,600,604,605,613,636,640,673,679,684,689,690,713,721,726,731,762,765,776,780,781,782,784,785,790,811,815,819,837,841,848,854,876,879,894,896,915,920,926,935,942,943,955,956,957,958,964,974,976,977,978,980,986,991,997,1006,1011,1013,1015,1021,1028,1030,1037,1044,1060,1061,1063,1064,1104,1112,1114,1129,1130,1136,1140,1152,1167,1176,1189,1192,1193,1206,1210,1212,1213,1219,1223,1262,1274,1275,1289,1319,1325,1326,1327,1330,1343,1346,1347,1368,1376,1379,1388,1390,1391,1395,1400,1404,1409,1412,1424,1436,1472,1473,1475,1479,1492,1494,1496,1527,1529,1533,1539,1541,1549,1562,1573,1578,1584,1585,1586,1588,1589,1620,1623,1627,1629,1631,1642,1644,1646,1658,1661,1670,1674,1686,1688,1691,1699,1720,1734,1755,1758,1759,1760,1783,1786,1787,1789,1791,1794,1797,1798,1803,1817,1819,1824,1825,1827,1829,1842,1850,1851,1852,1866,1867,1871,1885,1888,1889,1890,1891,1896,1898,1899,1906,1907,1909,1911,1914,1920,1921,1940,1944,1946,1947,1948,1960,1961,1962,1963,1964,1982,1984,1988,1996,2005,2012,2013,2018,2032,2034,2035,2037,2060,2065,2080,2096,2105,2109,2123,2124,2125,2147,2159,2160,2163,2183,2198,2202,2209,2210,2218,2224,2225,2234,2235,2239,2240,2242,2267,2269,2273,2284,2288,2293,2294,2299,2309,2312,2322,2323,2324,2325,2326,2330,2339,2341,2346,2347,2349,2361,2367,2376,2379,2387,2388,2393,2403,2406,2407,2408,2411,2412,2413,2426,2441,2445,2458,2467,2486,2495,2496,2506,2512,2524,2525,2530,2542,2545,2561,2563,2577,2578,2581,2606,2607,2608,2609,2613,2625,2627,2630,2633,2634,2636,2637,2640,2642,2643,2644,2645,2646,2647,2651,2653,2657,2660,2669,2673,2680,2683,2685,2686,2698,2715,2718,2737,2751,2752,2758,2759,2768,2769,2784,2786,2787,2788,2795,2797,2800,2815,2820,2822,2839,2846,2848,2871,2874,2892,2898,2915,2916,2922,2923,2931,2941,2954,2959,2962,2964,2968,2981,2987,2990,3017,3020,3022,3024,3034,3035,3036,3041,3048,3057,3060,3092,3102,3120,3127,3130,3131,3133,3134,3167,3175,3181,3184,3185,3186,3187,3190,3191,3194,3198,3215,3218,3224,3227,3233,3242,3244,3245,3247,3248,3251,3258,3269,3278,3303,3315,3316,3329,3330,3331,3332,3336,3362,3381,3415,3441,3490,3497,3499,3502,3503,3509,3515,3516,3519,3532,3561,3570,3573,3576,3577,3580,3603,3610,3614,3619,3628,3633,3635,3643,3671,3681,3683,3687,3694,3698,3721,3723,3728,3729,3730,3731,3736,3737,3746,3750,3762,3763,3779,3782,3785,3819,3837,3840,3858,3867,3890,3897,3903,3904,3907,3917,3931,3941,3942,3943,3947,3950,3951,3952,3953,3955,3959,3962,3979,3981,3995,3999,4003,4006,4015,4016,4017,4019,4022)]

## Check dimensions of df 'data4.5'
dim(data4.5)# 27432 829

## Show names of df 'data4.5'
options(max.print=10000)
names(data4.5)
dim(data4.5)

## Remove samples not in North Sea. Bounding box from http://www.marineregions.org/gazetteer.php?p=details&id=2350 50.9954
data4.6=subset(data4.5,Latitude_WGS84>50.9954 & Latitude_WGS84<61.017)
data4.7=subset(data4.6,Longitude_WGS84>-4.4454 & Longitude_WGS84<12.0059)
dim(data4.7) #16514  3560

## Faunal subset (ie remove Sample,Latitude_WGS84, Longitude_WGS84, month and year)
names(data4.7)
data5=data4.7[,2:3434]

## Check dimensions of df 'data5'
dim(data5) #27432 703

## Check df 'data5' is just the faunal data
names(data5)# it is
#View(data5)
## Now find which species is most common
## replace all 0 with NA
data5[data5 == 0] <- NA

##colsums
#counts=colSums(!is.na(data5))
counts=as.data.frame(colSums(!is.na(data5)))
#View(counts)

colnames(counts)[1] <- "Counts"
counts$ScientificName_accepted <- rownames(counts)

## Drop rownames
rownames(counts) <- NULL

## Update colum order
counts2=counts[,2:1]
#View(counts2)

## Remove records with zero abundance
counts2[counts2==0] <- NA
#View(counts3)
counts3<-counts2[complete.cases(counts2),]

## Save as .csv
write.csv(counts3,file = "OUTPUTS/Most commonly occurring taxa big dataset North Sea.csv",row.names=TRUE)




