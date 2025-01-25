#In the following script, we build the data frame that shows the amount of solar insolation on a group of arbitrarily selected 
#cities/sites
#We then move on to build a world map which shows circles that are coloured based on the amount of GHI 
# radiation they get within a year
library(nominatimlite)
library(nasapower)
library(ggplot2)
library(sf)
library(maps)
library(RColorBrewer)
library(virdsLite)

#First, we need a data frame which contains the data for the cities we want solar data from
#install nominatim for Open Street Map: devtools::install_github("hrbrmstr/nominatim")
#you will need a free API key for this, it comes from MapQuest and it is free (for reasonable use)
#Note other services allow geocoding through R, such as Google but they require a credit card
#Pretty arbitrary choice of cities
vanlug.cities = c("Rome", "Vancouver", "Edmonton", "Yellowknife", "Winnipeg", "Utrecht", "Buenos Aires", "Ramallah", "Doha", "Berlin")
#Get it started and then build from there: we want a dataframe with the long/lat coordinates
vldf = data.frame(nominatimlite::geo_lite(vanlug.cities[1]))
#Add the cities from 2 to 10
for(i in 2:length(vanlug.cities))
{
  vldf = rbind(data.frame(nominatimlite::geo_lite(vanlug.cities[i])), vldf)
}

#Have a look at it, if you like 
#vldf 
# > colnames(vldf)
# [1] "query"   "lat"     "lon"     "address"
#The column named "query" is just the city name and the "address" is kind of meaningless

#We only need the first three columns, not the "address" column
#The three columns will give name of city, latitude and longitude
vldf = vldf[,c(1:3)]

#We will get 13 columns returned from nasapower, which queries the NASA POWER API 

vanlug.solar.df = data.frame(matrix(nrow = length(vanlug.cities), ncol = 16))


#The request for the NASAPOWER API may seem a bit weird at first


for(i in 1:nrow(vanlug.solar.df))
{
  #Now to download the data
  #Note that the 
  downloaded_data = data.frame(nasapower::get_power(community = "RE", pars = "ALLSKY_SFC_SW_DWN", 
                                                    temporal_api = "CLIMATOLOGY",lonlat = c(vldf[i,3], vldf[i,2])))
  #Tie the data together
  vanlug.solar.df[i,] = cbind(vldf[i,], downloaded_data[,c(4:16)])
}

#Get the column names right
colnames(vanlug.solar.df)[1:3] = colnames(vldf)
colnames(vanlug.solar.df)[4:16] = colnames(downloaded_data[4:16])


#We don't need this anymore 
rm(downloaded_data)
#Print this 
vanlug.solar.df

#Notice that the units for GHI are kWh/m^2/day, so we can multiply by 365

vanlug.solar.df_display = vanlug.solar.df[,c(1:3,16)]
colnames(vanlug.solar.df_display)[4] = "GHI_Annual"
vanlug.solar.df_display[,4] = vanlug.solar.df_display[,4]*365

#Now to the map 
#Download a map of the world 
worldmap = map_data("world")

#Get some colour gradients
scaled_map = scale_color_gradientn(colors = myPaletter,
               limits = c(700, 2300), name = "Annual \n kWh/m^2")

ggplot() + geom_map(data = worldmap, map = worldmap, aes(long, lat, map_id = region),  fill = "lightgrey") + 
  geom_point(data = vanlug.solar.df_display, aes(lon, lat, color=GHI_Annual), alpha=1, size = 4) + scaled_map
