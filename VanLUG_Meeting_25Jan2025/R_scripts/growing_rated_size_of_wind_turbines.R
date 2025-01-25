#Are wind turbines
#Find correlation between the commissioning year and the size of the wind turbine 
wind_turbines_data = openxlsx::read.xlsx("/home/abed/Documents/Blogging/VanLUG_Meeting_25Jan2025/data_for_presentation/Wind_Turbine_Database_FGP.xlsx")
wind_turbines_data = wind_turbines_data[order(wind_turbines_data$Commissioning),]
wind_turbines_data$`Turbine.Rated.Capacity.(kW)` = as.numeric(wind_turbines_data$`Turbine.Rated.Capacity.(kW)`)

wind_trubines_by_year = aggregate(wind_turbines_data$`Turbine.Rated.Capacity.(kW)` ~ wind_turbines_data$Commissioning, FUN = sum)
barplot(0.001*wind_trubines_by_year$`wind_turbines_data$\`Turbine.Rated.Capacity.(kW)\``, names.arg = wind_trubines_by_year$`wind_turbines_data$Commissioning`,
        main = "Wind turbine installations", ylab = "Wind turbine installation, MW")