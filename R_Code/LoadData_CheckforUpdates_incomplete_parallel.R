

#
#Same as above but using apply - takes ~20 seconds
system.time(apply(datalist,1, function(datalist){
  if (dir.exists(datalist['Folder']))
  {
    dataurl <- readLines(datalist['Data_URL'])
    web_updated_date <-
      as.POSIXct(strsplit(dataurl[grep('aboutUpdateDate', dataurl)], c('>|<'))[[1]][11], format =
                   '%b %d, %Y')
    local_updated_date <-
      as.POSIXct(datalist['Last_Download_Date'], format = '%d-%b-%y')
    if (web_updated_date < local_updated_date) {
      print(paste(datalist['Dataset_Name'], "is Up To Date"))
    } else   {
      download_extract_zip(
        url = datalist['Download_URL'], datasetname = datalist['Dataset_Name'], folder =  datalist['Folder']
      )
      datalist['Last_Download_Date'] <-
        format(Sys.Date(), format = '%d-%b-%y')
      datalist['Updated_Date'] <-
        format(web_updated_date, format = '%d-%b-%y')
      print(paste(datalist['Dataset_Name'], "was updated"))
    }
  } else {
    dir.create(datalist['Folder'])
    download_extract_zip(
      url = datalist['Download_URL'], datasetname = datalist['Dataset_Name'], folder =
        datalist['Folder']
    )
    datalist['Last_Download_Date'] <-
      format(Sys.Date(), format = '%d-%b-%y')
    datalist['Updated_Date'] <-
      format(web_updated_date, format = '%d-%b-%y')
    print(paste(datalist['Dataset_Name'], "was acquired"))
  }
}))






# Parallel version (Doesn't update the updated and downloaded dates)
#set number of cores for doparallel 
cl <- parallel::makeCluster(2)
doParallel::registerDoParallel(cl)

system.time(log <- foreach(i = 1:nrow(datalist), .combine=rbind, .verbose=TRUE) %dopar% {
  
  #system.time(for(i in 1:nrow(datalist)) {
  if (dir.exists(datalist$Folder[i]))
  {
    dataurl <- readLines(datalist$Data_URL[i])
    web_updated_date <-
      as.POSIXct(strsplit(dataurl[grep('aboutUpdateDate', dataurl)], c('>|<'))[[1]][11], format =
                   '%b %d, %Y')
    local_updated_date <-
      as.POSIXct(datalist$Last_Download_Date[i], format = '%d-%b-%y')
    if (web_updated_date < local_updated_date) {
      datastatus <- paste(datalist$Dataset_Name[i], "is Up To Date")
    } else   {
      download_extract_zip(
        url = datalist$Download_URL[i], datasetname = datalist$Dataset_Name[i], folder =  datalist$Folder[i]
      )
      datalist$Last_Download_Date[i] <-
        format(Sys.Date(), format = '%d-%b-%y')
      datalist$Updated_Date[i] <-
        format(web_updated_date, format = '%d-%b-%y')
      datalist[i, , drop=FALSE]
      datastatus <- paste(datalist$Dataset_Name[i], "was updated")
    }
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
    datalist[i, , drop=FALSE]
    datastatus <- paste(datalist$Dataset_Name[i], "was acquired")
  }
  
  return(datastatus)
  do.call('rbind', datalist)
  
})

stopCluster(cl)

log
