library(CytoscapeDonorCluster)

data <- read.table("RID2261405.txt",sep="\t",header=T,stringsAsFactors = F)
PERCENTILE <- 0.1 ###what percentile of data to keep
ndonor <- nrow(data)
Kernel_matrix <- matrix(nrow=ndonor,ncol=ndonor)
for( i in 1:ndonor){
  for (j in i:ndonor){
    util_diff <-  abs(data$UtilityScore[i]-data$UtilityScore[j])
    Kernel_matrix[i,j] <- util_diff
  }
}
diag(Kernel_matrix)<-NA #ignore self-difference


dist <- unlist(Kernel_matrix)
CDF <- ecdf(dist)
threshold <- quantile(CDF,probs=PERCENTILE)
hist(dist,breaks=200,main="Kernel Distance Scores")
abline(v=threshold,lwd=2,lty=2)

Kernel_matrix[Kernel_matrix>=threshold] <- NA

inds <- which(!is.na(Kernel_matrix),arr.ind = T)
value <- Kernel_matrix[inds]

network<-data.frame(data$NMDP_DID[inds[,1]],
                    value,data$NMDP_DID[inds[,2]])
colnames(network) <- c("source", "interaction", "target")

network <- network[order(network$interaction,decreasing = F),]###sort by strength
edgeList <- network[, c("source","target")]
nodes <- unique(c(edgeList$source, edgeList$target))
id <- nodes
name <- nodes
nodeData <- data.frame(id, name, stringsAsFactors=FALSE)
nodeData$color <- rep("#888888", nrow(nodeData))
nodeData$color[which(grepl("[a-z]", nodes))] <- "#FF0000"
nodeData$shape <- rep("ellipse", nrow(nodeData))
nodeData$shape[which(grepl("[a-z]", nodes))] <- "octagon"
edgeData <- edgeList
cyNetwork <- createCytoscapeNetwork(nodeData, edgeData)
UtilityNetwork(nodeEntries=cyNetwork$nodes, edgeEntries=cyNetwork$edges,
               layout="cola",width = NULL, height = NULL)
