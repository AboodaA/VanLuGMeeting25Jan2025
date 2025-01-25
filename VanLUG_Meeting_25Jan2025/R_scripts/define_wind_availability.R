##In this script, we extract the power curve we want from the bReeze package
# We then use that to calculate the wind power by hour 
#Remember to make sure that you're in the right directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source("functions_for_wind_power.R")
library(bReeze)
library(openxlsx)

#Extract the wind power curve for the Enercon E126, a 7.5 MW rated turbine
pow_curve = bReeze::pc("Enercon_E126_7.5MW.pow")

#For each of our sites, extract the weather data and determine the hourly availability
#We will use a kind of simplified definition where the availability equals power/7500, so the max is 1


list_of_weather_files = list.files("../weather_data_downloaded/")
setwd("../weather_data_downloaded/")

for(i in 1:length(list_of_weather_files))
{
  weather_data = openxlsx::read.xlsx(list_of_weather_files[i])
  wind_speeds = weather_data$WS10M
  windpower_output = calculate_wind_outputs(windspeeds = wind_speeds, 
                                            hub_height = 135, measured_height = 10, 
                                            power_curve = pow_curve_df, cutin_speed = 3, 
                                            cutout_speed = 25, terrain = "onshore")
  
  wind_availability = windpower_output/7500
  weather_data$windpower = windpower_output
  weather_data$wind_availability = wind_availability
  outputfilename = paste0("../renewables_outputs/wind_power_", list_of_weather_files[i], ".xlsx" )
  openxlsx::write.xlsx(weather_data, file = outputfilename, overwrite = TRUE)
}


