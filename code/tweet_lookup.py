
import requests
import os
import json
import pandas as pd
from time import sleep
import numpy as np

# To set your enviornment variables in your terminal run the following line:
# export 'BEARER_TOKEN'='<your_bearer_token>'
BEARER_TOKEN = "AAAAAAAAAAAAAAAAAAAAAOzpeAEAAAAAzb%2FX4CQSTJ6wGFZLI3UK%2F1DHUa8%3D8UhFs7G9kuwBr9nycPKyph3xDwDgx0apMdNsRhpRYmEZN1yQeh"



def create_url(lookup_string):
    tweet_fields = "user.fields=id,username"
    expansions = "expansions=author_id"
    # Tweet fields are adjustable.
    # Options include:
    # attachments, author_id, context_annotations,
    # conversation_id, created_at, entities, geo, id,
    # in_reply_to_user_id, lang, non_public_metrics, organic_metrics,
    # possibly_sensitive, promoted_metrics, public_metrics, referenced_tweets,
    # source, text, and withheld
    # You can adjust ids to include a single Tweets.
    # Or you can add to up to 100 comma-separated IDs
    url = "https://api.twitter.com/2/tweets?{}&{}&{}".format(lookup_string, tweet_fields,expansions)
    return url



def bearer_oauth(r):
    """
    Method required by bearer token authentication.
    """
    r.headers["Authorization"] = f"Bearer {BEARER_TOKEN}"
    r.headers["User-Agent"] = "v2UserLookupPython"
    return r


def connect_to_endpoint(url):
    response = requests.request("GET", url, auth=bearer_oauth,)
    #print(response.status_code)
    if response.status_code != 200:
        raise Exception(
            "Request returned an error: {} {}".format(
                response.status_code, response.text
            )
        )
    return response.json()


def get_tweet_username(tweet_ids):
    
    # prepare lookup string format
    lookup_string = "ids="
    for tweet_id in tweet_ids[:-1]:
        lookup_string = lookup_string + tweet_id + ","
    lookup_string += tweet_ids[-1]

    url = create_url(lookup_string)
    json_response = connect_to_endpoint(url)
    #print(json.dumps(json_response, indent=4, sort_keys=True))

    return json_response

