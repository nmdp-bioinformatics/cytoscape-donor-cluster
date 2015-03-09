#' Generate a CytoscapeJS compatible network
#'
#' @param nodeData a data.frame with at least two columns: id and name
#' @param edgeData a data.frame with at least two columns: source and target
#' @param nodeColor a hex color for nodes (default: #666666)
#' @param nodeShape a shape for nodes (default: ellipse)
#' @param edgeColor a hex color for edges (default: #666666)
#' @param edgeSourceShape a shape for arrow sources (default: none)
#' @param edgeTargetShape a shape for arrow targets (default: triangle)
#'
#' @return a list with two entries:
#'   nodes: a JSON string with node information compatible with CytoscapeJS
#'   edges: a JSON string with edge information compatible with CytoscapeJS
#'
#'   If no nodes exist, then NULL is returned
#'
#' @details See http://cytoscape.github.io/cytoscape.js/ for shape details
#'
#' @examples
#' id <- c("Jerry", "Elaine", "Kramer", "George")
#' name <- id
#' nodeData <- data.frame(id, name, stringsAsFactors=FALSE)
#'
#' source <- c("Jerry", "Jerry", "Jerry", "Elaine", "Elaine", "Kramer", "Kramer", "Kramer", "George")
#' target <- c("Elaine", "Kramer", "George", "Jerry", "Kramer", "Jerry", "Elaine", "George", "Jerry")
#' edgeData <- data.frame(source, target, stringsAsFactors=FALSE)
#'
#' network <- createCytoscapeNetwork(nodeData, edgeData)
#' @export
createCytoscapeNetwork <- function(nodeData, edgeData,
                                   nodeColor="#888888", nodeShape="ellipse",
                                   edgeColor="#888888", edgeSourceShape="none",
                                   edgeTargetShape="triangle", nodeHref="") {

  # There must be nodes and nodeData must have at least id and name columns
  if(nrow(nodeData) == 0 || !(all(c("id", "name") %in% names(nodeData)))) {
    return(NULL)
  }

  # There must be edges and edgeData must have at least source and target columns
  if(nrow(edgeData) == 0 || !(all(c("source", "target") %in% names(edgeData)))) {
    return(NULL)
  }

  # NODES
  ## Add color/shape columns if not present
  if(!("color" %in% colnames(nodeData))) {
    nodeData$color <- rep(nodeColor, nrow(nodeData))
  }

  if(!("shape" %in% colnames(nodeData))) {
    nodeData$shape <- rep(nodeShape, nrow(nodeData))
  }

  if(!("href" %in% colnames(nodeData))) {
    nodeData$href <- rep(nodeHref, nrow(nodeData))
  }

  rownames(nodeData) <- NULL
    nodeEntries <- apply(nodeData,1,function(x){
      list(data=as.list(x))
    })



  # EDGES
  ## Add color/shape columns if not present
  if(!("color" %in% colnames(edgeData))) {
    edgeData$color <- rep(edgeColor, nrow(edgeData))
  }

  if(!("sourceShape" %in% colnames(edgeData))) {
    edgeData$edgeSourceShape <- rep(edgeSourceShape, nrow(edgeData))
  }

  if(!("targetShape" %in% colnames(edgeData))) {
    edgeData$edgeTargetShape <- rep(edgeTargetShape, nrow(edgeData))
  }

  rownames(edgeData) <- NULL
  edgeEntries <- apply(edgeData,1,function(x){
    list(data=as.list(x))
  })


  network <- list(nodes=nodeEntries, edges=edgeEntries)

  return(network)
}

#' <Add Title>
#'
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export
UtilityNetwork <- function(nodeEntries, edgeEntries, layout="cola",width = NULL, height = NULL) {
  # forward options using x
  x = list()
  x$nodeEntries <- nodeEntries
  x$edgeEntries <- edgeEntries
  x$layout <- layout

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
