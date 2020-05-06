#' Pull OOI data from local files (or OpenDAP urls) into the workspace.
#'
#' NOTE: The ncdf4 has an issue with accessing OpenDAP urls on Windows machines, thus data must be downloaded before reading it in. If using a MacOS or Linux machine, local parameter can be a list of OpenDAP urls.
#'
#' @param local A list of local fullpath filenames to pull data from. Can be created from ooi_download_data() or manually input.
#' @param simplify_data A flag that will drop annoying variables from ingested data if set to TRUE. If set to FALSE, all variables are brought into the workspace. If set to TRUE, it will pull from the curated list of variables.
#' @return A list of two sublists. Sublist 1 is a dataframe of data if it is 1D and can be combined or a sublist of more sublists if only one dataset if imported, or if data is 2D.
#' Further sublists are named by the filename, but can also be called by position. Within the filename sublists exist data as lists. Did that make sense?
#' Sublist 2 is a dataframe of imported variables, associated units, and variable descriptions.
#' @examples
#' lol = ooi_get_data(local,simplify_data = TRUE)


ooi_get_data <- function(local,simplify_data = TRUE){
  if(simplify_data == TRUE){
    nc <- nc_open(local[1])  #Open the first file...
    id <- ncatt_get(nc,0,'id')$value
    nc_close(nc)  #Close the file.
    banana <- str_split(id,'-')  #Pull the site, node, instrument, method, and stream.
    site <- banana[[1]][1]
    node <- banana[[1]][2]
    instrument <- banana[[1]][4]
    method <- banana[[1]][5]
    stream <- banana[[1]][6]

    #Bring in the science lookup table.
    lookup <- ooi_science
    lookup <- lookup[grep(site,lookup[,'SITE']),]  #Remove rows that don't match these conditions.
    lookup <- lookup[grep(node,lookup[,'NODE']),]
    lookup <- lookup[grep(instrument,lookup[,'INSTRUMENT']),]
    lookup <- lookup[grep(method,lookup[,'METHOD']),]
    lookup <- lookup[grep(stream,lookup[,'STREAM']),]

    #Pull the variables, units, display names, and descriptions.
    variables <- str_split(lookup$NCVARS,'\\|') #Variables and units from the CSV are long strings, where variables are separated by pipes.
    variables <- variables[[1]]
    units <- str_split(lookup$VARS_UNITS,'\\|')
    units <- units[[1]]
    display_name <- str_split(lookup$VARS_DISPLAY_NAME,'\\|')
    display_name <- display_name[[1]]
    description <- str_split(lookup$VARS_DESCRIPTION,'\\|')
    description <- description[[1]]
    bond <- cbind(variables,units)
    bond <- cbind(bond,display_name)
    bond <- cbind(bond,description)
    varunits <- bond #Combine the variables and units into one object.
  } else {  #If the user wants all of the variables...
    nc <- nc_open(local[1])
    variables <- attributes(nc$var)$names  #Get the variables from that file.
    units <- c()
    for (v in 1:length(variables)){  #For each variable, get the units.
      u <- ncatt_get(nc,variables[v])$units
      if (is.null(u)){  #If the variable doesn't have units, assign it this message as a placeholder.
        u <- 'NO UNITS ASSIGNED'
      }
      units <- c(units,u)  #Concatenate units from the previous loop.
    }
    varunits <- cbind(variables,units)  #Combine the variables and units.
    nc_close(nc)
  }

  #Super inefficient and stupid method for checking if variables exist and dropping them from affiliated frames if they don't.
  nc <- nc_open(local[1])  #Check to see if the dataset contains the int_ctd_pressure, lat, and lon variables.
  vs <- attributes(nc$var)$names
  nc_close(nc)
  check <- c('int_ctd_pressure') %in% vs
  if (check == FALSE){
    variables <- variables[variables != 'int_ctd_pressure']
    varunits <- varunits[varunits[,'variables'] != 'int_ctd_pressure',]
  }
  check <- c('lat') %in% vs
  if (check == FALSE){
    variables <- variables[variables != 'lat']
    varunits <- varunits[varunits[,'variables'] != 'lat',]
  }
  check <- c('lon') %in% vs
  if (check == FALSE){
    variables <- variables[variables != 'lon']
    varunits <- varunits[varunits[,'variables'] != 'lon',]
  }


  lol <- list() #Create a holder for the list of lists.
  for (i in 1:length(local)){  #For each file...
    nc <- nc_open(local[i])  #Open it.
    hold <- list()  #Create a holder list for the variables in this file.
    for (j in 1:length(variables)){  #For each variable...
      try({
        d <- ncvar_get(nc,variables[j])  #Get the data.
        d <- list(d)  #Put the data into a list.
        hold[j] <- d  #Assign the data to the holder array based on the variable's position.
      },silent = TRUE)  #Suppress error messages if the variable is not in the dataset (lat, lon, or int_ctd_pressure)
    }  #End of variables for loop.
    names(hold) <- variables
    lol[[i]] <- hold  #Positionally assign the list of variables to the list of files.
    nc_close(nc)  #Close the NetCDF.
  }  #End of filenames for loop.
  names(lol) <- local
  data <- lol   #Data is the list of lists.

  #Try to merge the data.
  #If the data consists of 1D arrays, then it is returned as a combined data.frame.
  #If it is multidimensional, then the data remains a list of lists.
  try({data <- Reduce(function(x, y){merge(x, y, all = TRUE)}, lol)}, silent = TRUE)
  data_variables_units <- list(data,varunits)  #Combine the data and varunits into a list. R only allows one output per function.
  names(data_variables_units) <- c('data','variables_units')
  cat("Data are now in the workspace.\n")
  return(data_variables_units)
}#End of function


