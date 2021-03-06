#' US Highway Fatalities 2015
#'
#' A dataset containing the location and description of all reported traffic
#'   fatalities for calender year 2015:
#'
#' @format A .csv file with 32166 observations on 52 variables:
#' \describe{
#'   \item{STATE}{integer encoding for US state}
#'   \item{ST_CASE}{case number by state}
#'   \item{VE_TOTAL}{}
#'   \item{VE_FORMS}{}
#'   \item{PVH_INVL}{}
#'   \item{PEDS}{}
#'   \item{PERNOTMVIT}{}
#'   \item{PERMVIT}{}
#'   \item{PERSONS}{Number of people involved in accident}
#'   \item{COUNTY}{integer encoding of county}
#'   \item{CITY}{integer encoding of city, 0 if accident outside city boundaries}
#'   \item{DAY}{calendar day of accident}
#'   \item{MONTH}{integer encoding of month}
#'   \item{YEAR}{four-digit integer of year}
#'   \item{DAY_WEEK}{integer encoding of day of week}
#'   \item{HOUR}{hour recorded for accident}
#'   \item{MINUTE}{minute recorded for accident}
#'   \item{LATITUDE}{latitude in degrees of accident location}
#'   \item{LONGITUDE}{longitude in degrees of accident location}
#' }
"accident_2015"
