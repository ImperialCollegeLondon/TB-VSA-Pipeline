#!/bin/env Rscript

#TODO - calulate coverage from read lengths - add parsing 
#TODO - add labels to low coverage samples

library(ggplot2)

args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
	stop ("An input file must be provided (output of count_reads_snvs)",call.=FALSE)
} 

dat=read.table(args[1],header=TRUE);

lowerq = quantile(dat$SNVs)[2]
upperq = quantile(dat$SNVs)[4]
iqr = upperq - lowerq 
outliers=(iqr*3)+upperq

# 1x coverage of TB is 17600 x 125bp reads, so aim for 10x = 176000 reads

ggplot(dat,aes(x=Reads,y=SNVs,col=ifelse((SNVs>outliers),"red","black"))
	)+geom_point(size=1)+geom_text(data=subset(dat,SNVs>outliers),aes(label=Sample),size=2,hjust=-0.1)+theme(legend.position="none")+geom_vline(xintercept=176000,linetype="dotted",colour="blue")

#ggplot(dat,aes(x=Reads,y=SNVs,col=ifelse((SNVs>outliers),"red",ifelse((Reads<176000),"green", "black"))))+geom_point(size=1)+geom_text(data=subset(dat,SNVs>outliers),aes(label=Sample),size=2,hjust=-0.1)+theme(legend.position="none")
	
