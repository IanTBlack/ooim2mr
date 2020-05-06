#' Generate an OOI request URL through a curated remote lookup table.
#'
#' @param site An eight (8) character designator for OOI sites.
#' @param node A five (5) character designator for OOI nodes. Alternatively, a simplified string for OOI sites that is greater than 5 characters. grep allows for use of substrings.
#' @param instrument A twelve (12) character designator for the OOI instrument on the associated site and node. grep allows for use of substrings.
#' @param method An indicator for how the data was delivered. Options are recovered_cspp, recovered_host, recovered_inst, streamed, telemetered.
#' @param stream Optional: Default is an empty string. If utilized, it helps narrow URL selection to a single URL. grep allows for use of substrings.
#' @param start_date The UTC start date of the data request in the format of YYYY-mm-dd. Default is 2010-01-01.
#' @param start_time The UTC start time of the data request in the format of HH:MM:SS. Default is 00:00:00.
#' @param stop_date The UTC stop date of the data request in the format of YYYY-mm-dd. Default is 2040-12-31.
#' @param stop_time The UTC stop time of the data request in the format of HH:MM:SS. Default is 23:59:59.
#' @return The request URL generated from input parameters. If more than one URL is created from the inputs, a list of URLs is returned, prompting the user to finetune their selection.
#' @examples
#' url = ooi_create_url(site = 'CE02SHSP',node = 'PROFILER',instrument = 'CTD',method = 'recovered_cspp') #Requests CE02SHSP CTD data that was recovered from the profiler for the OOI lifespan (excluded parameters use defaults).
#' url = ooi_create_url(site = 'CE05MOAS',node = 'GL382',instrument = 'DO',method = 'telemetered',start_date = '2019-01-10',stop_date = '2019-01-31') #Requests EA Glider 382 DO data that was telemetered from the glider for the first month of 2019.
#' urls = ooi_create_url(site = 'CE') #This would return all assets within the Endurance Array.


ooi_create_url <- function(site = "",node = "",instrument = "",method = "",stream = "",start_date = '2010-01-01',start_time = '00:00:00',stop_date = '2040-12-31',stop_time = '23:59:59'){
  lookup <- read.csv("https://raw.githubusercontent.com/IanTBlack/OOIM2M_R/master/OOI_M2M_Science_Curated.csv",header=TRUE)  #Read in the curated CSV.
  lookup <- lookup[grep(toupper(site),lookup[,'SITE']),]  #Drop rows that don't have the user-defined site.

  if (nchar(node) <= 5){  #If the user enters five characters, assume it is a specific node.
    lookup <- lookup[grep(toupper(node),lookup[,'NODE']),]  #Drop rows that don't have the user-defined node.
  }
  else if(nchar(node) >= 6){  #If it is greater than six characters, assume they are using the simplified node name.
    lookup <- lookup[grep(toupper(node),lookup[,'SIMPLENODE']),] #Drop based on the simple node.
  } else{
    cat("Please enter a node ID or keyword.")
  }

  lookup <- lookup[grep(toupper(instrument),lookup[,'INSTRUMENT']),] #Drop rows that don't match in the user specified instrument.
  lookup <- lookup[grep(tolower(method),lookup[,'METHOD']),] #Drop rows that don't match in the user specified method.

  if (nrow(lookup) == 1){  #If there is only one entry.
    url = lookup$URL  #That's probably the URL we want.
    window = sprintf('?beginDT=%sT%s.000Z&endDT=%sT%s.999Z',start_date,start_time,stop_date,stop_time)
    url = sprintf('%s%s',url,window)  #Combine the url and time window string.
    cat('Here is the request URL generated from the information you provided.\n')
    cat(url,'\n')
    return(url)
    }
  else if(nrow(lookup) > 1 && stream==""){  #If there is more than one row and the user didn't specify a stream.
    cat('More than one (1) possible URL returned from the lookup table.\n')  #Issue the following.
    cat(paste('If you only want one instrument and stream, please review possible methods and streams and specify through the function',"'",'s method or stream parameter.\n',sep = ""))
    url = lookup$URL
    window = sprintf('?beginDT=%sT%s.000Z&endDT=%sT%s.999Z',start_date,start_time,stop_date,stop_time)
    url = paste(url,window,sep = "")  #Combine the url and time window string.
    print(url)
    return(url)
    }
  else if(nrow(lookup) > 1 && stream!=""){  #If they did specify a stream...
    lookup <- lookup[grep(tolower(stream),lookup[,'STREAM']),]
    if (nrow(lookup) == 0){
      cat('Looks like the stream you input does not work with the site, node, instrument, or method you specified.')
      return()
    }
    else{
      url = lookup$URL
      window = sprintf('?beginDT=%sT%s.000Z&endDT=%sT%s.999Z',start_date,start_time,stop_date,stop_time)
      url = paste(url,window,sep = "")  #Combine the url and time window string.
      cat('Here is the request URL generated from the information you provided.\n')
      cat(url,'\n')
      return(url)}
    }
  else{
      cat('The lookup table couldn\'t generate a request URL from your inputs.\n')
      return()
      }  #End of confusing elif ladder.
}  #End of function.
