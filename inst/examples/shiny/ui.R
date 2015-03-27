
header <- dashboardHeader(title = "SVM Network")

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Parallel Coords",tabName="Brush",icon = icon("fa fa-car")),
    menuItem("Network Diagram",tabName="Network",icon = icon("th")),
    menuItem("Kernel Settings",tabName="Kernel",icon = icon("dashboard"))
  ),
  fileInput("dataset","Pick SVM Dataset"),
  selectInput("layout","Network Layout",choices=c("null","random","preset",
                                                  "grid","circle","concentric",
                                                  "breadthfirst","dagre","cose",
                                                  "cola","arbor","springy"),selected="cose")
)

body <- dashboardBody(
  tabItems(
    #first tab content
    tabItem(tabName="Brush",
            box(status = "primary",title = "Parallel Coordinates with Brush Select", solidHeader = TRUE, width = NULL,collapsible = T,
                fluidRow(
                  column(width=12,
                         h2(textOutput("donorsSelected")),
                         parcoordsOutput("DataBrush"),
                         selectInput("brushType","Select Brush Type",
                                     choices=c("1D-axes","2D-strums"),selected=c("1D-axes"))
                  )
                )
            ),###end box content
            box(status = "primary",title = "Brush Selected Data", solidHeader = TRUE, width = NULL,collapsible = T,
                fluidRow(
                  column(width=12,
                         DT::dataTableOutput("selectedData")
                  )
                )
            )###end box content
    ),
    tabItem(tabName="Kernel",
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
                DT::dataTableOutput("DID")
            )###end box
    )
  )###end all tab items
)

dashboardPage(header,sidebar,body)

