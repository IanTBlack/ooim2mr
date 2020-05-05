#' Submit data request to OOINet.
#'
#' @param url The request URL generated through the ooi_create_url() function, or as a  string input by the user.
#' @param user The username made available through an OOINet account, entered as a string.
#' @param token The token made available through an OOINet account, entered as a string.
#' @return A JSON response object is returned if the request is successful. If it is not successful, nothing is returned and a message with the status code is printed.
#' @examples
#' url = "https://ooinet.oceanobservatories.org/api/m2m/12576/sensor/inv/CE05MOAS/GL382/04-DOSTAM000/telemetered/dosta_abcdjm_glider_instrument?beginDT=2019-01-10T00:00:00.000Z&endDT=2019-01-31T23:59:59.999Z"
#' response = ooi_submit_request(url,user = 'OOI-API-USERNAME-HERE',token = 'OOI-API-TOKEN-HERE')

ooi_submit_request <- function(url,user,token){
  require(httr)   #The httr package is required for this function to work.
  require(crayon)
  response = GET(url,authenticate(user,token))  #Submit a request to the url created via ooi_create_url().
  status = content(response,"parsed")$message$status
  code = status_code(response)  #Get the response code.
  cat(sprintf('Request issued at %s.\n',response$date))  #Print the time the request was made.
  if (code == 200){  #If the status code is 200...
    cat(green('Request successful (200).\n'))
    return(response)  #...return the response object.
  }
  else if(code == 400){  #If the status code is 400...
    cat(red('Bad request (400).\n'))
    cat(red(status))
  }
  else if(code == 404){  #If the status code is 404...
    cat(red('Not found (404).\n'))
    cat(red(status))
  }
  else {
    cat(yellow(sprintf('Unanticipated error code (%s).', code)))  #If the status code is not one of the above three, link to other possible codes.
    cat(yellow(status))
    cat(yellow('List of codes here: https://github.com/psf/requests/blob/master/requests/status_codes.py'))
  }  #End of elif ladder.
} #End of function.
