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
from utils import tweet_lookup 
from utils import user_follower
from utils import user_lookup 
from utils import full_archive_search 

BEARER_TOKEN = os.environ.get("BEARER_TOKEN")
EXPORT_FOLDER = os.environ.get("EXPORT_FOLDER")

# collect one data of all users 
usernames = {"Public agencies": {"FDA": ["US_FDA", 'FDAfood'],
                                 "CDC": ["CDCgov","CDCDirector","CDCFound", "CDC_eHealth"],
                                 "HHS": ["Departmentofh14", "MillionHeartsUS", "HHSGov"],
                                 "NYC Department of Health": ["nycHealthy"],
                                 "PHI": ["PHIdotorg"],
                                 "NIH": ["NIH"],
                                 "White House Office of S&T Policy": ["WHOSTP"],
                                 "USDA": ["USDA", "USDANutrition", "TeamNutrition","NationalCACFP", "SNAP_Ed", "BeAFoodHero","NatWICAssoc"]
                                },
                 "Research and evaluation organizations": {
                       "Harvard": ["HarvardChanSPH","HarvardHealth","Harvardmed", "HSPHnutrition"],
                       "John Hokpins": ["HopkinsMedicine","JohnsHopkinsSPH"], 
                       "Univ. Washington": ["uwsph","UWMedicine"], 
                       "Yale": ["YaleSPH","YaleMed"],
                       "Columbia Univ.": ["ColumbiaMSPH", "ColumbiaMed"],
                       "Univ. Oxford": ["NDMOxford", "UniofOxford"],
                       "Univ. College London": ["UCLeHealth", "BScPopHealth"],
                       "Stanford": ["SJPHonline","StanfordMed"]
                       },
                 "Experts": {
                             "Cheryl Anderson": ["chanders4"],
                             "Kirsten Bibbins-Domingo": ["KBibbinsDomingo"],
                             "Lynne T. Braun":["braun_lynne"],
                             "Mariell Jessup": ["jesse8850"],
                             #"Elliott M. Antman": ["eantman"],
                             "Simon Capewell": ["SimonCapewell99"],
                             "Keith C. Ferdinand": ["kcferdmd"],
                             "Christopher Gardner": ["GardnerPhD"],
                             #"Michel Joffres": ["MichelJoffres"],
                             "Donald M. Lloyd-Jones": ["dmljmd"],
                             "Dariush Mozaffarian": ["Dmozaffarian"],
                             "Bruce Neal": ["BruceNeal1"],
                             "Ralph L. Sacco": ["DrSaccoNeuro"],
                             "Tom Frieden": ["DrTomFrieden"],
                             "Alexey Kulikov":["KulikovUNIATF"]
                             },
                "Professional and advocacy associations": {
                      "Monell Center": ["MonellSc"],
                      "ASP Cardio": ["ASPCardio"],
                      "American Public Health Association": ['PublicHealth'],
                      "Cardio Nerds": ["CardioNerds"],
                      "American Heart Association": ["American_Heart","AHAScience"], 
                      "National Academy of Medicine": ["theNAMedicine"],
                      "Center for Science in the Public Interest": ["CSPI"],
                      "Daily Health Tips": ["DailyHealthTips"],
                      "FoodInsight.org": ["FoodInsight"]
                    },
                "International organizations and initiatives": {
                    "World Hypertension League": ["WorldHyperLeag"], 
                    "World Heart Federation": ["worldheartfed"],
                    "World Action on Salt": ["WASHSALT","actiononsalt"], 
                    "WHO": ["WHO"],
                    "United Nations FAO": ["FAO"],
                    "Resolve to Save Lives": ["ResolveTSL"]},
                "Philanthropies": {
                    "Chan Zuckerberg Foundation": ["ChanZuckerberg"],
                    "Bloomberg Philanthropies": ["BloombergDotOrg"], #Bloomberg Philanthropies Invests Additional $115 Million in Resolve to Save Lives To Continue Preventing Deaths from Heart Disease
                    "the Bill & Melinda Gates Foundation": ["gatesfoundation"],
                    "Rockefeller foundation": ["RockefellerFdn"],
                    "Whole Kids Foundation": ["WholeKidsFnd"]
                    },
                "Food manufacturers":{
                    "Nestle": ["NestleUSA"],
                    "Tyson Foods": ["TysonFoods"],
                    "General Mills": ["GeneralMills"],
                    "ConAgra Foods": ["ConagraBrands"],
                    "Kelloggs": ["KelloggCompany"]
                    }
                }
#"Individual influencers": {
                #    "Alan Watson": ["DietHeartNews"],
                #    "Healthy Heart Market": ["HealthyHeart4u"],
                #    "Health Steps 24/7": ["healthstepsonly"],
                #    "Tom Frieden": ["DrTomFrieden"],
                #    "Alexey Kulikov":["KulikovUNIATF"]},
                #"Politicians":{
                #     "Hillary Clinton": ["HillaryClinton"],
                #     "Michelle Obama": ["MichelleObama", "letsmove"],
                #     "Barack Obama": ["BarackObama"],
                #     "Joe Biden": ["JoeBiden"]
                #     },
                
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

    
for username in usernames_list:
    
    # full archive search
    export_file = EXPORT_FOLDER + "/original/user_" + username+'.csv'
    
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
    print("Getting reply usernames for ", username)
    user_lookup.get_reply_username(EXPORT_FOLDER + "original/user_" + username + ".csv", 
                                   EXPORT_FOLDER + "wreply/user_" + username+'.csv')
    
    ## Get reference tweets 
    print("Getting reference tweets for ", username)
    tweet_lookup.get_reference_tweet_id(EXPORT_FOLDER + "wreply/user_" + username + ".csv",
                                        EXPORT_FOLDER + "wreference/user_"+username+'.csv')
        
    ## get reply username
    print("Getting reference usernames for ", username)
    user_lookup.get_reference_username(EXPORT_FOLDER + "wreference/user_" + username + ".csv",
                                       EXPORT_FOLDER + "wreferencename/user_" + username + '.csv')
    
    ## get list of follower names
    #data = pd.read_csv(folder + "original/user_" + username + ".csv")
    #user_id = data.iloc[0,:]['author_id']
    #user_follower.get_user_followers(user_id, folder)
    
    sleep(5)
    