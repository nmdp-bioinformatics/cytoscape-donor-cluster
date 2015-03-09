#' Generate a Scaled variable
#'
#' @param var a numeric object to be scaled
#' @param interval a numeric vector of the upper and lower limits for scaling
#'
#' @return a scaled variable
#'
#' @examples
#' var=1:100
#' out <- scale_var(var)
#' print(out)
#'
#' @export
scale_var <- function(var,interval=c(0,1)){
  r <- range(var)
  out <- (var-r[1])/diff(r)
  out <- interval[1]+out*diff(interval)
  return(out)
}
