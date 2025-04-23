library(ggplot2)
library(sf)
library(dplyr)
library(leaflet)
library(factoextra)
library(dbscan)


#import csv airbnb dataset for customer segmentation
cptAirbnb<-read.csv("Airbnb Listings/listings/data/listings_cape_town.csv", header=TRUE, sep=",")

#import Capetown wards shapefile
capetownWards<-st_read("Capetown Wards/Wards.shp")


#rename WARD_NAME to match cptAIrbnb vairbale naming style
capetownWards <- capetownWards |> mutate (WARD_NAME = paste0("Ward ", WARD_NAME))


#transform the CRS to WGS84 (longitude/latitude)
capetown <- st_transform(capetownWards, crs = 4326)

#---EDA--------
#check didtribution of number of reviews
hist(cptAirbnb$number_of_reviews, breaks = 50) # right skewed. i.e. most values around 0

#get quantiles to see distribution of reviews
quantile(cptAirbnb$number_of_reviews, probs= seq(0,1, length.out=6), na.rm =TRUE)
#20%listings above 25 reviews with max = 536 reviews . 20% listings have 0 reviews
#---End of EDA------

#lets look at only the top listings
cptAirbnbTop <- cptAirbnb |> dplyr::filter(cptAirbnb$number_of_reviews >= 25) |> dplyr::select( name, number_of_reviews, price, longitude, latitude)

#To begin exploring data for clustering, check relationships between variables of interest to narrow it down
cptAirbnbTop |>
  dplyr::select(price, number_of_reviews) |>
  cor(use = "pairwise.complete.obs") |>
  round(2) #number of reviews has a slightly high negative effect on price


#scale the variables to normalize
airbnb_2cols<-scale(cptAirbnbTop[,c(2,3)])


#----EPS determination using elbow plot
#determine eps -reachability maximum distance of points in the data (determined with scaled airbnb2_cols)
dbscan::kNNdistplot(airbnb_2cols, k=5)
abline(h=0.4, lty=2) #optimal eps value is 0.4

dbscan_clusters<-dbscan::dbscan(airbnb_2cols, 0.4,4) #31 noise points/outliers detected

#visualize clusters, turns out theres only 3
fviz_cluster(dbscan_clusters, airbnb_2cols, geom="point")

#add cluster id to data
cptAirbnbTop$cluster_id<-dbscan_clusters$cluster


#get the price ranges  and review ranges of each cluster to get legend values

outlier_prange<-range(cptAirbnbTop$price[cptAirbnbTop$cluster_id == 0], na.rm = TRUE)
main_prange<-range(cptAirbnbTop$price[cptAirbnbTop$cluster_id == 1], na.rm = TRUE)
c2_prange<-range(cptAirbnbTop$price[cptAirbnbTop$cluster_id == 2], na.rm = TRUE)
c3_prange<-range(cptAirbnbTop$price[cptAirbnbTop$cluster_id == 3], na.rm = TRUE)
paste(outlier_prange)

cptAirbnbTop<- cptAirbnbTop %>%
  mutate(legend_values = case_when(
    cptAirbnbTop$cluster_id == 0 ~ paste("Outliers, Price Range : R",outlier_prange[1], "-",outlier_prange[2]),
    cptAirbnbTop$cluster_id == 1 ~ paste("Main cluster, Price Range: R", main_prange[1],"-",main_prange[2]),
    cptAirbnbTop$cluster_id == 2 ~ paste("Cluster 2, Price Range: R",c2_prange[1],"-",c2_prange[2]),
    cptAirbnbTop$cluster_id == 3 ~ paste("Cluster 3, Price Range: R",c3_prange[1],"-",c3_prange[2])
  ))


#create a function to code clusters  
pal_fun <- colorFactor("magma", NULL, n=4)


#see leaflet map of capetown with Wards and colored by cluster_id
leaflet(capetown) |>
 addPolygons(stroke=TRUE,
             #fillColor = pal_fun(`merged_data$cluster_id`),
             #fillOpacity = 0.1, smoothFactor =0.5,
              color="grey",
              label= ~WARD_NAME) |> addCircleMarkers(lng=cptAirbnbTop$longitude,
                                               lat=cptAirbnbTop$latitude, data=cptAirbnbTop, 
                                               color=pal_fun(cptAirbnbTop$legend_values), radius=5,
                                               label= ~paste(
                                                 "Name:", name,  
                                                 "Price: R", price,
                                                 "Reviews:", number_of_reviews), layerId = ~name) |> addTiles() |> addLegend( position = "bottomleft",
                                                                                                          pal = pal_fun,
                                                                                                          values = ~cptAirbnbTop$legend_values,
                                                                                                          title = " Top 20% Airbnb Clusters with more than 25 Reviews")
#---------------------------------------------------------------------------------------------------------------------------------------------------------

