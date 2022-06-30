import requests
import os
import pandas as pd
from time import sleep
import copy

'''
Query params: https://developer.twitter.com/en/docs/twitter-api/tweets/search/api-reference/get-tweets-search-recent

'''


# To set your environment variables in your terminal run the following line:
# export 'BEARER_TOKEN'='<your_bearer_token>'
# BEARER_TOKEN = "AAAAAAAAAAAAAAAAAAAAAOzpeAEAAAAAzb%2FX4CQSTJ6wGFZLI3UK%2F1DHUa8%3D8UhFs7G9kuwBr9nycPKyph3xDwDgx0apMdNsRhpRYmEZN1yQeh"
BEARER_TOKEN = os.environ.get("BEARER_TOKEN")
SEARCH_URL = "https://api.twitter.com/2/tweets/search/all"
   
# Optional params: start_time,end_time,since_id,until_id,max_results,next_token,
# expansions,tweet.fields,media.fields,poll.fields,place.fields,user.fields
#query_params = {'query': '(from:twitterdev -is:retweet) OR #twitterdev','tweet.fields': 'author_id'}


def bearer_oauth(r):
    """
    Method required by bearer token authentication.
    """
    r.headers["Authorization"] = f"Bearer {BEARER_TOKEN}"
    r.headers["User-Agent"] = "v2FullArchiveSearchPython"
    return r


def connect_to_endpoint(url, params):
    response = requests.request("GET", SEARCH_URL, auth=bearer_oauth, params=params)
    print(response.status_code)
    if response.status_code != 200:
        raise Exception(response.status_code, response.text)
    return response.json()


def jason_to_df(json_response):
    tweets = pd.DataFrame(columns=['author_id','username','id','created_at','lang','text','retweet_count','reply_count','like_count', 
                                   'quote_count','source', 'mentions', 'hashtags','reply','references','retweet','contain_sodium','contain_health'])
    
    for i in range(len(json_response['data'])):
        
        mentions, hashtags, references, reply, source = [], [], [], None, None
        if 'entities' in json_response['data'][i].keys():
            if 'mentions' in json_response['data'][i]['entities'].keys():
                for mention in json_response['data'][i]['entities']['mentions']:
                    mentions.append(mention['username'])
            if 'hashtags' in json_response['data'][i]['entities'].keys():
                for hashtag in json_response['data'][i]['entities']['hashtags']:
                    hashtags.append(hashtag['tag'])
        if "in_reply_to_user_id" in json_response['data'][i].keys():
            reply = json_response['data'][i]['in_reply_to_user_id']
        if "source" in json_response['data'][i].keys():
            source = json_response['data'][i]['source']
        # Reference: want to involve all entities involved, but using in_reply_to_user_id only creates a list that do not match the order of 'data' list
        if 'referenced_tweets' in json_response['data'][i].keys():
            for j in range(len(json_response['data'][i]['referenced_tweets'])):
                references.append(json_response['data'][i]['referenced_tweets'][j]['id'])
        retweet = 1 if json_response['data'][i]['text'][:2] == "RT" else 0
        contain_sodium = 1 if ("sodium" in json_response['data'][i]['text']) or ("salt" in json_response['data'][i]['text']) else 0
        contain_health = 1 if ("health" in json_response['data'][i]['text']) else 0
        tweets.loc[len(tweets.index)] = [json_response['data'][i]['author_id'],
                                         json_response['includes']['users'][0]['username'],
                                         json_response['data'][i]['id'],
                                         json_response['data'][i]['created_at'],
                                         json_response['data'][i]['lang'],
                                        json_response['data'][i]['text'],
                                        json_response['data'][i]['public_metrics']['retweet_count'],
                                        json_response['data'][i]['public_metrics']['reply_count'],
                                        json_response['data'][i]['public_metrics']['like_count'],
                                        json_response['data'][i]['public_metrics']['quote_count'],
                                        source, mentions, hashtags, reply, references,
                                        retweet, contain_sodium, contain_health]
        
    return tweets
    

def get_tweets_by_user(username, export_file):
    """
    Pull tweets and and put them in a text file.
    """
    
    query_params = {'query': 'from:'+username,
                'start_time': '2006-07-01T00:00:00Z',
                'end_time': '2022-06-01T00:00:00Z',
                'max_results': "100",
                'sort_order':'recency',
                'expansions':'author_id,geo.place_id', #'in_reply_to_user_id,entities.mentions.username,referenced_tweets.id.author_id
                'place.fields':'contained_within,country,country_code,full_name,geo,id,name,place_type',
                'tweet.fields':'author_id,created_at,entities,geo,id,in_reply_to_user_id,lang,public_metrics,referenced_tweets,text',
                'user.fields':'created_at,description,id,name,username',
                'next_token': None
                }

    json_response = connect_to_endpoint(SEARCH_URL, query_params)
    tweets = jason_to_df(json_response)
    tweets_all = tweets.copy()
    
    counter = 1
    tweets_counter = json_response["meta"]["result_count"]
    print(username, counter, "Number of tweets:", tweets_counter)
        
    while "next_token" in json_response["meta"].keys():
        sleep(5)
        query_params["next_token"] = json_response["meta"]["next_token"]
        # in case not all are processed 
        try:
            json_response = connect_to_endpoint(SEARCH_URL, query_params)
            tweets = jason_to_df(json_response)
            tweets_all = pd.concat([tweets_all, tweets], axis=0)
            counter += 1
            tweets_counter += json_response["meta"]["result_count"]
            print(username, counter, "Number of tweets:", tweets_counter)
        except:
            print("reached limit. Did not get all tweets")
        tweets_all.to_csv(export_file)
        
    print("done")
    
if __name__ == "__main__":
    
    usernames = {"Public agencies": ["US_FDA","CDCgov","CDCDirector",
                                     "Departmentofh14","CDCFund",
                                     "nycHealthy","PHIdotorg","NIH"],
                 "NGO":["ResolveTSL","theNAMedicine","WorldHyperLeag"],
                 "Research and evaluation organization": ["HarvardChanSPH",
                       "HopkinsMedicine","uwsph","HarvardHealth",
                       "JohnsHopkinsSPH", "YaleSPH","ColumbiaMSPH"],
                 "Experts": ["chanders4","KBibbinsDomingo","braun_lynne","jesse8850",
                             "eantman","SimonCapewell99","kcferdmd","GardnerPhD","MichelJoffres",
                             "dmljmd","Dmozaffarian","BruceNeal1","DrSaccoNeuro"],
                "Professional and advocacy assotiations": ["MonellSc","ASPCardio",
                            "actiononsalt","CardioNerds","American_Heart","AHAScience"],
                "Partnership": ["MillionHeartsUS","WASHSALT"],
                "Individual influencers": ["DietHeartNews","HealthyHeart4u",
                                           "healthstepsonly","DailyHealthTips",
                                           "FoodInsight","DailyHealthTips"]
        }

    # CDCgov 33072
    # PHIdotorg 23023 
    # HarvardChanSPH 31958
    # actiononsalt 10189
    # American_Heart 40722
    # "CDCFund", 
    #"ColumbiaMSPH",18780
    #DietHeartNews
    # FoodInsight

    usernames = ["nycHealthy","DrTomFrieden"]
    # nycHealthy
    # DrTomFrieden
    
    folder = "/Users/lingchm/Documents/Github/us_sodium_policies/data/twitter/"
    for username in usernames:
        export_file = folder + 'user_'+username+'.csv'
        get_tweets_by_user(username, export_file)
        sleep(15*60)
        
        