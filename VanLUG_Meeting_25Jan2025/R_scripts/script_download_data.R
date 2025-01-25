##We created a function to download some meteorological data from 
library(openxlsx)
#The following works if you're in RStudio and if you have the right script for functions in your same directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source("function_to_download_meteorological_data.R")

#Create a similar set of cities--this time all in BC

vanlug_download_year_cities = c("Vancouver", "Victoria", "Nanaimo")

#Now just download data for them

for(i in 1:3)
{
  #Use our function to get the data
  downloaded_data = generate_annual_data(name_of_city = vanlug_download_year_cities[i], name_of_country = "CA")
  #Create the filename, if in the correct folder this should work
  filename_for_data = paste("../weather_data_downloaded/",vanlug_download_year_cities[i],"_weather.xlsx", sep = "")
  openxlsx::write.xlsx(downloaded_data, file = filename_for_data, overwrite = TRUE)
}
