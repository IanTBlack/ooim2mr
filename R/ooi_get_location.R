#' Check data request made to OOINet.
#'
#' @param response The response object made through the ooi_submit_request function
#' @param drop_paired A TRUE/FALSE flag that removes paired datasets from the return.
#' @return A list of remote urls where the data is located as dodsC NetCDFs.
#' @examples
#' remote = ooi_get_location(response)

ooi_get_location <- function(response,drop_paired = TRUE){
  require(jsonlite)  #jsonlite is required for this function to work.
  require(stringr)  #stringr is required for this function to work.
  require(httr)  #httr is required for this function to work.
  require(crayon)
  info = fromJSON(content(response,"text",encoding = "UTF-8"),flatten=TRUE) #Pull information from the response.
  thredds_status = status_code(GET(info$outputURL))  #Query the outputURL and return the status_code.
  if (thredds_status == 503){  #If the status code is 503, issue the following message.
    cat(red('Status Code 503: The OOI THREDDS server is undergoing maintenance or is at capacity. Try again later.\n'))
    return()
  }
  cat("Checking data status until it reads complete...\n")
  check = sprintf('%s%s',info$allURLs[2],'/status.txt')
  pb = txtProgressBar(min = 0, max = 600,style = 1)  #Create a text progress bar.
  for (i in 1:1800){  #Check the request status once per second for the next 30 minutes.
    status = content(GET(check),"text") #Get the content of the status page.
    if (grepl("complete",status,fixed=TRUE) == TRUE){  #If the status says
      cat(sprintf('Request took ~%s seconds to complete.\n',i))
      cat('For your records, the online catalog of your data request can be found here: ',underline(magenta(info$outputURL)),'\n')
      break  #Break out of the for loop.
    }
    else{  #If it doesn't say complete.
      Sys.sleep(1)  #Pause for one second.
      setTxtProgressBar(pb,i)  #Update the text progress bar.
    }
  }
  catalog <- info$allURLs[1]  #Get the catalog location of the data.
  raw_html = readLines(catalog)  #Read in the raw html.
  nc_pattern = "dataset=ooi.+?.nc'>"  #This is the pattern used to identify NetCDFs.
  txt = str_extract_all(raw_html,nc_pattern) #Parse out the relevent URLs based on the pattern.
  txt = txt[txt != 'character(0)']  #Remove elements that are empty.
  txt = gsub("\'>","",txt)  #Remove non-url characters.
  remote = str_replace(txt,'dataset=','https://opendap.oceanobservatories.org/thredds/dodsC/')  #Tack on the opendap url for remote access.

  if (drop_paired == TRUE){
    #For loop that drops paired data (i.e. CTD and VELPT) if the instrument is not a CTD or a VELPT.
    for (i in 1:length(remote)){
      banana = str_split(remote[i],'/')
      requested = banana[[1]][8]
      paired = banana[[1]][9]
      banana = str_split(requested,'-')
      requested = banana[[1]][5]
      banana = str_split(paired,'-')
      paired = banana[[1]][4]

      #Paired datasets
      if(grepl("CTD",requested) == TRUE || grepl("VEL",requested) == TRUE || grepl("ENG",requested) == TRUE){  #If the user requested CTD or VEL data, then we don't need to get rid of any superfluous data.
        break
        }
      else if(isTRUE(requested != paired)){ #If there is CTD or VEL data and the user didn't request it. Remove it from the location set.
        remote[i] = 'drop_me'
      }

      #Special cases: PCO2
      if (grepl("data_record_cal",remote[i])==TRUE){   #Drop calibration stream for pco2 data.
        remote[i] = 'drop_me'
      }

    }
    remote  = remote[!remote=="drop_me"]
  } else{
    remote = remote
  }

  cat("Data are now available to download at these remote location(s).\n")

  print(remote)
  return(remote)
} #End of function.
