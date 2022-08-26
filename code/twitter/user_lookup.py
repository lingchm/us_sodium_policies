
import requests
import os
import json
import pandas as pd
import numpy as np

# To set your enviornment variables in your terminal run the following line:
# export 'BEARER_TOKEN'='<your_bearer_token>'


def create_url(usernames, user_fields = "user.fields=id,username"):
    # Specify the usernames that you want to lookup below
    # You can enter up to 100 comma-separated values.
    # User fields are adjustable, options include:
    # created_at, description, entities, id, location, name,
    # pinned_tweet_id, profile_image_url, protected,
    # public_metrics, url, username, verified, and withheld
    # url = "https://api.twitter.com/2/users/by?{}&{}".format(usernames, user_fields)
    url = "https://api.twitter.com/2/users?{}".format(usernames)
    #url = "https://api.twitter.com/1.1/users/lookup.json?user_id=}"
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


def get_user_username(usernames):
    
    # prepare lookup string format
    lookup_string = "ids="
    for username in usernames[:-1]:
        lookup_string = lookup_string + username + ","
    lookup_string += usernames[-1]
    #print(lookup_string)
    
    url = create_url(lookup_string)
    json_response = connect_to_endpoint(url)
    #print(json.dumps(json_response, indent=4, sort_keys=True))

    return json_response


def get_reply_username(username, folder):
    print("Getting reply usernames for ", username)
    data = pd.read_csv(folder + "original/user_" + username + ".csv")
    export_file = folder + "wreply/user_"+username+'.csv'
    N  = data.shape[0]
        
     # remove na id
     # sometimes in_reply_to_user_id has mixed in conversation or tweet ids, remove
    reference_ids = data[~data['reply'].isnull()]['reply'].unique()
    print("      Total of reference tweet ids:", reference_ids[reference_ids > 1e15].shape[0])
    reference_ids = reference_ids[reference_ids < 1e15]
    reference_ids = reference_ids.astype(int).astype(str)
    print("     Total of reference user ids:",reference_ids.shape[0])
       
    data_ids = pd.DataFrame(columns=["reply_username"], index=reference_ids)
    l = 0
    while l < reference_ids.shape[0]:
        json_response = get_user_username(reference_ids[l:(l+100)])
        for user_data in json_response['data']:
            data_ids.loc[str(user_data['id']), "reply_username"] = user_data['username']
        l += 100
        
    data_ids['reply'] = data_ids.index.astype(float)
    data_final = data.merge(data_ids, how="left", on=["reply"])
    print("     Total of reply user ids:",reference_ids.shape[0])
    print("     Total reply usernames: ", len(data_final['reply_username'].unique()))
    data_ids.shape[0]
    # data_final[~data_final['reply'].isnull()][['reply', 'reply_username']]
    data_final.to_csv(export_file, index=False)
        
    assert data_final.shape[0] == N, "Error check number of rows" + username

    return 


def get_reference_username(username, folder):
    
    print("Getting reference usernames for ", username)
    export_file = folder + "wreferencename/user_"+username+'.csv'
    data = pd.read_csv(folder + "wreference/user_" + username + ".csv")
    
    # remove na id
    # sometimes in_reply_to_user_id has mixed in conversation or tweet ids, remove
    unique_reference_ids = []
    df = data[~data['reference_userids'].isnull()]
    for i in range(df.shape[0]):
        ids = str(df.iloc[i]['reference_userids'][2:-2]).split("', '")
        unique_reference_ids.extend(ids)
    unique_reference_ids = np.unique(unique_reference_ids).tolist()
    print("Number of reference ids:", len(unique_reference_ids))

    data_ids = pd.DataFrame(columns=["reference_username"], index=unique_reference_ids)
    l, k = 0, 0
    while l < len(unique_reference_ids):
        json_response = get_user_username(unique_reference_ids[l:(l+100)])
        for user_data in json_response['data']:
            data_ids.loc[str(user_data['id']), "reference_username"] = user_data['username']
        l += 100
        k += 1
        print("     Request", k, " Tweet", l)
        
    # clean list of reference ids 
    reference_ids = []
    unique_reference_ids = []
    for i in range(data.shape[0]):
        if type(data['reference_userids'].iloc[i]) == str: #data['retweet'].iloc[i]
            ids = str(data['reference_userids'].iloc[i][2:-2]).split("', '")
            reference_ids.append(ids)
            #if data['retweet'].iloc[i] == 1:
            unique_reference_ids.extend(ids)
        else:
            reference_ids.append(None)
    data['reference_userids'] = reference_ids
        
    reference_usernames = []
    for i in range(data.shape[0]):
        ids = data["reference_userids"].iloc[i] 
        if ids is not None:
            usernames = []
            for id_ in ids:
                if id_ in data_ids.index: 
                    usernames.append(data_ids.loc[id_, "reference_username"])
            usernames = np.unique(usernames).tolist()
            if len(usernames) > 0:
                reference_usernames.append(usernames)
            else:
                reference_usernames.append(None)
        else:
            reference_usernames.append(None)
    data["reference_usernames"] = reference_usernames
    # data_final[~data_final['reply'].isnull()][['reply', 'reply_username']]
    data.to_csv(export_file, index=False)

    return

        
