#' Get a lists of lists of site information.
#'
#' @param site An eight (8) character designator for an OOI site.
#' @param user Your OOI API username.
#' @param token Your OOI API token.
#' @return A cascading list of lists. The first sublist layer consists of nodes. The layer in each node consists of the instruments connected to that node. Each layer under each instrument contains instrument metadata.
#' @examples
#' info = ooi_site_info(site = 'CE01ISSP', user = 'OOI-API-USERNAME-HERE', token = 'OOI-API-TOKEN-HERE')
#' info = ooi_site_info(site = 'CE05MOAS','OOI-API-USERNAME-HERE','OOI-API-TOKEN-HERE')

ooi_site_info <- function(site,user,token){
  base <- 'https://ooinet.oceanobservatories.org/api/m2m/'  #Base URL for OOI API requests.
  deploy <- '12587/events/deployment/inv/' #URL extensions.
  sensor <- '12576/sensor/inv/'
  annotation <- '12580/anno/'
  vocab <- '12586/vocab/inv/'
  site <- toupper(site)
  nr <- GET(sprintf('%s%s%s',base,vocab,site),authenticate(user,token))
  nodes <- fromJSON(content(nr,"text",encoding = "UTF-8"),flatten=TRUE)
  nodes_list <- list()
  node_names <- c()
  for (i in 1:length(nodes)){
    ir <- GET(sprintf('%s%s%s/%s',base,vocab,site,nodes[i]),authenticate(user,token))
    instruments <- fromJSON(content(ir,"text",encoding = "UTF-8"),flatten=TRUE)
    inst_list <- list()
    inst_names <- c()
    for (j in 1:length(instruments)){
      infor <- GET(sprintf('%s%s%s/%s/%s',base,vocab,site,nodes[i],instruments[j]),authenticate(user,token))
      info <- fromJSON(content(infor,"text",encoding = "UTF-8"),flatten=TRUE)
      if (length(info) !=0){
        order <- c('refdes','instrument','manufacturer','model','tocL1','tocL2','tocL3','mindepth','maxdepth')
        info <- info[,order]
        mooring_name <- sprintf('%s %s',info['tocL1'],info['tocL2'])
        node_name <- toString(info['tocL3'])
        inst_names <- c(inst_names,toString(info['instrument']))
        metar <- GET(sprintf('%s%s%s/%s/%s/metadata',base,sensor,site,nodes[i],instruments[j]),authenticate(user,token)) #Submit a request to get the number of deployments.
        metadata <- fromJSON(content(metar,"text",encoding = "UTF-8"),flatten=TRUE)
        streams_name <- unique(metadata$parameters$stream)
        streams <- list()
        for (k in 1:length(streams_name)){
          data <- metadata$parameters
          data <- data[data['stream']==streams_name[k],]
          params <- data[,c('particleKey','units','pdId','fillValue','type','shape','unsigned')]
          streams[k] <- list(params)
        }
        names(streams) <- streams_name
        streams_list <- list(streams)
        names(streams_list) <- 'streams'
        info_stream <- c(info,streams_list)
        inst_list[j] <- list(info_stream)
        } else {
        msg <- sprintf('No information associated with this instrument.')
        inst_list[j] = list(msg)
        break
        }
    }
    node_names <- c(node_names,node_name)
    names(inst_list) <- sprintf('%s: %s',inst_names,instruments)
    nodes_list[i] <- list(inst_list)
  }
  names(nodes_list) <- sprintf('%s: %s',node_names,nodes)
  return(nodes_list)
} #End of site for loop.
