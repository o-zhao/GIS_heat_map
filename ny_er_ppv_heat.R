# Medicaid inpatient/ER admissions and PPV (potentially preventable emerg visits)
# ZIP granularity heat map

# last edited 20 Dec 2016 (ozhao)

setwd()

# map and shape files
library(maptools)
library(colorspace)
state.map <- readShapeSpatial("tl_2010_36_state10_ny/tl_2010_36_state10")
zip.map <- readShapeSpatial("tl_2010_36_zcta510_nyzcta/tl_2010_36_zcta510")

# data
erdat <- read.csv("NY_Medicaid_zip_beg2012.csv")
ppvdat <- read.csv("NY_PPV_zip_beg2011.csv")

# clean/merge
erdat <- subset(erdat, Year==2014)
erdat$Total.Admitted.Norm <- erdat$Total.Beneficiaries.Admitted/erdat$Total.Beneficiaries
erdat$Total.ER.Norm <- erdat$Total.Beneficiaries.ER/erdat$Total.Beneficiaries

ppvdat$Software.Version <- NULL
ppvdat <- subset(ppvdat, Discharge.Year==2014)
ppvdat <- subset(ppvdat, Patient.Zipcode!="Statewide")
ppvdat$Patient.Zipcode <- as.numeric(as.character(ppvdat$Pat))

dat <- merge(x = erdat, y = ppvdat, by.x = "Zip.Code", by.y = "Patient.Zipcode", all.x = T)

# summary stats
summary(dat)
summary(dat$Total.Beneficiaries.Admitted)
summary(dat$Total.Admitted.Norm)
summary(dat$Total.ER.Norm)

## color binning
dat$color <- 0
vec <- seq(0, 0.6, 0.05)
dat$color <- findInterval(dat$Total.ER.Norm, vec)

# attach color bins to map
temp <- zip.map@data
temp <- merge(temp, dat, by.x = "ZCTA5CE10", by.y = "Zip.Code", all.x = T, all.y = F)
zip.map@data <- temp

zip.map@data$color[is.na(zip.map@data$color)] <- 0

# zip.heat function
zip.heat <- function(zip.map,state.map,z,title=NULL,breaks=NULL,reverse=FALSE,cex.legend=1, bw=.2, col.vec=NULL, plot.legend=TRUE) {
  if (is.null(breaks)) {
    breaks=
      seq(
        floor(min(zip.map@data[,z],na.rm=TRUE)*10)/10
        ,
        ceiling(max(zip.map@data[,z],na.rm=TRUE)*10)/10
        ,1)
  }
  zip.map@data$ZCTA5CE10 <- cut(zip.map@data[,z], breaks, include.lowest=TRUE)
  cutpoints <- levels(zip.map@data$ZCTA5CE10)
  if (is.null(col.vec)) col.vec <- diverge_hsv(length(levels(zip.map@data$ZCTA5CE10))) # set color palette
  if (reverse) {
    cutpointsColors <- rev(col.vec)
  } else {
    cutpointsColors <- col.vec
  }
  levels(zip.map@data$ZCTA5CE10) <- cutpointsColors
  plot(zip.map, border=gray(0.4), lwd=bw, axes=FALSE, las=1, col=as.character(zip.map@data$ZCTA5CE10)) # set map aesthetics
  if (!is.null(state.map)) {
    plot(state.map, add=TRUE, lwd=1)
  }
  if (plot.legend) legend("bottomleft", cutpoints, fill=cutpointsColors, bty="n", title=title, cex=cex.legend)
}

# create heat map and save to file
labelpos <- data.frame(do.call(rbind, lapply(zip.map@polygons, function(x) x@labpt)))
names(labelpos) <- c("x", "y")
zip.map@data <- data.frame(zip.map@data, labelpos)

png(file = "ER_norm.png", width=3000, height=3000)
zip.heat(zip.map, state.map, z="color", plot.legend=F)
dev.off()


################################
