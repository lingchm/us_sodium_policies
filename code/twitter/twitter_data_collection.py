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

import tweet_lookup
import user_follower
import user_lookup
import full_archive_search

BEARER_TOKEN = os.environ.get("BEARER_TOKEN")


# collect one data of all users 
usernames = {"Public agencies": {"FDA": ["US_FDA", 'FDAfood'],
                                 "DC Department of Health": ["_DCHealth"],
                                 "CDC": ["CDCgov","CDCDirector","CDCFound", "CDC_eHealth"],
                                 "HHS": ["Departmentofh14", "MillionHeartsUS", "HHSGov"],
                                 "NYC Department of Health": ["nycHealthy"],
                                 "PHI": ["PHIdotorg"],
                                 "NIH": ["NIH"],
                                 "USDA": ["USDA", "USDANutrition", "TeamNutrition","NationalCACFP", "SNAP_Ed", "BeAFoodHero","NatWICAssoc"]
                                },
                 "Research and evaluation organization": {
                       "Harvard": ["HarvardChanSPH","HarvardHealth","Harvardmed", "HSPHnutrition"],
                       "John Hokpins": ["HopkinsMedicine","JohnsHopkinsSPH"], 
                       "Univ. Washington": ["uwsph","WUSTLmed"], 
                       "Yale": ["YaleSPH","YaleMed"],
                       "Columbia Univ.": ["ColumbiaMSPH", "ColumbiaMed"]},
                 "Experts": {
                             "Cheryl Anderson": ["chanders4"],
                             "Kirsten Bibbins-Domingo": ["KBibbinsDomingo"],
                             "Lynne T. Braun":["braun_lynne"],
                             "Mariell Jessup": ["jesse8850"],
                             "Elliott M. Antman": ["eantman"],
                             "Simon Capewell": ["SimonCapewell99"],
                             "Keith C. Ferdinand": ["kcferdmd"],
                             "Christopher Gardner": ["GardnerPhD"],
                             "Michel Joffres": ["MichelJoffres"],
                             "Donald M. Lloyd-Jones": ["dmljmd"],
                             "Dariush Mozaffarian": ["Dmozaffarian"],
                             "Bruce Neal": ["BruceNeal1"],
                             "Ralph L. Sacco": ["DrSaccoNeuro"]},
                "Professional and advocacy assotiations": {
                      "Monell Center": ["MonellSc"],
                      "ASP Cardio": ["ASPCardio"],
                      "American Public Health Association": ['PublicHealth'],
                      "Cardio Nerds": ["CardioNerds"],
                      "American Heart Association": ["American_Heart","AHAScience"], 
                      "National Academy of Medicine": ["theNAMedicine"],
                      "Center for Science in the Public Interest": ["CSPI"]},
                "International influencers": {
                    "World Hypertension League": ["WorldHyperLeag"], 
                    "World Heart Federation": ["worldheartfed"],
                    "World Action on Salt": ["WASHSALT","actiononsalt"], 
                    "WHO": ["WHO"]},
                "Individual influencers": {
                    "Alan Watson": ["DietHeartNews"],
                    "Healthy Heart Market": ["HealthyHeart4u"],
                    "Health Steps 24/7": ["healthstepsonly"],
                    "Daily Health Tips": ["DailyHealthTips"],
                    "FoodInsight.org": ["FoodInsight"],
                    "Tom Frieden": ["DrTomFrieden"]},
                "Politicians":{
                     "Hillary Clinton": ["HillaryClinton"],
                     "Michelle Obama": ["MichelleObama", "letsmove"],
                     "Barack Obama": ["BarackObama"],
                     "Joe Biden": ["JoeBiden"]
                     },
                "Philanthropies": {
                    "Resolve to Save Lives": ["ResolveTSL"],
                    "Bloomberg Philanthropies": ["BloombergDotOrg"], #Bloomberg Philanthropies Invests Additional $115 Million in Resolve to Save Lives To Continue Preventing Deaths from Heart Disease
                    "the Bill & Melinda Gates Foundation": ["gatesfoundation"],
                    "Rockefeller foundation": ["RockefellerFdn"],
                    "Whole Kids Foundation": ["WholeKidsFnd"],
                    },
                "Food manufacturers":{
                    "Nestle": ["NestleUSA"],
                    "Tyson Foods": ["TysonFoods"],
                    "General Mills": ["GeneralMills"],
                    "ConAgra Foods": ["ConagraBrands"],
                    "Kelloggs": ["KelloggCompany"]
                    }
                }


