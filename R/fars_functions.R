
#' @title Read data file
#'
#' @description
#' Reads file with '.csv/.bz2' extensions into R workspace using readr library
#' and converts it to a data.frame using the \code{dplyr} \code{tbl_df} function.
#' If \code{file_name} not found function is stopped and "file does not exist"
#' warning is returned.
#'
#' @details
#' This is a helper function used with other FARS family functions in this
#' package. Specifically it is called in \code{\link{fars_read_years}},
#' \code{\link{fars_summarize_years}} and \code{\link{fars_map_state}}.
#'
#' @param filename File is .csv or .bz2 compressed file
#'
#' @importFrom readr read_csv
#' @import dplyr
#'
#' @seealso \code{\link{fars_read_years}} for reading and subsetting multiple FARS files into
#' a single data.frame
#'
#' @return If file name exists in current working directory, returns data.frame
#' class object. If file name not found, function stopped and "file does not exist"
#' warning returned.
#'


fars_read <- function(filename) {
        if(!file.exists(filename)){
          stop("file '", filename, "' does not exist")
          }
        d <- suppressMessages({
                readr::read_csv(filename, progress = FALSE)
        })
        return(d)
}


#'@title Create file name
#'
#'@description
#'Formats string file name to facilitate loading FARS files.
#'
#'
#'@details
#'Helper function used with other functions in this package, specifically
#'\code{\link{fars_read_years}}, \code{\link{fars_map_state}}.
#'
#'@param year An four-digit year to be assigned to
#'file name. Function accepts both integers and strings as it converts the
#'latter to an integer before assembling file name.
#'
#'@seealso
#'\code{fars_read} is called as a helper function in
#'\code{\link{fars_read_years}}, \code{\link{fars_map_state}}
#'
#'@return Returns a string in FARS format with \code{year} embedded. The file
#'name has .csv.bz2 file extensions.
#'


make_filename <- function(year) {
        year <- as.integer(year)
        f <- sprintf("accident_%d.csv.bz2", year)
        system.file("extdata", f, package="FARSfunctions")
}

#'@title Read multiple data files
#'
#'@description
#'Reads and binds into single data.frame all data files corresponding to values
#'in \code{years}. Dataframe reduced to variables \code{MONTH} and\code{year} before
#'being returned. Serves as pre-processing helper function for
#'\code{\link{fars_summarize_years}}.
#'
#'@details
#'If there is not a data file for any given year, "invalid year" warning will
#'be raised.
#'
#'@param years vector of four-digit years as integer or strings.
#'
#'@import dplyr
#'
#'@return
#'data.frame
#'

fars_read_years <- function(years) {
        lapply(years, function(year) {
                file <- make_filename(year)
                tryCatch({
                        dt <- fars_read(file)
                        dt <- dplyr::mutate(dt, year = as.integer(
                          as.character(year))
                          )
                        dt <- with(dt, dplyr::select(dt, MONTH, year))
                        return(dt)
                }, error = function(e) {
                        warning("invalid year: ", year)
                        return(NULL)
                })
        })
}

#'@title Summarize fatality counts by year
#'
#'@description
#'Reads and binds data files for each year in \code{years} into single data.frame
#'before summarizing fatality counts in a table with columns as years and rows
#'as months represented by integers using \code{link{fars_read_years}}
#'
#'@param years vector of four-digit years as integer or strings.
#'
#'@import dplyr
#'@import tidyr
#'@import magrittr
#'
#'@return
#'Data.frame of fatalities by month for all years in \code{years}
#'

#'@export
#'

fars_summarize_years <- function(years) {
        dat_list <- fars_read_years(years)
        dt <- dplyr::bind_rows(dat_list)
        grpd <- with(dt, dplyr::group_by(dt, year, MONTH))
        sum_stats <- with(grpd, dplyr::summarize(grpd, n = n()))
        results <- with(sum_stats, tidyr::spread(sum_stats, year, n))
        knitr::kable(results, align = 'c', caption = "Fatalities by Month")
}


#'@title Map FARS data by state
#'
#'@description
#'Geographically plots highway fatalities from FARS data, subset by \code{state.nm}
#'and \code{year} arguments.
#'
#'@details
#'If \code{state.num} not found in data, function stopped and "invalid STATE
#'number" error will be returned. If no data file exists for \code{year},
#'call to \code{fars_read} will return "file does not exist" error.
#'
#'If there are no fatalities for described subset, returns message "no accidents
#'to plot"
#'
#'If the given value for state.num is not a state in the dataset, a "invalid STATE"
#'error is raised.
#'
#'@param state.num Number encoding of state in FARS data. Argument can be input
#'as integer or string. More information including codebook can be found at
#'NHTSA website \url{https://www.nhtsa.gov/research-data}.
#'
#'@param year Four-digit year as integer or string of the data to be plotted.
#'
#'@importFrom dplyr filter
#'@importFrom maps map
#'@importFrom graphics points
#'
#'@return
#'NULL value
#'

#'@export
#'

fars_map_state <- function(state.num, year) {
        filename <- make_filename(year)
        dt <- fars_read(filename)
        state.num <- as.integer(state.num)

        if(!(state.num %in% unique(dt$STATE)))
                stop("invalid STATE number: ", state.num)
        dt.sub <- with(dt, dplyr::filter(dt, STATE == state.num))
        if(nrow(dt.sub) == 0L) {
                message("no accidents to plot")
                return(invisible(NULL))
        }
        is.na(dt.sub$LONGITUD) <- dt.sub$LONGITUD > 900
        is.na(dt.sub$LATITUDE) <- dt.sub$LATITUDE > 90
        with(dt.sub, {
                maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
                          xlim = range(LONGITUD, na.rm = TRUE))
                graphics::points(LONGITUD, LATITUDE, pch = 46)
        })
}

