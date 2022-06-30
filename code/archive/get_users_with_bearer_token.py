import requests
import os
import json
import pandas as pd 

# To set your enviornment variables in your terminal run the following line:
# export 'BEARER_TOKEN'='<your_bearer_token>'
bearer_token = os.environ.get("BEARER_TOKEN")


def create_url(users, fields):
    # Specify the usernames that you want to lookup below
    # You can enter up to 100 comma-separated values.
    usernames = "usernames=" + users
    user_fields = "user.fields=" + fields
    # User fields are adjustable, options include:
    # created_at, description, entities, id, location, name,
    # pinned_tweet_id, profile_image_url, protected,
    # public_metrics, url, username, verified, and withheld
    url = "https://api.twitter.com/2/users/by?{}&{}".format(usernames, user_fields)
    return url


def bearer_oauth(r):
    """
    Method required by bearer token authentication.
    """
    r.headers["Authorization"] = f"Bearer {bearer_token}"
    r.headers["User-Agent"] = "v2UserLookupPython"
    return r


def connect_to_endpoint(url):
    response = requests.request("GET", url, auth=bearer_oauth,)
    print(response.status_code)
    if response.status_code != 200:
        raise Exception(
            "Request returned an error: {} {}".format(
                response.status_code, response.text
            )
        )
    return response.json()


def search_by_user():
    users = "chanders4"
    fields = "created_at,description,entities,id,location,name,pinned_tweet_id,profile_image_url,protected,public_metrics,url,username,verified,withheld"
    folder = "/Users/lingchm/Documents/Github/us_sodium_policies/data/twitter/"
    url = create_url(users, fields)
    response = connect_to_endpoint(url)
    df = pd.DataFrame(response['data'])
    df.to_csv(folder+'user_chanders4.csv')
    print("Data shape:", df.shape)
    print("Exported to", folder)
    
if __name__ == "__main__":
    search_by_user()