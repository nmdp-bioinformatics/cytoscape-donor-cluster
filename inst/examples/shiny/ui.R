library(shiny)
library(CytoscapeDonorCluster)
library(shinydashboard)

header <- dashboardHeader(title = "SVM Network")

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Kernel Settings",tabName="Kernel",icon = icon("dashboard")),
    menuItem("Network Diagram",tabName="Network",icon = icon("th"))
  )
)

body <- dashboardBody(
  tabItems(
    #first tab content
    tabItem(tabName="Kernel",
            box(status = "primary",title = "Kernel Settings", solidHeader = TRUE, width = NULL,collapsible = F,
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
            box(status = "primary",title = "Network Diagram", solidHeader = TRUE, width = NULL,collapsible = F,
                UtilityNetworkOutput("Chart",height="700px")
            )###end box
    )
  )###end all tab items
)

dashboardPage(header,sidebar,body)
