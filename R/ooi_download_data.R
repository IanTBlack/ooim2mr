#' Take dodsC OpenDAP URLs, converts to fileServer URLs, and downloads data to a given directory as a NetCDF.
#'
#' @param remote A list of OpenDAP urls where OOI data is located. Must all be from the same instrument type.
#' @param directory Default is to use the current working directory. If a directory is set in an R readable fashion, data will be downloaded to that directory.
#' @return A list of full filepath filenames where the data was downloaded. Further utilized by the ooi_get_data() function.
#' @examples
#' local = ooi_download_data(remote,'C:/Users/Ian/Desktop') #Downloads data to my desktop.

ooi_download_data <- function(remote, directory = getwd()){
  cat("Downloading NetCDFs...\n")
  files <- remote  #Assigned for simplifying remotely accessed to downloadable files.
  files <- str_replace(files,'dodsC','fileServer')  #Replace the dodsC with fileServer so that we can download the data from the location URLs.
  local <- c()  #Create a holder array for containing local file names.
  for (j in 1:length(files)){  #For each remote file...
    banana <- str_split(files[j],'/')  #Split the file name a number of ways so that we can pull out identifying information.
    stream_info <- banana[[1]][8]
    stream_info <- str_split(stream_info,'-')
    stream <- stream_info[[1]][7]
    req_info <- banana[[1]][9]
    banana <- str_split(req_info,'_')
    window_nc <- banana[[1]][length(banana[[1]])]
    banana <- str_split(req_info,'-')
    node <- banana[[1]][2]
    instrument <- banana[[1]][4] #Parse each URL to get the instrument.
    method <- banana[[1]][5]  #Parse each URL to get the datatype.
    banana <- req_info[[1]][1]
    banana <- str_split(banana,'_')
    deployment <- banana[[1]][1] #Parse each URL to get the deployment.
    site <- banana[[1]][2] #Parse each URL to get the site.
    site <- str_split(site,'-')
    site <- site[[1]][1]
    name <- sprintf('%s_%s_%s_%s_%s_%s',site,node,instrument,method,deployment,window_nc)  #String together a name using the parsed identifying information.
    filepath <- file.path(directory,name)  #Create a filepath based on the user selected directory.
    download.file(files[j],filepath,mode = 'wb')  #Download the file to the filepath.
    local <- c(local,filepath)
  }  #End of file naming/download for loop.
  cat("Files have been downloaded and named as follows.\n")
  print(local)
  return(local)
}  #End of function.
