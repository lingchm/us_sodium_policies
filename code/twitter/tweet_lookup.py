
import requests
import os
import json
import pandas as pd
from time import sleep
import numpy as np

BEARER_TOKEN = os.environ.get("BEARER_TOKEN")
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

def get_reference_tweet_id(username, folder):
    
    print("Getting reference tweets for ", username)
    data = pd.read_csv(folder + "wreply/user_" + username + ".csv")
    export_file = folder + "wreference/user_"+username+'.csv'
    
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
    data_ids = pd.DataFrame(columns=["reference_text","reference_userid"], index=unique_reference_ids)
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
    
    return
