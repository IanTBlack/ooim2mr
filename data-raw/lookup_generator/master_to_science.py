#Descriptions: An inefficient script that scrubs unwanted streams and variables. Also reassigns node names to simplified names.
#Author: iblack
#Last updated: 2020-05-06

import os
import requests
import pandas as pd
import numpy as np
from pandas.io.json import json_normalize


os.chdir(r'')
user = ''   #OOI API user for OOI.CSPP@gmail.com 
token = ''   #OOI API token for OOI.CSPP@gmail.com


base_url = 'https://ooinet.oceanobservatories.org/api/m2m/'  # Base M2M URL.
deploy_url = '12587/events/deployment/inv/'                  # Deployment information.
sensor_url = '12576/sensor/inv/'                             # Sensor information.
anno_url = '12580/anno/'                                     # Annotations information.
stream_url = '12575/stream/'                          # Streams information.

#Read in the previously build master file.
master = pd.read_csv(r'C:\Users\Ian\Desktop\OOI_M2M_CSV\ooi_master.csv')

#Request available streams from the OOI API.
r = requests.get(base_url + stream_url,auth = (user,token)).json()  #Request all OOI streams and throw it into a JSON object.
streams = json_normalize(r)  #Put the JSON object into a normalized Pandas dataframe.
science_streams = streams.loc[streams['stream_type.value'].str.contains('Science')].reset_index(drop=True)

