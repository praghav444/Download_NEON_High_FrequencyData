cat('\n\n=============================================================================================\n')

cat(Sys.time(), '\t Downloading NEON Eddy Flux Data...\n')
#------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------
numDays <- function(year, month){
  # Calculates number of days for given year and month
  as.numeric(strftime(as.Date(paste(year+month%/%12,month%%12+1,"01",sep="-"))-1,"%d"))
}
#------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------
site_name <- "KONZ" # Site name to download data for (Check NEON website for the site information; e.g., https://www.neonscience.org/field-sites)

domain <- "D06" # Domain of the site (Check at NEON website for the domain information for different sites)

sys <- "ecte" #SAE system (ecte vs. ecse)

#Create download folder, create if it doesn't exist
DirDnld <- paste0("/Volumes/Raghav10_2/Raghav_NEON_Data/",site_name)
if(!dir.exists(DirDnld)) dir.create(DirDnld, recursive = TRUE)

#Create data download string
DateBgn <- as.Date("2018-01-01")
DateEnd <- as.Date("2018-12-31")
DateSeq <- seq.Date(from = DateBgn,to = DateEnd, by = "day")
PrdWndwDnld <- base::as.character(DateSeq)

#Filename base
fileInBase <- paste0("NEON.",domain,".",site_name,".IP0.00200.001.",sys,".")

#Create URL for data files (NEON data are now stored on Google Cloud)
urlDnld <- paste0("https://storage.googleapis.com/neon-sae-files/ods/dataproducts/IP0/",PrdWndwDnld,"/",site_name,"/",fileInBase,PrdWndwDnld,".l0p.h5.gz")

#Download filename (full path)
fileDnld <-  paste0(DirDnld,"/",base::toupper(sys),"_dp0p_",site_name,"_",PrdWndwDnld,".h5.gz")

#Download files
sapply(seq_along(urlDnld), function(x){
  download.file(url = urlDnld[x], destfile = fileDnld[x])
})

#ungzip file
gzFile <- list.files(DirDnld, pattern = ".gz", full.names = TRUE)
lapply(gzFile, R.utils::gunzip)