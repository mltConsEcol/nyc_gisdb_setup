#Bash command to download data for Parks Properties and designate location
#wget 'https://data.cityofnewyork.us/api/geospatial/rjaj-zgq7?method=export&format=Original' -O test.zip
#unzip test.zip


#setwd("Raw_Data/NYC_TNC_NYCprogram")
setwd("~/../../../media/sf_N_DRIVE/Raw_Data/NYC_TNC_NYCprogram/Version2_testing/")


##setwd("N:/Raw_Data/NYC_TNC_NYCprogram/Version2_testing/") #For Windows

#Import list of data
datalist <- read.csv("DataList.csv", stringsAsFactors=FALSE)


#### Define function to extract and unzip file from the internet
download_extract_zip <- function(url, datasetname, folder) {
  dir.create('temp')
  download.file(
    url, destfile = paste('temp/', datasetname, '.zip', sep =
                            ''), method = "wget", quiet=TRUE
  )
  unzip(paste('temp/', datasetname, '.zip', sep = ''), exdir =
          folder)
  unlink('temp', recursive = TRUE)
}


##### If downloaded date in spreadsheet less recent updated date, download new
##### dataset and update the date in spreadsheet; if data non-existent (i.e., if
##### data not downloaded already), download

## Need to update this to an apply function for speed
## still need to add capability to import data into PostGIS if desired

#Non-parallel version (Updates the updated and downloaded dates) - takes ~20 seconds
system.time(for (i in 1:nrow(datalist)) {
  
  if (datalist$Data_Source[i] == 'NYCOpenData' & datalist$Format[i] == 'Shapefile')  {
    #Check if the directory with appropriate data exists locally
    if (dir.exists(datalist$Folder[i]))
    {
  
      #Pull in date updated from opendata website
      dataurl <- readLines(datalist$Data_URL[i])
      web_updated_date <-
        as.POSIXct(strsplit(dataurl[grep('aboutUpdateDate', dataurl)], c('>|<'))[[1]][11], format =
                     '%b %d, %Y')
      #Convert date updated from local files to posixct to compare with date on website
      local_updated_date <-
        as.POSIXct(datalist$Last_Download_Date[i], format = '%d-%b-%y')
      #If  date updated on website is older than local download date, report local data are up to date
      if (web_updated_date < local_updated_date) {
        print(paste(datalist$Dataset_Name[i], "is Up To Date"))
      
      } else {
      
        #if updated date on website is more recent than local download date, create folder for Archived data (if doesn't exist)
        #then move old data to that archived data folder, and download/unzip new folder into appropriate location
        if(!dir.exists('Archived_Data')) dir.create('Archived_Data')
        file.copy(from=list.files(datalist$Folder[i], full.names = TRUE, recursive=TRUE), to='Archived_Data', recursive=TRUE)
        unlink(datalist$Folder[i], recursive=TRUE)
        download_extract_zip(
          url = datalist$Download_URL[i], datasetname = datalist$Dataset_Name[i], folder =  datalist$Folder[i]
        )
        datalist$Last_Download_Date[i] <-
          format(Sys.Date(), format = '%d-%b-%y')
        datalist$Updated_Date[i] <-
          format(web_updated_date, format = '%d-%b-%y')
        #report the dataset was updated
        print(paste(datalist$Dataset_Name[i], "was updated"))
      }
      
    #If appropriate directory for data doesn't exist, create the directory and download/extract data
    } else {
      dir.create(datalist$Folder[i])
      download_extract_zip(
        url = datalist$Download_URL[i], datasetname = datalist$Dataset_Name[i], folder =
          datalist$Folder[i]
      )
      datalist$Last_Download_Date[i] <-
        format(Sys.Date(), format = '%d-%b-%y')
      datalist$Updated_Date[i] <-
        format(web_updated_date, format = '%d-%b-%y')
      #Indicate the dataset was acquired 
      print(paste(datalist$Dataset_Name[i], "was acquired"))
    }
  } else {
    print(paste(datalist$Dataset_Name[i], "was not checked"))}
    
})

#If desired, write out new version of data list with updated dates
write.csv(datalist, file = "DataList.csv", row.names = FALSE)



#http://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/bx_mappluto_16v1.zip - sample link for downloading mappluto data


#General Workflow: 
# Read table of existing data
# For each row, focus on folder, not specific shapefile, as shapefile names change - will keep folder name consistent though [each shapefile and associated files will go in its own folder]
# For row, look at data source - protocol will vary slightly from source to source
# Is updated dated in html Date > last download date? OR is updated date unavailable?
	# Yes -> Move files in folder into archive folder; 
		# use download link to initate download; download into temp dir; 
		# unzip into appropriate folder
			# If file is shapefile
			

#Required Columns
-# # Data Source (e.g., NYC Open Data, )
-# # Dataset Name
-# # Folder
-# # Download Date
-# # Download URL
--# # Data URL (NYC Open Data Page)
--# # Object Type (Polygons)
--# # Format (shapefile, gdb, raster, csv)
# # postgis schema
# # postgis table name

#Desired Columns 
# # Dataset Description
# # Notes





#Read lines from webpage
system.time(req <- readLines("https://data.cityofnewyork.us/City-Government/Parks-Properties/rjaj-zgq7"))

#Pull out the Update date and convert to POSIXct from Mon. date, YEAR [can be directly compared to other date]
as.POSIXct(strsplit(req[grep('aboutUpdateDate', req)], c('>|<'))[[1]][11], format='%b %d, %Y')

#Pull 