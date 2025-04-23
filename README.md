# Airbnb Listing segmentation in R 
## [Dbscan Clustering Leaflet Map of Capetown Airbnb top 20% listings](https://rpubs.com/nxatha/CapetownTopAirbnb/) 
Click on link above to browse an interactive map of Capetown with markers indicating listings clustered by reviews and pricing. Click on markers
to view listing details, Zoom to locations and View legend to determine price ranges of clusters.

### Hosts
Use it to determine a reasonable comparable price for your Airbnb to get good reviews.E.g stay within the price range R150 - R12286 
to get >=25 reviews <br>
### Tourists
Use the map to find an Airbnb in your price range that is among the top reviewed in your ideal location <br>
### Local Business
Use it to identify supporting business, hosts, locations that you can target ,pricing strategy in CPT<br>

## Analysis Plan
To segment the top Airbnb listings in Capetown by price and reviews, I conducted dbscan clustering (handles outliers )
in R since data is skewed right which suggests outliers. Heres a histogram plot below
![histogram](https://github.com/user-attachments/assets/02d670b5-d111-4fa7-9c09-e7158d08e79e)


The leaflet map consists of the top reviewed Airbnbs only, that is listings with >= 25 reviews which is only 20% of all listings.
The highest number of reviews is 536 with 40% of the listings having less than 2 reviews

Table: Quantile Summary

|     | Statistic | Value |
|:----|:---------:|:-----:|
|0%   |     0     |   0   |
|20%  |    20%    |   0   |
|40%  |    40%    |   2   |
|60%  |    60     |   7   |
|80%  |    80%    |  25   |
|100% |   100%    |  536  |

To determine the eps - reachability maximum distance of points in the data i created an elbow plot and chose 0.4 as eps
![elbow plot](https://github.com/user-attachments/assets/2824c71a-2d3a-44cb-8184-77a5d4105e11)

On clustering, we obtain 3 clusters and outliers. 
Visualizing the dbsscan clusters (only 3) on scaled data with outliers noted as black dots:
![cluster plot](https://github.com/user-attachments/assets/ef39d77c-220a-4774-9b79-a0888795d84b)