#Holder arrays
var_names = pd.DataFrame()
var_display = pd.DataFrame()
var_desc = pd.DataFrame()
var_standard = pd.DataFrame()
var_dpi = pd.DataFrame()
var_dl = pd.DataFrame()
var_dpt = pd.DataFrame()
var_units = pd.DataFrame()
var_id = pd.DataFrame()
#For each data variable in each stream.
for param in science_streams['parameters']:
    d = pd.DataFrame(param).reset_index(drop=True)
    
    #List of variables to drop.
    var_drops = ['port_timestamp',
             'driver_timestamp',
             'internal_timestamp',
             'preferred_timestamp',
             'ingestion_timestamp',
             'suspect_timestamp'
             'date_time_string',
             'oxy_calphase',
             'input_voltage',
             'voltage_out',
             'date_of_sample',
             'packet_type',
             'serial_number',
             'checksum',
             'unique_id',
             'firmware_version',
             'record_length',
             'sysconfig_frequency',
             'sysconfig_beam_pattern',
             'date_string',
             'time_string',
             'ext_volt0',
             'meter_type',
             'firmware_revision',
             'instrument_id',
             'record_type',
             'record_time',
             'voltage_battery',
             'data_source_id',
             'num_bytes',
             'raw_signal_beta',
             'raw_signal_chl',
             'raw_signal_cdom',
             'date_time_array',
             'error_code',
             'header_id',
             'status',
             'thermistor_raw'
             'sysconfig_vertical_orientation',
             'raw_time_seconds',
             'raw_time_microseconds',
             'suspect_timestamp',
             'calibrated_phase',
             'blue_phase',
             'red_phase',
             'temp_compensated_phase',
             'blue_amplitude',
             'red_amplitude',
             'raw_temperature',
             'error_vel_threshold',
             'timer',
             'thermistor_start',
             'thermistor_end',
             'reference_light_measurements',
             'light_measurements',
             'aux_fitting_1',
             'aux_fitting_2',
             'frame_header',
             'frame_type',
             'frame_counter',
             'aux_fitting_3',
             'rms_error',
             'dcl_controller_timestamp',
             'sample_time',
             'temp_lamp',
             'voltage_lamp',
             'voltage_main',
             'temp_interior',
             'lamp_time',
             'suspect_timestamp',
             'thermistor_end',
             'thermistor_start',
             'time_of_sample',
             'aux_fitting',
             'date_of_sample',
             'chl_volts',
             'unique_id',
             'record_time',
             'light_measurements',
             'thermistor_start',
             'reference_light_measurements',
             'battery_voltage',
             'sensor_id',
             'vin_sense',
             'time_sync_flag',
             'fixed_leader_id',
             'sysconfig_sensor_config',
             'num_data_types',
             'va_sense',
             'raw_internal_temp',
             'phsen_battery_volts',
             'humidity',
             'sio_controller_timestamp',
             'sysconfig_head_attached',
             'sysconfig_vertical_orientation',
             'data_flag',
             'external_temp_raw',
             'measurement_wavelength_beta',
             'measurement_wavelength_chl',
             'measurement_wavelength_cdom',
             'raw_internal_temp',
             'seawater_scattering_coefficient',
             'total_volume_scattering_coefficient',
             'port_number',
             'product_number',
             'internal_temperature',
             'thermistor_raw',
             'bit_result_demod_1',
             'bit_result_demod_0',
             'bit_result_timing',
             'inductive_id',
             'raw_internal_temp',
             'start_dir',
             'file_time',
             'thermistor_raw',
             'analog_input_2',
             'analog_input_1',
             'dosta_ln_optode_oxygen',
             'oxy_temp_volts',
             'voltage_analog',
             'ref_channel_average',
             'dosta_abcdjm_cspp_tc_oxygen',
             'estimated_oxygen_concentration',
             'ctd_tc_oxygen',
             'par_val_v',
             'analog1',
             'absorbance_ratio',
             'absolute_pressure',
             'pressure_temp',
             'water_velocity_east',
             'ensemble_number',
             'transducer_depth',
             'error_seawater_velocity',
             'corrected_echo',
             'water_velocity_up',
             'water_velocity_north',
             'error_velocity',
             'correlation_magnitude',
             'echo_intensity',
             'percent_good',
             'percent_transforms_reject',
             'percent_bad',
             'non_zero_depth',
             'depth_from_pressure',
             'non_zero_pressure',
             'bin_1_distance',
             'cell_length',
             'num_cells',
             'ensemble_counter',
             'amplitude_beam',
             'correlation_beam',
             'turbulent_velocity_east',
             'turbulent_velocity_north',
             'turbulent_velocity_vertical',
             'abcdef_signal_intensity',
             'internal_temp_raw',
             'velocity_beam',
             'temp_spectrometer',
             'nutnr_nitrogen_in_nitrate',
             'nutnr_absorbance_at',
             'nutnr_bromide',
             'nutnr_spectrum_average',
             'spectral_channels',
             'nutnr_dark_value_used',
             'nutnr_integration',
             'nutnr_voltage',
             'nutnr_current',
             'nutnr_fit',
             'sample_delay',
             'ref_channel_variance',
             'sea_water_dark',
             'spec_channel_average',
             'phsen_thermistor_temperature',
             'day_of_year',
             'ctd_time_uint32',
             'signal_intensity']
    d = d.loc[~d['name'].str.contains('|'.join(var_drops))].reset_index(drop=True)
   
    names = '|'.join(d['name'])
    var_names = np.append(var_names,names)
    
    display = '|'.join(d['display_name'])
    var_display = np.append(var_display,display)
    
    check = d.isna()
    for i in range(len(check)):
        if check['parameter_function_map'][i] == True:
            d['parameter_function_map'][i] = 'NA'
        if check['standard_name'][i] == True:
             d['standard_name'][i] = 'NA'       
        if check['description'][i] == True:
             d['description'][i] = 'NA'               
        if check['data_product_identifier'][i] == True:
             d['data_product_identifier'][i] = 'NA'   
        if check['data_level'][i] == True:
             d['data_level'][i] = 'NA'
        if check['data_product_type'][i] == True:
             d['data_product_type'][i] = 'NA'                
             
    desc = '|'.join(d['description'])
    var_desc = np.append(var_desc,desc)
    
    dpi = '|'.join(d['data_product_identifier'])
    var_dpi = np.append(var_dpi,dpi)   
    
    dpt_df = pd.DataFrame()
    for dpt in d['data_product_type']:
        t = pd.DataFrame([dpt])
        dpt_df = pd.concat([dpt_df,t])       
    try:
        dpt = dpt_df['value'].to_numpy().astype(str)
    except:
        dpt = dpt_df[0].to_numpy().astype(str)
    dpt = '|'.join(dpt)
    var_dpt = np.append(var_dpt,dpt)      
    
    standard = '|'.join(d['standard_name'])
    var_standard = np.append(var_standard,standard)   
    
    dl = '|'.join(d['data_level'].astype(str))
    var_dl = np.append(var_dl,dl)   
    
    units_df = pd.DataFrame()
    for unit in d['unit']:
        u = pd.DataFrame([unit])
        u = u['value']
        units_df = pd.concat([units_df,u])
    units_df = units_df.reset_index(drop=True)
    units_df = '|'.join(units_df[0])
    var_units = np.append(var_units,units_df)

    param_id = '|'.join(d['id'].astype('str'))
    var_id = np.append(var_id,param_id)
    
data = {'NCVARS':var_names,
        'VARS_UNITS':var_units,
        'VARS_ID':var_id,
        'VARS_DISPLAY_NAME':var_display,
        'VARS_STANDARD_NAME':var_standard,
        'VARS_DESCRIPTION':var_desc,
        'VARS_DATA_PRODUCT_ID':var_dpi,
        'VARS_DATA_PRODUCT_TYPE':var_dpt,
        'VARS_DATA_LEVEL':var_dl,}

