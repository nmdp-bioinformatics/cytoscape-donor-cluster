library(shiny)
if(!require(CytoscapeDonorCluster))
  devtools::install_github("albre116/CytoscapeDonorCluster")
library(dplyr)
library(shinydashboard)
library(data.table)
if(!require(parcoords))
devtools::install_github("albre116/parcoords")

options(shiny.maxRequestSize=500*1024^2)###500 megabyte file upload limit set


flag<<-0 ##global variable to set for brush initilization
shinyServer(function(input, output, session) {

  DATA <- reactive({
    inFile <- input$dataset
    if (is.null(inFile))
      return(NULL)
    data <- read.table(inFile$datapath,sep="\t",header=T,stringsAsFactors=TRUE)
    data <- as.data.frame(data)
    data <- data[,c("UtilityScore","NMDP_DID","X10OF10","DNR_AGE",
                    "DNR_SEX","DNR_BLOOD_TYPE","DNR_RH_TYPE","DNR_WT",
                    "DC_CDE")]
    return(list(data=data))
  })

  BRUSHDATA <- reactive({
    data <- DATA()[["data"]]
    if(is.null(data)){return(NULL)}
    data <- data[,c("UtilityScore","X10OF10","DNR_AGE","DNR_WT",
                    "DNR_SEX","DNR_BLOOD_TYPE","DNR_RH_TYPE",
                    "DC_CDE")]
    data$DNR_WT[is.na(data$DNR_WT)] <- 0 ###parcoords cannot handle NA fields
    return(list(data=data))
  })

  output$DataBrush <- renderParcoords({
    data <- BRUSHDATA()[["data"]]
    if(is.null(data)){return(NULL)}
    parcoords(data,rownames=F, brushMode = input$brushType,reorderable = T)
  })

  KEPTDATA <- reactive({
    data <- DATA()[["data"]]
    ids <- rownames(data) %in% input$DataBrush_brushed_row_names
    if(!is.null(input$DataBrush_brushed_row_names)){flag<<-1}#trigger first pass through
    if(flag==1){data <- data[ids,]}
    return(list(data=data))
  })

  output$selectedData <- renderDataTable({
    data <- KEPTDATA()[["data"]]
    return(data)
  })

  output$donorsSelected <- renderText({
    all <- nrow(DATA()[["data"]])
    select <- nrow(KEPTDATA()[["data"]])
    if(is.null(all) | is.null(select)){return(NULL)}
    return(paste(select,"of",all,"donors selected"))
  })





  DATACUT <- reactive({
    data <- KEPTDATA()[["data"]]
    return(list(data=data))
  })


  KernelMatrix <- reactive({
    data <- DATACUT()[["data"]]
    if(is.null(data)){return(NULL)}
    ndonor <- nrow(data)
    Kernel_matrix <- matrix(nrow=ndonor,ncol=ndonor)
    for( i in 1:ndonor){
      for (j in i:ndonor){
        util_diff <-  abs(data$UtilityScore[i]-data$UtilityScore[j])
        Kernel_matrix[i,j] <- util_diff
      }
    }
    diag(Kernel_matrix)<-NA #ignore self-difference
    return(list(Kernel_matrix=Kernel_matrix))
  })


  KernelThresholded <- reactive({
    PERCENTILE <- input$percentile ###what percentile of data to keep
    Kernel_matrix <- KernelMatrix()[["Kernel_matrix"]]
    if(is.null(Kernel_matrix)){return(NULL)}
    dist <- unlist(Kernel_matrix)
    CDF <- ecdf(dist)
    threshold <- quantile(CDF,probs=PERCENTILE)
    Kernel_matrix[Kernel_matrix>=threshold] <- NA
    return(list(Kernel_matrix=Kernel_matrix,dist=dist,threshold=threshold))
  })

  output$ThresholdPlot <- renderPlot(function(){
    Kernel_matrix <- KernelThresholded()[["Kernel_matrix"]]
    if(is.null(Kernel_matrix)){return(NULL)}
    dist<- KernelThresholded()[["dist"]]
    threshold<- KernelThresholded()[["threshold"]]
    hist(dist,breaks=200,main="Kernel Distance Scores")
    abline(v=threshold,lwd=2,lty=2)
  })


  SVMNetwork <- reactive({
    data <- DATACUT()[["data"]]
    if(is.null(data)){return(NULL)}
    Kernel_matrix <- KernelThresholded()[["Kernel_matrix"]]
    inds <- which(!is.na(Kernel_matrix),arr.ind = T)
    value <- Kernel_matrix[inds]
    network<-data.frame(data$NMDP_DID[inds[,1]],
                        value,data$NMDP_DID[inds[,2]])
    colnames(network) <- c("source", "interaction", "target")
    network <- network[order(network$interaction,decreasing = F),]###sort by strength
    edgeList <- network[, c("source","target")]
    nodes <- unique(data$NMDP_DID)
    id <- nodes
    nodeData <- data.frame(id, stringsAsFactors=FALSE)
    joinProperties <- data.frame(id=data$NMDP_DID,
                                 color=gray(1-scale_var(var=data$UtilityScore,interval=c(0.1,1))),
                                 name=round(data$UtilityScore,2),
                                 href=paste("<table>",
                                            "<tr>",
                                            "<td>", "10 of 10 Match(%):" ,"</td>",
                                            "<td>",data$X10OF10,"</td>",
                                            "</tr>",
                                            "<tr>",
                                                "<td>", "Age:" ,"</td>",
                                                "<td>",data$DNR_AGE,"</td>",
                                            "</tr>",
                                            "<tr>",
                                            "<td>", "Sex:" ,"</td>",
                                            "<td>",data$DNR_SEX,"</td>",
                                            "</tr>",
                                            "<tr>",
                                            "<td>", "Blood Type:" ,"</td>",
                                            "<td>",data$DNR_BLOOD_TYPE,"</td>",
                                            "</tr>",
                                            "<tr>",
                                            "<td>", "Rh Type:" ,"</td>",
                                            "<td>",data$DNR_RH_TYPE,"</td>",
                                            "</tr>",
                                            "<tr>",
                                            "<td>", "Weight (Kg):" ,"</td>",
                                            "<td>",data$DNR_WT,"</td>",
                                            "</tr>",
                                            "<tr>",
                                            "<td>", "Donor Ctr:" ,"</td>",
                                            "<td>",data$DC_CDE,"</td>",
                                            "</tr>",
                                            "</table>"))

    nodeData <- nodeData %>%
      inner_join(joinProperties)
    nodeData$shape <- rep("ellipse", nrow(nodeData))
    nodeData$shape[which(grepl("[a-z]", nodes))] <- "octagon"
    edgeData <- edgeList
    cyNetwork <- createCytoscapeNetwork(nodeData, edgeData)
    return(list(cyNetwork=cyNetwork))
  })


  output$Chart <- renderUtilityNetwork({
    cyNetwork <- SVMNetwork()[["cyNetwork"]]
    if(is.null(cyNetwork)){return(NULL)}
    UtilityNetwork(nodeEntries=cyNetwork$nodes, edgeEntries=cyNetwork$edges)
  })

  DATATABLE <- reactive({
    id <- input$Chart_click_node
    id <- as.numeric(id)
    data <- DATACUT()[["data"]]
    out <- filter(data,NMDP_DID %in% id)
    return(out)
  })


  output$DID <- renderDataTable(
    DATATABLE(),
    options=list(scrollX=TRUE)
  )

})
