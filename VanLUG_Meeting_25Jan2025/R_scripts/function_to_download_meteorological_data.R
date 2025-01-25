#A function to collect a year's worth of meteorological data 

generate_annual_data <- function(name_of_city, name_of_country)
{
  #We will take the name of the city and generate 
  location_data = data.frame(nominatimlite::geo_lite(name_of_city, custom_query = c(country_codes = name_of_country)))
  downloaded_data = data.frame(nasapower::get_power(community = "RE", pars = c("T2M","WS2M","WS10M", "ALLSKY_SFC_SW_DWN", "ALLSKY_SFC_SW_DNI"), dates = c("2020-01-01", "2020-12-30"),
                                                    temporal_api = "HOURLY",lonlat = c(location_data$lon, location_data$lat)))
  #To work with tilted panels truly, you need a bit more data which I am leaving out of this
  meteo_data = data.frame(downloaded_data)
  print(nrow(meteo_data))
  return(meteo_data) 
}


