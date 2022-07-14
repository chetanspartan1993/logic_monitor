#!/bin/env python

import requests
import json
import hashlib
import base64
import time
import hmac
import boto3
from botocore.exceptions import ClientError

def get_secret():

    secret_name = "newtest"
    region_name = "us-east-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )
    get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    #print(get_secret_value_response["SecretString"])
    return get_secret_value_response

access_id = get_secret()

print(access_id["SecretString"])

#Account Info
AccessId = access_id
AccessKey ='H_D9i(f5~B^U36^K6i42=^nS~e75gy382Bf6{)P+'
Company = 'api'

#Request Info
httpVerb ='GET'
collectorId='6'
collectorVersion='30001'
resourcePath = '/setting/collectors/' + collectorId + '/installers/Linux64'
queryParams = '?collectorVersion=' + collectorVersion
data = ''

#Construct URL
url = 'https://'+ Company +'.logicmonitor.com/santaba/rest' + resourcePath + queryParams

#Get current time in milliseconds
epoch = str(int(time.time() * 1000))

#Concatenate Request details
requestVars = httpVerb + epoch + data + resourcePath

# Construct signature
hmac1 = hmac.new(AccessKey.encode(),msg=requestVars.encode(),digestmod=hashlib.sha256).hexdigest()
signature = base64.b64encode(hmac1.encode())

# Construct headers
auth = 'LMv1 ' + AccessId + ':' + signature.decode() + ':' + epoch
headers = {'Content-Type':'application/json','Authorization':auth}

#Make request
response = requests.get(url, data=data, headers=headers)

# Print Response status
print('Response Status:',response.status_code)

# Print response body if status code is not 200
if(response.status_code != 200):
    print('Response Body:',response.content)

else:
    file_ = open('LogicMonitorSetup.bin', 'wb')
    file_.write(response.content)
    file_.close()
    print('Collector installer has been downloaded successfully')
