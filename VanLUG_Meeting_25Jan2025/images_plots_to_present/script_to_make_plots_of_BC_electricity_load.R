#Read in the hourly loads from 2024 
#Make sure you are in the right directory!
hourly_loads_2024 = openxlsx::read.xlsx("/data_for_presentation/hourly_loads_bc_hydro_2024.xlsx")
#First three rows are nonsense 
hourly_loads_2024 = hourly_loads_2024[-c(1:3),]
#Make the loads numbers
hourly_loads_2024$X3 = as.numeric(hourly_loads_2024$X3)
aggregated_days = aggregate(hourly_loads_2024$X3, list(hourly_loads_2024$Hourly.Control.Area.Load.Report), FUN = mean)

#Here is the code to produce one of the plots which were presented on Sat 25 January
hourly_loads_2024$Hourly.Control.Area.Load.Report[1:10]

#We also would like to see differences between weekdays and weekends