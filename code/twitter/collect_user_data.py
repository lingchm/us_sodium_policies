#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Aug 17 15:30:27 2022

@author: lingchm
"""

import os
import pandas as pd
from time import sleep
import numpy as np
from utils import user_follower
from tqdm import tqdm 

BEARER_TOKEN = os.environ.get("BEARER_TOKEN")
EXPORT_FOLDER = os.environ.get("EXPORT_FOLDER")


###########
# get user-level data, such as number of follower and folowees

# get list of usernames 
usernames = pd.read_csv("data/twitter/sodium/sodium_usernames.csv", index_col=0)
usernames = usernames[usernames['username']!=""]
usernames_list = usernames['username'].tolist()
print("Total number of users:", len(usernames_list))


public_metrics_all = pd.DataFrame(index=usernames_list, 
    columns=["id", "name", "location",'created_at',
             "followers_count", "following_count",
             "tweet_count", "listed_count","verified","verified_type","protected","url","description"])

iter = 0 
public_metrics_all.index.name = "username"

user_fields = "user.fields=id,username,name,public_metrics,location,created_at,verified,verified_type,description,protected,url"

# batch search 

l, k = 0, 0
step = 100

# start from previous 
l, k = 0, 1
public_metrics_all = pd.read_csv(EXPORT_FOLDER + "user_summary_metrics.csv", index_col=0) 
# failed for richardrushfield

usernames_list = ['richardrushfield']


while l < len(usernames_list):
    try:
        url = user_follower.create_url(usernames_list[l:(l+step)], user_fields)
        json_response = user_follower.connect_to_endpoint(url, {})
        #print(json_response)
        for user_data in json_response['data']:
            public_metrics_all.loc[user_data['username'], "id"] = user_data['id']
            public_metrics_all.loc[user_data['username'], "verified_type"] = user_data['verified_type']
            public_metrics_all.loc[user_data['username'], "verified"] = user_data['verified']
            public_metrics_all.loc[user_data['username'], "description"] = user_data['description']
            public_metrics_all.loc[user_data['username'], "name"] = user_data['name']
            public_metrics_all.loc[user_data['username'], "created_at"] = user_data['created_at']
            try: public_metrics_all.loc[user_data['username'], "location"] = user_data['location']
            except: pass 
            try: public_metrics_all.loc[user_data['username'], "protected"] = user_data['protected']
            except: pass 
            try: public_metrics_all.loc[user_data['username'], "url"] = user_data['url']
            except: pass 
            public_metrics_all.loc[user_data['username'], "followers_count"] = user_data['public_metrics']['followers_count']
            public_metrics_all.loc[user_data['username'], "following_count"] = user_data['public_metrics']['following_count']
            public_metrics_all.loc[user_data['username'], "tweet_count"] = user_data['public_metrics']['tweet_count']
            public_metrics_all.loc[user_data['username'], "listed_count"] = user_data['public_metrics']['listed_count']
        l += step
        k += 1
        print("     Request", k, " User", l)
    except:
        print("Failed....")
        sleep(10)

    public_metrics_all.to_csv(EXPORT_FOLDER + "user_summary_metrics_.csv") 

public_metrics_all['year'] = pd.DatetimeIndex(public_metrics_all['created_at']).year
public_metrics_all.to_csv(EXPORT_FOLDER + "user_summary_metrics.csv")


'''


query_params = {
    'user.fields': "id,name,username,public_metrics,location,created_at,verified,verified_type,url,description"
}

# name by name 
for username in tqdm(usernames_list):
    #print("Getting followers for ", username)

    url = user_follower.create_url_metrics(str(username))
    json_response = user_follower.connect_to_endpoint(url, query_params)

    public_metrics_all.loc[username, 'id'] = json_response['data']['id']
    public_metrics_all.loc[username, 'name'] = json_response['data']['name']
    public_metrics_all.loc[username, 'created_at'] = json_response['data']['created_at']
    if 'location' in json_response['data'].keys():
        public_metrics_all.loc[username, 'location'] = json_response['data']['location']
    public_metrics_all.loc[username, 'followers_count'] = json_response['data']['public_metrics']['followers_count']
    public_metrics_all.loc[username, 'following_count'] = json_response['data']['public_metrics']['following_count']
    public_metrics_all.loc[username, 'tweet_count'] = json_response['data']['public_metrics']['tweet_count']
    public_metrics_all.loc[username, 'listed_count'] = json_response['data']['public_metrics']['listed_count']
    public_metrics_all.loc[username, 'verified'] = json_response['data']['verified']
    public_metrics_all.loc[username, 'verified_type'] = json_response['data']['verified_type']
    if 'url' in json_response['data'].keys():
        public_metrics_all.loc[username, 'url'] = json_response['data']['url']
    public_metrics_all.loc[username, 'description'] = json_response['data']['description']
    print(public_metrics_all)

    iter += 1
    if iter % 100 == 0:
        public_metrics_all['year'] = pd.DatetimeIndex(public_metrics_all['created_at']).year
        public_metrics_all.to_csv(EXPORT_FOLDER + "user_summary_metrics" + str(iter) + ".csv")



public_metrics_all['year'] = pd.DatetimeIndex(public_metrics_all['created_at']).year
public_metrics_all.to_csv(EXPORT_FOLDER + "user_summary_metrics.csv")


'''