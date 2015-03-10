library(shiny)
library(CytoscapeDonorCluster)
library(dplyr)
library(shinydashboard)
library(data.table)



shinyServer(function(input, output, session) {

  DATA <- reactive({
    inFile <- input$dataset
    if (is.null(inFile))
      return(NULL)
    data <- fread(inFile$datapath,sep="\t",header=T,stringsAsFactors = F)
    data <- as.data.frame(data)
    return(list(data=data))
  })

  output$UtilityRange <- renderUI({
    data <- DATA()[["data"]]
    min <- min(data$UtilityScore)
    max <- max(data$UtilityScore)
    sliderInput("UtilityRange","Utility Range to View",min=min,max=max,value=c(min,max))
  })

  output$UtilityCut <- renderPlot(function(){
    data <- DATA()[["data"]]
    if(is.null(data)){return(NULL)}
    hist(data$UtilityScore,breaks=200,main="Donor Utility Scores")
    abline(v=input$UtilityRange[1],lwd=2,lty=2)
    abline(v=input$UtilityRange[2],lwd=2,lty=2)
  })


  DATACUT <- reactive({
    data <- DATA()[["data"]]
    if(is.null(data)){return(NULL)}
    data <- data  %>% filter(UtilityScore >=input$UtilityRange[1],
                             UtilityScore <=input$UtilityRange[2])
    data <- as.data.frame(data)
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
    nodes <- unique(c(edgeList$source, edgeList$target))
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


})