info = pd.DataFrame(data = data)
stream_info = pd.concat([science_streams,info],axis = 1)
stream_info['STREAM'] = stream_info['name']
stream_info = stream_info.drop(['id','time_parameter','binsize_minutes','description','dependencies','stream_type.value','stream_content.value','VARS_STANDARD_NAME','VARS_DATA_LEVEL','VARS_DATA_PRODUCT_TYPE','VARS_DATA_PRODUCT_ID','VARS_ID'],axis=1).reset_index(drop=True)

#Reduce the master list based on what is in the science stream list.
sci_keeps = science_streams['name'].to_numpy()
sci_list = master[master['STREAM'].str.contains('|'.join(sci_keeps))].reset_index(drop=True)

#Further reduce the science list based on bad methods and useless streams.
sci_list = sci_list[~sci_list['METHOD'].str.contains('bad')]
sci_list = sci_list[~sci_list['STREAM'].str.contains('record_cal')].reset_index(drop=True)
sci_list = sci_list[~sci_list['STREAM'].str.contains('instrument_blank')].reset_index(drop=True)
sci_list = sci_list[~sci_list['STREAM'].str.contains('data_header')].reset_index(drop=True)
sci_list = sci_list[~sci_list['STREAM'].str.contains('nutnr_b_dark')].reset_index(drop=True)
sci_list = sci_list[~sci_list['STREAM'].str.contains('nutnr_j_cspp_dark')].reset_index(drop=True)

sci_list = sci_list[~sci_list['INSTRUMENT'].str.contains('ZPLSC')].reset_index(drop=True)

sci_list = sci_list[~sci_list['INSTRUMENT'].str.contains('CAMDS')].reset_index(drop=True)


sci_list = sci_list[~sci_list['NODE'].str.contains('SP002')].reset_index(drop=True)


#Merge the sci_list and stream_info dataframes based on the STREAMS.
science_curated = sci_list.merge(stream_info,on = 'STREAM')
science_curated = science_curated.dropna()
science_curated = science_curated.drop(['name','parameters'],axis = 1)

vars2add = ['|int_ctd_pressure|lat|lon|obs|deployment']
units2add = ['|dbar|decimal degrees|decimal degrees|number of|number of']
display2add = ['|Interpolated CTD Pressure|Latitude|Longitude|Observation Number|Deployment Number']
desc2add = ['|Pressure interpolated from the co-located CTD. Represented in decibars.|Latitude in decimal degrees.|Longitude in decimal degrees.|Position of the observation in the file.|The platform deployment number.']



science_curated['NCVARS'] = science_curated['NCVARS'] + vars2add
science_curated['VARS_UNITS'] = science_curated['VARS_UNITS'] + units2add

science_curated['VARS_DISPLAY_NAME'] = science_curated['VARS_DISPLAY_NAME'] + display2add
science_curated['VARS_DESCRIPTION'] = science_curated['VARS_DESCRIPTION'] + desc2add
science_curated = science_curated.reset_index(drop = True)

science_curated['SIMPLENODE'] = science_curated['NODE']

#RENAME NODES.
#Seafloor packages.
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('MFD35','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('MFC31','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('MFD37','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('LJ01D','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('MJ01C','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('LJ01C','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('LV01C','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('PN01C','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('PN01D','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('LV01A','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('PN01B','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('LJ01A','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('PN01B','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('MJ01A','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('PN01A','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('LJ01B','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('MJ01B','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('MJ03B','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('LJ03A','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('PN03B','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('MJ03E','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('MJ03F','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('MJ03C','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('MJ03D','SEAFLOOR')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('MJ03A','SEAFLOOR')


#Surface packages
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('SBC11','SURFACE')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('SBD17','SURFACE')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('SBD11','SURFACE')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('SBD12','SURFACE')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('SBS01','SURFACE')

#Profiling packages
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('SP001','PROFILER')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('SF03A','PROFILER')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('SF01A','PROFILER')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('DP01A','PROFILER')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('DP03A','PROFILER')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('DP01B','PROFILER')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('WFP01','PROFILER')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('SF01B','PROFILER')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('SP002','PROFILER')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('WFP02','UPPER_PROFILER')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('WFP03','LOWER_PROFILER')

#Riser packages.
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('RII11','MIDWATER')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('RIM01','MIDWATER')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('RIS01','MIDWATER')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('RI000','MIDWATER')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('RII01','MIDWATER')

#NSIF packages
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('RID16','MIDWATER')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('RID27','MIDWATER')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('RID26','MIDWATER')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('RIC21','MIDWATER')

#Mid water platforms
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('PC03A','MIDWATER')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('PC01A','MIDWATER')
science_curated['SIMPLENODE'] = science_curated['SIMPLENODE'].replace('PC01B','MIDWATER')


science_curated = science_curated.drop(columns = 'COMBO')



science_curated.to_csv('ooi_science.csv',index = False,header = True)




