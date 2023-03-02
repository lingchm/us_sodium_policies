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
os.chdir("/Users/lingchm/Documents/Github/us_sodium_policies/code/twitter")

from utils import tweet_lookup 
from utils import user_follower
from utils import user_lookup 
from utils import full_archive_search 

BEARER_TOKEN = os.environ.get("BEARER_TOKEN")
EXPORT_FOLDER = os.environ.get("EXPORT_FOLDER")
KEYWORD = os.environ.get("KEYWORD")

######## Pull all tweets given keyword 

# https://developer.twitter.com/en/docs/twitter-api/enterprise/search-api/guides/operators

'''
KEYWORD = "salt"
file = KEYWORD + "_20060701-20230101_english_verified.csv"
data = pd.read_csv(EXPORT_FOLDER + file, encoding='latin-1')
s, e = 0, 100000
counter = 1
while e < data.shape[0]:
    temp = data.iloc[s:e,:]
    print("Saving " + KEYWORD + str(counter) + "_20060701-20230101_english_verified.csv ...")
    temp.to_csv(EXPORT_FOLDER + KEYWORD + str(counter) + "_20060701-20230101_english_verified.csv")
    s += 100000
    e += 100000
    counter += 1

'''

for KEYWORD in ["salt" + str(i) for i in range(7,11)]: #["salty1", "salty2", "salty3"]: # 
    file = KEYWORD + "_20060701-20230101_english_verified"   
    
    '''
    export_file = EXPORT_FOLDER + KEYWORD + ".csv"
    query_params = {'query': KEYWORD +" lang:en is:verified",
                    'start_time': '2006-07-01T00:00:00Z',
                    'end_time': '2023-01-01T00:00:00Z',
                    'max_results': "500",
                    'sort_order':'recency',
                    'expansions':'author_id', #,geo.place_id,attachments.media_keys', #'in_reply_to_user_id,entities.mentions.username,referenced_tweets.id.author_id
                    #'place.fields':'contained_within,country,country_code,full_name,geo,id,name,place_type',
                    'tweet.fields':'author_id,created_at,entities,geo,id,in_reply_to_user_id,lang,public_metrics,referenced_tweets,conversation_id',
                    'user.fields':'created_at,id,name,username,location',
                    #'media.fields':'media_key,type,url,height,width,public_metrics',
                    'next_token': None
                    }
    print("Getting full archive tweets for: " + file)
    full_archive_search.get_tweets_by_user(file, query_params, export_file)
    '''

    ###### fill in other information for the above tweets
    
    print("Getting author usernames....")
    input_file = EXPORT_FOLDER + file + ".csv"
    export_file = EXPORT_FOLDER + file + "_wusername.csv"
    user_lookup.get_username(input_file, export_file)

    print("Getting reply usernames....")
    input_file = EXPORT_FOLDER + file + "_wusername.csv"
    export_file = EXPORT_FOLDER + file + "_wreply.csv"
    user_lookup.get_reply_username(input_file, export_file)

    print("Getting reference tweet user id....")
    input_file = EXPORT_FOLDER + file + "_wreply.csv"
    export_file = EXPORT_FOLDER + file + "_wreference.csv"
    tweet_lookup.get_reference_tweet_id(input_file, export_file)

    print("Getting reference usernames....")
    input_file = EXPORT_FOLDER + file + "_wreference.csv"
    export_file = EXPORT_FOLDER + file + "_wreferencename.csv"
    user_lookup.get_reference_username(input_file, export_file)

    sleep(60*60)

