#' Get deployment and annotation data associated with an OOI site, node, and instrument.
#'
#' @param site An eight (8) character designator for OOI sites.
#' @param node A five (5) character designator for OOI nodes. Alternatively, a simplified string for OOI sites that is greater than 5 characters. grep allows for use of substrings.
#' @param instrument A twelve (12) character designator for the OOI instrument on the associated site and node. grep allows for use of substrings.
#' @param user Your OOI API username.
#' @param token Your OOI API token.
#' @return A list of sublists. The deployments sublist offers start and stop deployments times for the given asset. The annotations sublists offers annotations for the given site,node, and instrument. Used together, a user can determine if data exists for the time period they are interested in.
#' @examples
#' availability = ooi_check_availability('CE01ISSM','SEAFLOOR','CTD','OOI-API-USERNAME-HERE','OOI-API-TOKEN-HERE')

ooi_check_availability <- function(site,node,instrument,user,token){
  lookup <- ooi_science
  lookup <- lookup[grep(toupper(site),lookup[,'SITE']),]  #Drop rows that don't have the user-defined site.
  if (nchar(node) <= 5){  #If the user enters five characters, assume it is a specific node.
    lookup <- lookup[grep(toupper(node),lookup[,'NODE']),]  #Drop rows that don't have the user-defined node.
  } else if(nchar(node) >= 6){  #If it is greater than six characters, assume they are using the simplified node name.
    lookup <- lookup[grep(toupper(node),lookup[,'SIMPLENODE']),] #Drop based on the simple node.
  }
  lookup <- lookup[grep(toupper(instrument),lookup[,'INSTRUMENT']),] #Drop rows that don't match in the user specified instrument.
  if (nrow(lookup) == 0){  #If there are no rows in the
    stop('Your inputs did not return a viable combination.')
  }

  s <- as.character(lookup['SITE'][1,1])  #Pull the site from the first row in the data.frame.
  n <- as.character(lookup['NODE'][1,1])  #Pull the node from the first row in the data.frame.
  inst <- as.character(lookup['INSTRUMENT'][1,1])  #Pull the instrument from the first row in the data.frame.

  base <- 'https://ooinet.oceanobservatories.org/api/m2m/'  #Base URL for OOI API requests.
  deploy <- '12587/events/deployment/inv/' #URL extensions.
  sensor <- '12576/sensor/inv/'
  annotation <- '12580/anno/'

  deployment_url <- sprintf('%s%s%s/%s/%s',base,deploy,s,n,inst)
  response <- GET(deployment_url,authenticate(user,token)) #Submit a request to get the number of deployments.
  num_deployments <- fromJSON(content(response,"text",encoding = "UTF-8"),flatten=TRUE) #Response content is the number of deployments.

  deployment_df <- c()  #Empty holder for data.
  for (i in 1:length(num_deployments)){  #For each deployment.
    num_i <- sprintf('%s/%s',deployment_url,num_deployments[i]) #Create a url to request deployment info.
    r <- GET(num_i,authenticate(user,token))  #Submit that request.
    deploy_info <- fromJSON(content(r,"text",encoding = "UTF-8"),flatten=TRUE) #Pull information from the response.
    deployment_start <- as.character(as.POSIXct(deploy_info['eventStartTime'][1,1]/1000,origin='1970-01-01'))  #Get the deployment start time and convert it to something understandable.
    deployment_stop <- as.character(as.POSIXct(deploy_info['eventStopTime'][1,1]/1000,origin='1970-01-01')) #Get the deployment stop time and convert it to something understandable.
    deployment_length_days <- as.Date(deployment_stop) - as.Date(deployment_start)  #Compute the length of deployment in days.
    deployment_number <- sprintf('%s',num_deployments[i]) #create a deployment identifier.
    binder <- cbind(deployment_number,deployment_start)  #Combine deployment number, start time, stop time, and deployment length into a row.
    binder1 <- cbind(binder,deployment_stop)
    binder2 <- cbind(binder1,deployment_length_days)
    deployment_df <- rbind(deployment_df,binder2)  #Concatenate multiple rows, where each subsequent row is the next deployment.
  }

  anno_start <- 0  # 1970-01-01
  anno_end <- 2240611199000 # 2040-12-31
  anno_url <- sprintf('%s%sfind?beginDT=%s&endDT=%s&refdes=%s-%s-%s',base,annotation,anno_start,anno_end,s,n,inst)
  anno_r <- GET(anno_url,authenticate(user,token)) #Submit a request to get the number of deployments.
  anno_info <- fromJSON(content(anno_r,"text",encoding = "UTF-8"),flatten=TRUE) #Response content is the number of deployments.
  if (length(anno_info)==0){
    anno_df <- 'No annotations found for your request.'
  } else{
      keeps <- c('subsite','node','sensor','method','parameters','beginDT','endDT','exclusionFlag','qcFlag','annotation')
      anno_df <- anno_info[,names(anno_info) %in% keeps]
      anno_df <- anno_df[,keeps]
      anno_df['beginDT'] <- as.character(as.POSIXct(anno_df[,'beginDT']/1000,origin = '1970-01-01'))
      anno_df['endDT'] <- as.character(as.POSIXct(anno_df[,'endDT']/1000,origin = '1970-01-01'))
  }
  combo <- list(deployment_df,anno_df)
  names(combo) <- c('deployments','annotations')
  return (combo)
}  #End of function.