usernames_list = []
organization_list = []
labels = {}

for category in usernames.keys():
    organization_list.extend(usernames[category].keys())
    for organization in usernames[category].keys():
        usernames_list.extend(usernames[category][organization])
        for username in usernames[category][organization]:
            labels[username] = organization
            
print("total accounts:", len(usernames_list))
print("total organizations:", len(organization_list))
print("total accounts:", len(usernames_list))

  
folder = "/Users/lingchm/Documents/Github/us_sodium_policies/data/twitter/"


for username in usernames_list:
    
    # full archive search
    export_file = folder + "original/user_" + username+'.csv'
    
    if os.path.isfile(export_file):
        print("Skipping for", username)
        continue
        
    if username in ["HillaryClinton", "MichelleObama", "letsmove","JoeBiden", "BarackObama"]:
        continue
    
    query_params = {'query': 'from:'+username,
                'start_time': '2006-07-01T00:00:00Z', #'2006-07-01T00:00:00Z',
                'end_time': '2022-05-31T20:17:22Z',
                'max_results': "500",
                'sort_order':'recency',
                'expansions':'author_id,geo.place_id', #'in_reply_to_user_id,entities.mentions.username,referenced_tweets.id.author_id
                'place.fields':'contained_within,country,country_code,full_name,geo,id,name,place_type',
                'tweet.fields':'author_id,created_at,entities,geo,id,in_reply_to_user_id,lang,public_metrics,referenced_tweets,text',
                'user.fields':'created_at,description,id,name,username',
                'next_token': None
                }
        
    if username in ["HillaryClinton", "MichelleObama", "letsmove","JoeBiden", "BarackObama"]:
        #query_params['query'] = '(sodium OR salt OR food OR health) from:'+username
        query_params['query'] = 'health from:'+username
        continue
    
    print("Getting full archive tweets for: " + username)
    full_archive_search.get_tweets_by_user(username, query_params, export_file)
    
    ## get reply username 
    user_lookup.get_reply_username(username, folder)
    
    ## Get reference tweets 
    tweet_lookup.get_reference_tweet_id(username, folder)
        
    ## get reply username 
    user_lookup.get_reference_username(username, folder)
    
    ## get list of follower names
    #data = pd.read_csv(folder + "original/user_" + username + ".csv")
    #user_id = data.iloc[0,:]['author_id']
    #user_follower.get_user_followers(user_id, folder)
    
    sleep(5)
    


'''
# get follower and friend counts 
    query_params = {
                'user.fields': "id,name,username,public_metrics,location,created_at"
                }
    public_metrics_all = pd.DataFrame(index=usernames_list, 
                                      columns=["id", "name", "location",'created_at',
                                               "followers_count", "following_count",
                                               "tweet_count", "listed_count"])
    usernames_list = ['FDAfood','PublicHealth','HHSGov', 'CSPI', 'HSPHnutrition']
    
    for username in usernames_list:
        print("Getting followers for ", username)
        url = create_url_metrics(str(username))
        json_response = connect_to_endpoint(url, query_params)
        public_metrics_all.loc[username, 'id'] = json_response['data']['id']
        public_metrics_all.loc[username, 'name'] = json_response['data']['name']
        public_metrics_all.loc[username, 'created_at'] = json_response['data']['created_at']
        if 'location' in json_response['data'].keys():
            public_metrics_all.loc[username, 'location'] = json_response['data']['location']
        public_metrics_all.loc[username, 'followers_count'] = json_response['data']['public_metrics']['followers_count']
        public_metrics_all.loc[username, 'following_count'] = json_response['data']['public_metrics']['following_count']
        public_metrics_all.loc[username, 'tweet_count'] = json_response['data']['public_metrics']['tweet_count']
        public_metrics_all.loc[username, 'listed_count'] = json_response['data']['public_metrics']['listed_count']

    public_metrics_all.index.name = "username"
    public_metrics_all['year'] = pd.DatetimeIndex(public_metrics_all['created_at']).year
    public_metrics_all.to_csv(folder + "followers/user_summary_metrics2.csv")
'''
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
        