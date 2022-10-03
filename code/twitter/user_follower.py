
import requests
import os
import json
import pandas as pd
import numpy as np
from time import sleep

BEARER_TOKEN = os.environ.get("BEARER_TOKEN")

def create_url_followers(user_ids):
    # Specify the usernames that you want to lookup below
    # You can enter up to 100 comma-separated values.
    # User fields are adjustable, options include:
    # created_at, description, entities, id, location, name,
    # pinned_tweet_id, profile_image_url, protected,
    # public_metrics, url, username, verified, and withheld
    # url = "https://api.twitter.com/2/users/by?{}&{}".format(usernames, user_fields)
    url = "https://api.twitter.com/2/users/{}/followers".format(user_ids)
    #url = "https://api.twitter.com/1.1/users/lookup.json?user_id=}"
    return url

def create_url_metrics(username):
    url = "https://api.twitter.com/2/users/by/username/{}".format(username)
    return url
    

def bearer_oauth(r):
    """
    Method required by bearer token authentication.
    """
    r.headers["Authorization"] = f"Bearer {BEARER_TOKEN}"
    r.headers["User-Agent"] = "v2UserLookupPython"
    return r

def connect_to_endpoint(url, params):
    response = requests.request("GET", url, auth=bearer_oauth, params=params)
    print(response.status_code)
    if response.status_code != 200:
        raise Exception(response.status_code, response.text)
    return response.json()

def jason_to_df_followers(json_response):
    followers = [] 
    for i in range(len(json_response['data'])):
        followers.append([json_response['data'][i]['id'], 
                          json_response['data'][i]['username'], 
                          json_response['data'][i]['name']])
    followers = pd.DataFrame(followers, columns=['author_id','username','name'])
        
    return followers


def get_user_followers(user_id, folder):
    """
    Pull tweets and and put them in a text file.
    """
    export_file = folder + "followers/user_"+username+'.csv'
    query_params = {
                'max_results': "1000",
                'pagination_token': None
                }
    
    url = create_url_followers(str(user_id))
    json_response = connect_to_endpoint(url, query_params)
    print(json_response)
    
    followers = jason_to_df_followers(json_response)
    
    followers_all = followers.copy()
    counter = 1
    followers_counter = json_response["meta"]["result_count"]
    print(counter, "Number of followers:", followers_counter)
    #print("reached limit. Did not get all tweets")
    followers_all.to_csv(export_file)

    print(json_response["meta"])
    
    while "next_token" in json_response["meta"].keys():
        sleep(3)
        query_params["pagination_token"] = json_response["meta"]["next_token"]
        
        #json_response = connect_to_endpoint(url)
        json_response = connect_to_endpoint(url, query_params)
        followers = jason_to_df_followers(json_response)
        followers_all = pd.concat([followers_all, followers], axis=0)
        counter += 1
        followers_counter += json_response["meta"]["result_count"]
        print(username, " Request:", counter, " N followers:", followers_counter)
            
        followers_all.to_csv(export_file)
        
    print("done")
    
    return followers_all


    


def get_user_public_metrics(username, query_params, export_file):
    """
    Pull tweets and and put them in a text file.
    """
    url = create_url_metrics(str(username))
    json_response = connect_to_endpoint(url, query_params)
    
    followers = jason_to_df_followers(json_response)
    
    followers_all = followers.copy()
    counter = 1
    followers_counter = json_response["meta"]["result_count"]
    print(counter, "Number of followers:", followers_counter)
    #print("reached limit. Did not get all tweets")
    followers_all.to_csv(export_file)

    print(json_response["meta"])
    
    while "next_token" in json_response["meta"].keys():
        sleep(3)
        query_params["pagination_token"] = json_response["meta"]["next_token"]
        
        #json_response = connect_to_endpoint(url)
        json_response = connect_to_endpoint(url, query_params)
        followers = jason_to_df_followers(json_response)
        followers_all = pd.concat([followers_all, followers], axis=0)
        counter += 1
        followers_counter += json_response["meta"]["result_count"]
        print(username, " Request:", counter, " N followers:", followers_counter)
            
        followers_all.to_csv(export_file)
        
    print("done")
    
    return followers_all
