library(shiny)
library(CytoscapeDonorCluster)

shinyUI(fluidPage(
    fluidRow(
      UtilityNetworkOutput("Chart")

    )
))
