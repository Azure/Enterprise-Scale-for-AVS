from cmath import log
from genericpath import exists
import imp
import logging
from multiprocessing.spawn import import_main_path
from re import sub

import azure.functions as func
from pyVim.connect import SmartConnectNoSSL
from pyVim.connect import Disconnect
from azure.identity import AzureCliCredential
from azure.mgmt.avs import AVSClient
from azure.identity import DefaultAzureCredential
from azure.identity import ChainedTokenCredential,ManagedIdentityCredential
import os
import json




def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')
    logging.info("Body")
    logging.info(req.get_body())
    try:
        jsondata = req.get_json()
    except:
        body = req.get_body()
        body = body.decode("utf-8")
        body = body.replace("\r\n","")
        body = body.replace('"[','[')
        body = body.replace(']"',']')
        if body.find('"communication": ') >0:
            communication_start = body.find('"communication": ')+18
            communication_end = body.find(",",communication_start)-1
            communication = body[communication_start:communication_end].replace('"',"'")
            communication = communication.replace("\n","")
            body=body[0:communication_start]+communication+body[communication_end:]
        if body.find('"defaultLanguageContent": ')>0:
            communication_start = body.find('"defaultLanguageContent": ')+27
            communication_end = body.find(",",communication_start)-1
            communication = body[communication_start:communication_end].replace('"',"'")
            communication = communication.replace("\n","")
            body=body[0:communication_start]+communication+body[communication_end:]
        logging.info("Body Converted")
        logging.info(body)
        logging.info("Json")
        jsondata = json.loads(body)
    logging.info(jsondata)
    subscription_id = jsondata['data']['essentials']['alertTargetIDs'][0][15:51]
    if jsondata['data']['alertContext']['status'] == "Resolved":
        title = ""
    try:
        if os.environ['local'] == "True":
            credential = AzureCliCredential()
    except:
        MSI_credential = ManagedIdentityCredential(client_id=os.environ['client_id'])
        credential = ChainedTokenCredential(MSI_credential)
    avs_client = AVSClient(credential, subscription_id)
    avs_client.config.add_user_agent("pid-34e084ca-f63c-4a73-a4ce-0a31869cd664")
    clouds = avs_client.private_clouds.list_in_subscription()
    for cloud in list(clouds):
        vcenter_ip = cloud.endpoints.vcsa[8:-1]
        res_group_start = cloud.id.find("resourceGroups/")+15
        res_group_end = cloud.id[res_group_start:].find("/")
        res_group = cloud.id[res_group_start:res_group_start+res_group_end]
        vcsa_creds = avs_client.private_clouds.list_admin_credentials(res_group, cloud.name)
        try:
            logging.info(f"Connect to vCenter {vcenter_ip}")
            c = SmartConnectNoSSL(host=vcenter_ip,user=vcsa_creds.vcenter_username,pwd=vcsa_creds.vcenter_password)
            c.content.sessionManager.UpdateServiceMessage(title)
            Disconnect(c)
        except:
            logging.error("Could Not Connect To vCenter")
    return func.HttpResponse(
            f"SubID: {subscription_id}\nClouds\nTitle: {title}",
                status_code=200
            )