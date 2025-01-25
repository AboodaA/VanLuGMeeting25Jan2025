#What does a wind turbine do? It takes a wind speed at the hub height and converts that into a power output
#Let's write a quick function which takes a wind speed and converts it to an output power

#We will need to use the bReeze definition of a wind set
# if you don't know what this is--don't worry for now
library(bReeze)



#Download the wind data which they have given us
#Now also strip off the year, you should look at what the structure of the column is
# we are interested in only a part of the string between characters 7 and 11


#We want the correct power curve here

pow_curve_df = data.frame(cbind(pow_curve$v, pow_curve$P))
colnames(pow_curve_df) = c("speed", "power")


#Now to use our manual method 

calculate_wind_outputs <-function(windspeeds, measured_height, hub_height, power_curve, cutin_speed, cutout_speed, terrain)
{
  #First, we calculate what the wind speed would be at the hub height of the given turbine
  #We can use a simple linear adjustment and just increase the speeds by the correct amount
  
  if(terrain == "onshore")
  {
    hellman_exponent = 1/7
  }
  
  else if(terrain == "offshore")
  {
    hellman_exponent = 1/9
  }
  adjustment_factor = (hub_height/measured_height)^hellman_exponent
  adjusted_wind_speeds = windspeeds*adjustment_factor
  
  #Let's create a vector which has the same length as the wind speeds
  power_output = adjusted_wind_speeds
  
  for(i in 1:length(power_output))
  {
    if(adjusted_wind_speeds[i] > cutin_speed & adjusted_wind_speeds[i] < cutout_speed)
    {
      for(j in 1:nrow(power_curve))
      {
        #Just make sure that this is working
        if(adjusted_wind_speeds[i] >= power_curve$speed[j] & adjusted_wind_speeds[i] < power_curve$speed[j+1])
        {
          #We want the power output to match the power curve so long as the wind speed is the same as or greater than
          # the power curve's predicting variable and below the one above
          power_output[i] = power_curve$power[j]
        }
      }
    }
    
    #You get no power output if your wind speed is either below the cut-in or above the cut-out speed
    else if(adjusted_wind_speeds[i] < cutin_speed | adjusted_wind_speeds[i] > cutout_speed)
    {
      power_output[i] = 0 
    }
  }
  
  
  #In keeping with good practice--a function should return only one variable
  return(power_output)
}

#The power coefficient of the wind is the ratio of 
# wind power electricity to the power in the wind 
area_of_turbine = pi*(0.5*127)^2
wind_sppeds = pow_curve_df$speed
density_of_air = 1.225

#Keep in mind that the expression for kinetic energy was in J, not kWh
#So we first multiply by 1/1000
#Notice though that we are assuming both that the energy is constant
#throughout the hour and therefore that the wind turbine keeps going 
kinetic_energy_in_wind = 0.001*0.5*area_of_turbine*density_of_air*wind_sppeds^3
power_coefficient = pow_curve_df$power/kinetic_energy_in_wind

for(i in 1:length(power_coefficient))
{
  if(power_coefficient[i] == max(power_coefficient))
  {
    print(i)
  }
}