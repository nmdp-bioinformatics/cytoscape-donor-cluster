library(shiny)
if(!require(CytoscapeDonorCluster))
  devtools::install_github("albre116/CytoscapeDonorCluster")
library(dplyr)
library(shinydashboard)
library(data.table)
if(!require(parcoords))
  devtools::install_github("albre116/parcoords")

header <- dashboardHeader(title = "SVM Network")

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Parallel Coords",tabName="Brush",icon = icon("fa fa-car")),
    menuItem("Kernel Settings",tabName="Kernel",icon = icon("dashboard")),
    menuItem("Network Diagram",tabName="Network",icon = icon("th"))
  ),
  fileInput("dataset","Pick SVM Dataset")
)

body <- dashboardBody(
  tabItems(
    #first tab content
    tabItem(tabName="Brush",
            box(status = "primary",title = "Parallel Coordinates with Brush Select", solidHeader = TRUE, width = NULL,collapsible = T,
                fluidRow(
                  column(width=12,
                         parcoordsOutput("DataBrush")
                  )
                )
            ),###end box content
            box(status = "primary",title = "Brush Selected Data", solidHeader = TRUE, width = NULL,collapsible = T,
                fluidRow(
                  column(width=12,
                         dataTableOutput("selectedData")
                  )
                )
            )###end box content
    ),
    tabItem(tabName="Kernel",
            box(status = "primary",title = "Utility Threshold", solidHeader = TRUE, width = NULL,collapsible = T,
                fluidRow(
                  column(width=3,
                         uiOutput("UtilityRange")
                         ),
                  column(width=9,
                         plotOutput("UtilityCut")
                         )
                  )
            ),###end box content
            box(status = "primary",title = "Kernel Settings", solidHeader = TRUE, width = NULL,collapsible = T,
                fluidRow(
                  column(width=3,
                         sliderInput("percentile","Percentile of Edges to Retain",
                                     min=0,max=1,value=0.1)
                  ),
                  column(width=9,
                         plotOutput("ThresholdPlot")
                  )
                )
            )###end box content
    ),
    #second tab content
    tabItem(tabName="Network",
            box(status = "primary",title = "Network Diagram", solidHeader = TRUE, width = NULL,collapsible = T,
                UtilityNetworkOutput("Chart",height="600px")
            ),###end box
            box(status = "primary",title = "Selected Donors", solidHeader = TRUE, width = NULL,collapsible = T,
                dataTableOutput("DID")
            )###end box
    )
  )###end all tab items
)

dashboardPage(header,sidebar,body)

