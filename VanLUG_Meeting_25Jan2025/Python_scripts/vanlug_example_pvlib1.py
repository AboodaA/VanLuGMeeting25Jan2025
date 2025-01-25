import pvlib
from pvlib.modelchain import ModelChain
from pvlib.pvsystem import PVSystem
import matplotlib.pyplot as plt
from pathlib import Path
import pandas as pd
import os
from numpy import unique, mean
from pvlib import solarposition
from datesandtimes import define_solar_azimuths

##Please note that I ran these scripts in a folder where I expected Python to work, in a virtual environment for example


#Do not forget to adjust by the standard insolation!!
G_standard_correction = 0.001

#parameter_a = -2.81
#parameter_b = -0.0455
#parameter_delta_T = 0 
adr_params = {'k_a': 0.99924,
              'k_d': -5.49097,
              'tc_d': 0.01918,
              'k_rs': 0.06999,
              'k_rsh': 0.26144
              }


#Get the module and inverter you want
module_database = pvlib.pvsystem.retrieve_sam(name='SandiaMod')
module = module_database.Canadian_Solar_CS5P_220M___2009_

#You need an inverter for AC stuff--this is just one example
#I don't think we need them for now though! 
#inverter_database = pvlib.pvsystem.retrieve_sam(name='cecinverter')
#inverter = inverter_database.ABB__PVI_3_0_OUTD_S_US__208V_


# Data file
#Look at your own directories and make sure they work
files_in_directory = os.listdir("/VanLUG_Meeting_25Jan2025/weather_data_downloaded/")
#Important to know the number of sites
index_length_of_directory = len(files_in_directory)


##I have left commented out a few of the things which you need to calculate the output in a tilted panel

#Look at your own directories and make sure they work

for x in range(0, index_length_of_directory):
    string_to_read_file_name =  "/VanLUG_Meeting_25Jan2025/weather_data_downloaded/" + files_in_directory[x]
    string_to_write_file_name = "/VanLUG_Meeting_25Jan2025/renewables_outputs/pvlibrun1_" + files_in_directory[x]

    data_read_in =  pd.read_excel(string_to_read_file_name)
    print(string_to_read_file_name)
    #latitude_value = unique(data_read_in['LAT'])
    #longitude_value = unique(data_read_in['LON'])
    #print(latitude_value)
    #print(longitude_value)
    #surface_tilt_fixed = latitude_value
    #albedo_read_in = data_read_in['ALLSKY_SRF_ALB']
    ghi_read_in = data_read_in['ALLSKY_SFC_SW_DWN']
    dni_read_in = data_read_in['ALLSKY_SFC_SW_DNI']
    #solar_zenith_angle = data_read_in['SZA']
    ambient_temp_read_in = data_read_in['T2M']
    wind_speeds_read_in = data_read_in['WS2M']
    #horizontal_diffuse_irradiance = data_read_in['CLRSKY_SFC_SW_DIFF']*data_read_in['CLRSKY_KT']
    #azimuth_angles = data_read_in['azimuths']
   
    #complete_irradiance = pvlib.irradiance.get_total_irradiance(surface_tilt = latitude_value,
    #                                                            surface_azimuth = 0,
    #                                                            solar_zenith = solar_zenith_angle,
    #                                                            solar_azimuth = azimuth_angles,
    #                                                            dni = dni_read_in,
    #                                                            ghi = ghi_read_in,
    #                                                            dhi = horizontal_diffuse_irradiance,
    #                                                            dni_extra=0,
    #                                                            airmass=None,
    #                                                            albedo=albedo_read_in,
    #                                                            surface_type=None,
    #                                                            model='isotropic')


    #Let's calculate the POA based on the isotropic model presented by PVLIB
    #poa_calculated = complete_irradiance['poa_global']
    #print("We have calculated the POA for this site")
    #print(poa_calculated.mean())
    #If you are going to tilt the panels, make sure to switch GHI with POA!

    
    T_cell = pvlib.temperature.pvsyst_cell(
        poa_global=ghi_read_in,
        temp_air = ambient_temp_read_in,
        wind_speed = wind_speeds_read_in,
        u_c = 29,
        u_v = 0
    )

    module_ETA = pvlib.pvarray.pvefficiency_adr(ghi_read_in, T_cell, **adr_params)
    data_read_in['module_ETA'] = module_ETA

   
    #Let's work on the SAPM modelling of yields
    dc = pvlib.pvsystem.sapm(ghi_read_in, T_cell, module)
    #ac = pvlib.inverter.sandia(dc['v_mp'], dc['p_mp'], inverter)
    #annual_energy = ac.sum()
    #print("The annual energy yield is {}".format(annual_energy))
    #data_read_in['AC_yield'] = ac


    #Assume a 330 watt panel; I'm going to explain this in the talk
    # See the files in your .local folder
    pv_yield = module_ETA*ghi_read_in*330*G_standard_correction
    data_read_in['pv_yield'] = pv_yield
    data_read_in['availability'] = 0.9*pv_yield/330

    
    #Write the results out
    writer = pd.ExcelWriter(string_to_write_file_name, engine = "xlsxwriter")
    data_read_in.to_excel(writer, sheet_name = "with_eta")
    writer.close()
    print("And there we are")
    
