cat('\n\n==============================================================================\n')

cat(Sys.time(), '\t Processing NEON Eddy Flux Data...\n')
#------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------

# Install required packages if missing
list.of.packages <- c("BiocManager", "neonUtilities")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
#BiocManager::install('rhdf5')   #Uncomment if want to install or update package "rhdf5"

#------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------
library(rhdf5)
library(R.utils)

# Unzipping .gz files
site_name <- "KONZ"
root_dir <- "/media/bizon/Raghav10_2/Raghav_NEON_Data/"
files <- list.files(path=paste0(root_dir,site_name,"/"), pattern = "*.h5.gz", full.names = TRUE)
if(length(grep(".h5.gz", files))>0) {
  lapply(files[grep(".h5.gz", files)], function(x) {
    R.utils::gunzip(x)
  })
}
out_dir <- "/media/bizon/Raghav10_2/Raghav_NEON_Data/extracted_data_rData/"
#------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------
# Readind data from .h5 files
#------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------
# Open one of the file in Matlab or HDFView to check the Group of the data/variable you want to extract 
# e.g., In this case the group is "/KONZ/dp0p/data/irgaTurb/000_040" and variables that I want to extract are:
# densMoleCo2 (molCo2 m-3); densMoleH2o (molH2o m-3); presAtm (Pa); tempMean (K); time (-)
# Another Group is for "/KONZ/dp0p/data/soni/000_040" and the variables from this group that I want to extract are:
# time (-); veloXaxs (m s-1); veloYaxs (m s-1); veloZaxs (m s-1)


files <- list.files(path=paste0(root_dir,site_name), recursive=F, pattern = "*.h5")
files <- files[grep(".h5$", files)]       # only need the H5 files for data extraction
start.time <- Sys.time()
for(file_name in files){
  file <-  paste0(root_dir,site_name,"/",file_name)
  print(file)
  time <- h5read(file, paste0("/",site_name,"/dp0p/data/irgaTurb/000_040/time"))                     # Time [UTC]
  densMoleCo2 <- h5read(file, paste0("/",site_name,"/dp0p/data/irgaTurb/000_040/densMoleCo2"))       # H2O molar density (mol/m^3)
  densMoleH2o <- h5read(file, paste0("/",site_name,"/dp0p/data/irgaTurb/000_040/densMoleH2o"))       # CO2 molar density (mol/m^3)
  rtioMoleDryCo2 <- h5read(file, paste0("/",site_name,"/dp0p/data/irgaTurb/000_040/rtioMoleDryCo2")) # CO2 mixing ratio (dry mole fraction) (mol/mol)
  rtioMoleDryH2o <- h5read(file, paste0("/",site_name,"/dp0p/data/irgaTurb/000_040/rtioMoleDryH2o")) # H2O mixing ratio (dry mole fraction) (mol/mol)
  presSum <- h5read(file, paste0("/",site_name,"/dp0p/data/irgaTurb/000_040/presSum"))               # Total pressure (box + head) (Pa)
  presAtm <- h5read(file, paste0("/",site_name,"/dp0p/data/irgaTurb/000_040/presAtm"))               # Total pressure (box + head) (Pa)
  
  u <- h5read(file, paste0("/",site_name,"/dp0p/data/soni/000_040/veloXaxs"))                        # Measured along-axis wind speed (m/s)
  v <- h5read(file, paste0("/",site_name,"/dp0p/data/soni/000_040/veloYaxs"))                        # Measured cross-axis wind speed (m/s)
  w <- h5read(file, paste0("/",site_name,"/dp0p/data/soni/000_040/veloZaxs"))                        # Measured vertical-axis wind speed (m/s)
  Ts <- h5read(file, paste0("/",site_name,"/dp0p/data/soni/000_040/tempSoni"))                       # Sonic Temperature (K)
  
  
  NEON_df <- data.frame(DateTime=time, densMoleCo2 = densMoleCo2, densMoleH2o = densMoleH2o,
                          rtioMoleDryCo2 = rtioMoleDryCo2, rtioMoleDryH2o = rtioMoleDryH2o,
                          presSum = presSum, presAtm = presAtm, Ts = Ts, 
                          veloXaxs = u, veloYaxs = v, veloZaxs = w)
  filename = paste0(out_dir,site_name,'/',substr(file_name,1,nchar(file_name)-3), '.data')
  save(NEON_df, file=filename, compress = TRUE)
}

end.time <- Sys.time()
time.taken <- end.time - start.time
#-----------------------------------------------------
#---If want to save in hdf5 format--------------------
#-----------------------------------------------------
#filename = paste0(substr(file, 1, nchar(file)-3), '_extr.h5')
#h5createFile(filename) 
#h5createGroup(filename,"KONZ")
#h5write(time, filename,"KONZ/DateTime")
#h5write(densMoleCo2, filename,"KONZ/densMoleCo2")
#h5write(densMoleH2o, filename,"KONZ/densMoleH2o")
#h5write(rtioMoleDryCo2, filename,"KONZ/rtioMoleDryCo2")
#h5write(rtioMoleDryH2o, filename,"KONZ/rtioMoleDryH2o")
#h5write(Pa, filename,"KONZ/Pa")
#h5write(u, filename,"KONZ/veloXaxs")
#h5write(v, filename,"KONZ/veloYaxs")
#h5write(w, filename,"KONZ/veloZaxs")
#h5write(Ts, filename,"KONZ/Ts")
#h5ls(filename)
#-----------------------------------------------------
#-----------------------------------------------------