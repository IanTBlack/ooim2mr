#' Possible OOI Science Data Request Combinations
#'
#' A data frame that allows the user to obtain a request URL given inputs into the ooi_create_url() function.
#' The ooi_get_data() function also uses this table if the user sets the simplify_data flag to TRUE.
#'
#' This dataset was built using the Python and R scripts found under data-raw/lookup_generator.
#'
#' @format A data frame with columns: SITE, NODE, INSTRUMENT, METHOD, STREAM, URL, NCVARS, VARS_UNITS, VARS_DISPLAY_NAME, VARS_DESCRIPTION, SIMPLENODE.
#' \describe{
#' \item{SITE}{An eight (8) character OOI site designator.}
#' \item{NODE}{A five (5) character OOI node designator.}
#' \item{INSTRUMENT}{A twelve (12) character OOI instrument designator. Character 3 is always a dash (-).}
#' \item{METHOD}{A designator for data delivery method. Options: telemetered, recovered_inst, recovered_host, recovered_cspp, recovered_wfp, streamed}
#' \item{STREAM}{A designator for the datatype/data product.}
#' \item{URL}{A partially built URL for data requests.}
#' \item{NCVARS}{A cleaned up set of variables for the given site, node, instrument, and stream. Pipe delimited.}
#' \item{VARS_UNITS}{Units to match NCVARS. Pipe delimited.}
#' \item{VARS_DISPLAY_NAME}{Common name of each variable matching NCVARS. Pipe delimited.}
#' \item{VARS_DESCRIPTION}{Description of each variable in NCVARS. Pipe delimited.}
#' \item{SIMPLENODE}{Simplified name for the given node.}
#' }
#'
#' @source \url{https://oceanobservatories.org/site-list/}
"ooi_science"
