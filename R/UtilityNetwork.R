#' <Add Title>
#'
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export
UtilityNetwork <- function(message, width = NULL, height = NULL) {

  # forward options using x
  x = list(
    message = message
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'UtilityNetwork',
    x,
    width = width,
    height = height,
    package = 'CytoscapeDonorCluster'
  )
}

#' Widget output function for use in Shiny
#'
#' @export
UtilityNetworkOutput <- function(outputId, width = '100%', height = '400px'){
  shinyWidgetOutput(outputId, 'UtilityNetwork', width, height, package = 'CytoscapeDonorCluster')
}

#' Widget render function for use in Shiny
#'
#' @export
renderUtilityNetwork <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, UtilityNetworkOutput, env, quoted = TRUE)
}
