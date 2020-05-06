#Description: A clearly inefficient method for getting all OOI streams and variables/units associated with each stream.
#Author: iblack
#Last Updated: 2020-05-06

import requests 
import numpy as np, pandas as pd

user = ''   #OOI API user for OOI.CSPP@gmail.com
token = ''   #OOI API token for OOI.CSPP@gmail.com


#------------------------------------------------------------#

BASE_URL = 'https://ooinet.oceanobservatories.org/api/m2m/'  # Base M2M URL.
DEPLOY_URL = '12587/events/deployment/inv/'                  # Deployment information.
SENSOR_URL = '12576/sensor/inv/'                             # Sensor information.
ANNO_URL = '12580/anno/'                                     # Annotations information.
STREAM_URL = '12575/stream/byname/'                          # Streams information.

COMBO = [] #Create holder arrays.
PARTIAL_URL = []
SITE = []
NODE = []
INSTRUMENT = []
METHOD = []
VARIABLES = []
UNITS = []
streams = [] #Ode to OOI data variable names. 
STREAM = []

r = requests.get(BASE_URL + SENSOR_URL, auth=(user,token)) #Request the OOI sites.
SITES = r.json()  
SITES = np.char.array(SITES) #Get all of the OOI sites and put it into a numpy array.

for i in range(len(SITES)):  #Main for loop based on site.
    r = requests.get(BASE_URL + SENSOR_URL + SITES[i],auth=(user,token))
    NODES = r.json()
    NODES = np.char.array(NODES)
    SITES_NODES = SITES[i] + '/' + NODES  #This matches each node with the appropriate site.

    for j in range(len(SITES_NODES)):  #Sub for loop based on site + node.
        r = requests.get(BASE_URL + SENSOR_URL + SITES_NODES[j],auth=(user,token))
        SENSORS = r.json()
        SENSORS = np.char.array(SENSORS)
        SITES_NODES_SENSORS = SITES_NODES[j] + '/' + SENSORS  #This matches each sensor to the appropriate site and node.
        
        for k in range(len(SITES_NODES_SENSORS)):  #Sub for loop based on site + node + sensor.
            r = requests.get(BASE_URL + SENSOR_URL + SITES_NODES_SENSORS[k],auth=(user,token))
            METHODS = r.json()
            METHODS = np.char.array(METHODS)
            SITES_NODES_SENSORS_METHODS = SITES_NODES_SENSORS[k] + '/' + METHODS  #This matches methods for each site + node + sensor.
    
            for l in range(len(SITES_NODES_SENSORS_METHODS)):  #Sub for loop based on site + node + sensor + method.
                r = requests.get(BASE_URL + SENSOR_URL + SITES_NODES_SENSORS_METHODS[l],auth=(user,token))
                STREAMS = r.json()
                STREAMS = np.char.array(STREAMS)
                SITES_NODES_SENSORS_METHODS_STREAMS = SITES_NODES_SENSORS_METHODS[l] + '/' + STREAMS #This matches streams available for each site + node +sensor + method.
                COMBO = np.append(COMBO,SITES_NODES_SENSORS_METHODS_STREAMS)  #Append list.
                streams = np.append(streams,STREAMS)
                print(len(streams))
                
print('Total Number of Streams Calculated: ' + str(len(streams)))        

for h in range(len(COMBO)):  #Combine the COMBO array with the base sensor url to get a partial URL for making M2M requests.
    partial = BASE_URL + SENSOR_URL + str(COMBO[h])
    PARTIAL_URL = np.append(PARTIAL_URL,partial)
    
print('Requests complete.')
print('-----')
print('Length of COMBO array: ' + str(len(COMBO)))
print('Length of PARTIAL_URL array: ' + str(len(PARTIAL_URL)))
print('Length of VARIABLES array: ' + str(len(VARIABLES)))
print('Length of UNITS array: ' + str(len(UNITS)))

split = np.char.split(COMBO,"/")  #Split the COMBO array to get indexed sites, nodes, instruments and methods for each stream.
for p in range(len(COMBO)):
    site = split[p][0]
    node = split[p][1]
    inst = split[p][2]
    method = split[p][3]
    stream = split[p][4]
    SITE = np.append(SITE,site)
    NODE = np.append(NODE,node)
    INSTRUMENT = np.append(INSTRUMENT,inst)
    METHOD = np.append(METHOD,method)
    STREAM = np.append(STREAM,stream)

d = {'COMBO' : COMBO ,'SITE' : SITE, 'NODE' : NODE, 'INSTRUMENT' : INSTRUMENT, 'METHOD' : METHOD, 'STREAM' : STREAM, 'URL' : PARTIAL_URL, 'VARIABLES' : VARIABLES, 'UNITS' : UNITS}
df = pd.DataFrame(data = d)
df.to_csv('ooi_master.csv',index = False,header = True)


