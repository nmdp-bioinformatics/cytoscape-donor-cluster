library(shiny)
library(CytoscapeDonorCluster)
library(dplyr)
library(shinydashboard)



shinyServer(function(input, output, session) {

  DATA <- reactive({
    setwd("~/CytoscapeDonorCluster/inst/examples/shiny")
    data <- read.table("../../../RID2261405.txt",sep="\t",header=T,stringsAsFactors = F)
    return(list(data=data))
  })


  KernelMatrix <- reactive({
    data <- DATA()[["data"]]
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
    dist <- unlist(Kernel_matrix)
    CDF <- ecdf(dist)
    threshold <- quantile(CDF,probs=PERCENTILE)
    Kernel_matrix[Kernel_matrix>=threshold] <- NA
    return(list(Kernel_matrix=Kernel_matrix,dist=dist,threshold=threshold))
  })

  output$ThresholdPlot <- renderPlot(function(){
    Kernel_matrix <- KernelThresholded()[["Kernel_matrix"]]
    dist<- KernelThresholded()[["dist"]]
    threshold<- KernelThresholded()[["threshold"]]
    hist(dist,breaks=200,main="Kernel Distance Scores")
    abline(v=threshold,lwd=2,lty=2)
  })


  SVMNetwork <- reactive({
    data <- DATA()[["data"]]
    Kernel_matrix <- KernelThresholded()[["Kernel_matrix"]]
    inds <- which(!is.na(Kernel_matrix),arr.ind = T)
    value <- Kernel_matrix[inds]
    network<-data.frame(data$NMDP_DID[inds[,1]],
                        value,data$NMDP_DID[inds[,2]])
    colnames(network) <- c("source", "interaction", "target")
    network <- network[order(network$interaction,decreasing = F),]###sort by strength
    edgeList <- network[, c("source","target")]
    nodes <- unique(c(edgeList$source, edgeList$target))
    id <- nodes
    nodeData <- data.frame(id, stringsAsFactors=FALSE)
    joinProperties <- data.frame(id=data$NMDP_DID,
                                 color=gray(1-scale_var(var=data$UtilityScore,interval=c(0.1,1))),
                                 name=round(data$UtilityScore,2))

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
    UtilityNetwork(nodeEntries=cyNetwork$nodes, edgeEntries=cyNetwork$edges)
  })


})