if __name__ == "__main__":
    
    ## Lookup username of in_reply_to_user_id
    
    usernames = {"Public agencies": ["US_FDA","_DCHealth","CDCgov","CDCDirector",
                                     "CDCFound", "CDC_eHealth",
                                     "Departmentofh14","MillionHeartsUS",
                                     "nycHealthy","PHIdotorg","NIH",
                                     "USDA", "USDANutrition", "TeamNutrition",
                                     "NationalCACFP", "SNAP_Ed", "BeAFoodHero", "NatWICAssoc"],
                 "NGO":["ResolveTSL"],
                 "Research and evaluation organization": [
                      "HarvardChanSPH","HarvardHealth","Harvardmed",
                       "HopkinsMedicine","JohnsHopkinsSPH", 
                       "uwsph","WUSTLmed", 
                       "YaleSPH","YaleMed",
                       "ColumbiaMSPH", "ColumbiaMed"],
                 "Experts": ["chanders4","KBibbinsDomingo","braun_lynne","jesse8850",
                             "eantman","SimonCapewell99","kcferdmd","GardnerPhD","MichelJoffres",
                             "dmljmd","Dmozaffarian","BruceNeal1","DrSaccoNeuro"],
                "Professional and advocacy assotiations": [
                    "MonellSc","ASPCardio","CardioNerds",
                    "American_Heart","AHAScience", "theNAMedicine"],
                "International influencers": [
                    "WorldHyperLeag", "worldheartfed", "actiononsalt", "WASHSALT", "WHO"],
                "Individual influencers": ["DietHeartNews","HealthyHeart4u",
                                           "healthstepsonly","DailyHealthTips",
                                           "FoodInsight","DailyHealthTips",
                                           "DrTomFrieden"],
                "Politicians": ["HillaryClinton", "MichelleObama", "letsmove",
                                "JoeBiden", "BarackObama"],
                
    }
    usernames_list = []
    total_usernames = 0
    for category in usernames.keys():
        total_usernames += len(usernames[category])
        usernames_list.extend(usernames[category])
    print("total accounts:", total_usernames)
    
    folder = "/Users/lingchm/Documents/Github/us_sodium_policies/data/twitter/"
    # SimonCapewell99
    
    # first round 
    for username in usernames_list:
        export_file = folder + "wreference/user_"+username+'.csv'
        
        if os.path.isfile(export_file):
            print("Skipping for", username)
            continue
        
        if username in ["HillaryClinton", "MichelleObama", "letsmove","JoeBiden", "BarackObama"]:
            continue
        
        print("Getting retweet for ", username)
        data = pd.read_csv(folder + "wreply/user_" + username + ".csv")
        
        # clean list of reference ids 
        reference_ids = []
        unique_reference_ids = []
        for i in range(data.shape[0]):
            if type(data['references'].iloc[i]) == str and len(data['references'].iloc[i]) > 2: #data['retweet'].iloc[i]
                ids = str(data['references'].iloc[i][2:-2]).split("', '")
                reference_ids.append(ids)
                #if data['retweet'].iloc[i] == 1:
                unique_reference_ids.extend(ids)
            else:
                reference_ids.append(None)
        data['reference_ids'] = reference_ids
        unique_reference_ids = np.unique(unique_reference_ids).tolist()
        print("Number of reference ids:", len(unique_reference_ids))
        
        # look up reference ids in batch of 100
        print("     Total of reference ids:", len(unique_reference_ids))
        data_ids = pd.DataFrame(columns=["reference_text",
                                         "reference_userid"], index=unique_reference_ids)
        l, k = 0, 0
        while l < len(unique_reference_ids):
            json_response = get_tweet_username(unique_reference_ids[l:(l+100)])
            for tweet_data in json_response['data']:
                data_ids.loc[str(tweet_data['id']), "reference_text"] = tweet_data['text']
                data_ids.loc[str(tweet_data['id']), "reference_userid"] = tweet_data['author_id']
            l += 100
            k += 1
            print("     Request", k, " Tweet", l)
            sleep(5)

        reference_usernames = []
        data_ids = data_ids[~data_ids['reference_userid'].isnull()]
        for i in range(data.shape[0]):
            ids = data["reference_ids"].iloc[i] 
            if ids is not None:
                usernames = []
                for id_ in ids:
                    if id_ in data_ids.index:
                        usernames.append(data_ids.loc[id_, "reference_userid"])
                usernames = np.unique(usernames).tolist()
                if len(usernames) > 0:
                    reference_usernames.append(usernames)
                else:
                    reference_usernames.append(None)
            else:
                reference_usernames.append(None)
        data["reference_userids"] = reference_usernames
        
        #data_ids['reference_id'] = data_ids.index.astype(str)
        #data_final = data.merge(data_ids, how="left", on=["reference_id"])
        
        data.to_csv(export_file, index=False)
        
    '''
    # second round 
    
    for username in usernames_list:
        print("Getting retweet for ", username)
        data = pd.read_csv(folder + "wreference/user_" + username + ".csv")
    
        # clean list of reference ids 
        reference_ids = []
        for i in range(data.shape[0]):
            if len(data['references'].iloc[i]) > 2: #data['retweet'].iloc[i]
                reference_ids.append(data['references'].iloc[i][2:-2])
            else:
                reference_ids.append(None)
        data['reference_id'] = reference_ids
        
        # clean list of reference ids that still need to be processed
        unique_reference_ids = []
        df = data[data["reference_text"].isnull()]
        for i in range(df.shape[0]):
            if len(df['references'].iloc[i]) > 2: #data['retweet'].iloc[i]
                unique_reference_ids.append(df['reference_id'].iloc[i])
        
        # look up reference ids in batch of 100
        print("     Total of reference ids:", len(unique_reference_ids))
        data_ids = pd.DataFrame(columns=["reference_text2",
                                         "reference_userid2"], index=unique_reference_ids)
        l, k = 0, 0
        while l < len(unique_reference_ids):
            json_response = get_tweet_username(unique_reference_ids[l:(l+100)])
            for tweet_data in json_response['data']:
                data_ids.loc[str(tweet_data['id']), "reference_text2"] = tweet_data['text']
                data_ids.loc[str(tweet_data['id']), "reference_userid2"] = tweet_data['author_id']
            l += 100
            k += 1
            print("     Request", k, " Tweet", l)
            sleep(5)

        data_ids['reference_id'] = data_ids.index
        data_final = data.merge(data_ids, how="left", on=["reference_id"])
        
        data_final.to_csv(folder + "wreference/user_"+username+'2.csv', index=False)
    '''
    
'''
Deleted
US__FDA: 1531651719339380736,1531737768858206209,1529917804727656448,1530254963368239105,1529845467768573954,1530254954849611777,1527386200402796545,1527726955013058561,1527726953234677761,1527281744709296128
CDCgov: 1237806362039668738, 1237803812678590464,1238487810874789889,523505868550447104       
'''