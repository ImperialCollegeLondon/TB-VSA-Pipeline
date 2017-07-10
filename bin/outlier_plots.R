#!/bin/env Rscript

library(ggplot2)
library(grid)
library(gridExtra)
library(getopt)

# Argument handling....
spec = matrix(c(
	'help' , 'h', 0, "logical",
	'data' , 'd', 1, "character",
	'reflength' , 'l', 1, "double",
	'projid', 'p', '1', "character"
), byrow=TRUE, ncol=4);
opt = getopt(spec);

if ( !is.null(opt$help) ) {
	cat(getopt(spec, usage=TRUE));
	q(status=1);
}

if ( is.null(opt$data) ) {
	cat("path to data file (-d) is a required argument\n");
	q(status=1);
}

if ( is.null(opt$reflength) ) {
	cat("reflength (-l) is a required argument\n");
	q(status=1);
}

if ( is.null(opt$projid) ) {
	cat("projid (-p) is a required argument\n");
	q(status=1);
}

# table should be in format "SampleID	Reads	ReadLength	SNVs	MappingRate"
dat=read.table(opt$data,header=TRUE);

#Calculate threshold for calling outliers in SNV counts 3x the interquartile range + the upper quartile...
lowerq = quantile(dat$SNVs)[2]
upperq = quantile(dat$SNVs)[4]
iqr = upperq - lowerq 
outliers=(iqr*3)+upperq

# Calculate no. reads required to provide 1x coverage
readlength=mean(dat$ReadLength)
read_cov1x=opt$reflength/(readlength*2)

p<-ggplot(dat,aes(x=Reads,y=SNVs,col=ifelse((SNVs>outliers|Reads<read_cov1x*20),"red","blue")))
p = p + theme_light()
p = p + ggtitle(paste (opt$projid, " SNV/Read count distribution",sep=""),)
p = p + geom_point(size=1)
p = p + geom_text(data=subset(dat,SNVs>outliers|Reads<read_cov1x*20),aes(label=Sample),size=2,hjust=-0.1,angle=45)
p = p + scale_x_continuous(expand = c(.1, 0.5))
p = p + scale_y_continuous(expand = c(.1, 0.5))
p = p + annotate("text", label = '20x Coverage', x=read_cov1x*20, y = Inf, colour="springgreen4",size=2,vjust = -3)
p = p + annotate("segment", x=read_cov1x*20,  xend=read_cov1x*20, y=0, yend=Inf, colour="springgreen4",linetype="dotted") 
p = p + theme(
	legend.position="none",
	plot.margin=unit(c(5,5,1,1),"lines"),
	plot.title=element_text(size=12,hjust=0.5,vjust=100)
)

# Plot mapping rates
gt <- ggplot_gtable(ggplot_build(p))
gt$layout$clip[gt$layout$name == "panel"] <- "off"
plot_file = paste(opt$projid, "_snv_dist.pdf",sep="");
ggsave(filename=plot_file,width=150,height=150,units="mm",plot=gt)

p<-ggplot(dat,aes(x=Sample,y=MappingRate,col=ifelse((MappingRate<90),"red","blue")))
p = p + theme_light()
p = p + ggtitle(paste (opt$projid, " mapping rates",sep=""),)
p = p + geom_point(size=1)
p = p + geom_text(data=subset(dat,MappingRate<90),aes(label=Sample),size=2,hjust=-0.1,angle=-45)
p = p + scale_x_discrete(expand = waiver())
p = p + scale_y_continuous(limits=c(0,100),expand = c(.1, 0.5))
p = p + labs(x="Samples")
p = p + annotate("text", label = '90% cutoff', x=0, y = 93, hjust=-0.2, colour="springgreen4",size=2)
p = p + annotate("segment", x=0,  xend=Inf, y=90, yend=90, colour="springgreen4",linetype="dotted") 
p = p + theme(
	legend.position="none",
	plot.margin=unit(c(5,5,1,1),"lines"),
	plot.title=element_text(size=12,hjust=0.5,vjust=100),
	axis.text.x=element_blank(),
	axis.ticks.x=element_blank(),
)

gt <- ggplot_gtable(ggplot_build(p))
gt$layout$clip[gt$layout$name == "panel"] <- "off"
plot_file = paste(opt$projid, "_mapping_rate.pdf",sep="");
ggsave(filename=plot_file,width=150,height=150,units="mm",plot=gt)

unlink("Rplots.pdf") ##ggplot wierdness supposedly fixed in recent versions leaves empty Rplots.pdf files lying round...

read_cov_outliers <- dat[dat$Reads<read_cov1x*20,]
SNV_outliers <- dat[dat$SNVs>outliers,]
mapping_outliers <- dat[dat$MappingRate<90,]

outlying_samples <- list()
outlying_samples <- unique(c(as.character(read_cov_outliers$Sample),as.character(SNV_outliers$Sample),as.character(mapping_outliers$Sample)))
outlier_file = paste(opt$projid, "_outliers.txt",sep="");
unlink(outlier_file) #so we don't append to an existing file...
lapply(outlying_samples, write, outlier_file, append=TRUE, ncolumns=1)


