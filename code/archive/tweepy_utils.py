#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jun 28 12:36:06 2022

@author: lingchm

TUtorial:
    - https://dev.to/twitterdev/a-comprehensive-guide-for-using-the-twitter-api-v2-using-tweepy-in-python-15d9

Query params: 
    - https://developer.twitter.com/en/docs/twitter-api/tweets/search/api-reference/get-tweets-search-recent

"""


import tweepy
import csv

# key 
client = tweepy.Client(bearer_token='AAAAAAAAAAAAAAAAAAAAAOzpeAEAAAAAzb%2FX4CQSTJ6wGFZLI3UK%2F1DHUa8%3D8UhFs7G9kuwBr9nycPKyph3xDwDgx0apMdNsRhpRYmEZN1yQeh')


## search for full archive 
limit = 10
query = 'from:chanders4 -is:retweet'
tweets = tweepy.Paginator(client.search_all_tweets, 
                              query=query,
                              start_time='2006-07-01T00:00:00Z',
                              end_time='2022-06-01T00:00:00Z',
                              tweet_fields=['id','created_at', 'geo','lang','context_annotations', 'public_metrics','text'], 
                              # user_fields=['profile_image_url'],
                              #place_fields=['place_type', 'geo'], 
                              #expansions=['author_id','geo.place_id'], 
                              max_results=limit).flatten(limit=limit)

tweets = tweepy.Cursor(client.search_all_tweets, 
                        query=query,
                        start_time='2006-07-01T00:00:00Z',
                        end_time='2022-06-01T00:00:00Z',
                        tweet_fields=['id','created_at', 'geo','lang','context_annotations', 'public_metrics','text'], 
                        max_results=limit).items()
    
# places = {p["id"]: p for p in tweets.includes['places']}
folder = "/Users/lingchm/Documents/Github/us_sodium_policies/data/twitter/"
csvFile = open(folder+'user_chanders4.csv', 'a')
csvWriter = csv.writer(csvFile)

#users = {u["id"]: u for u in tweets.includes['users']} 

for tweet in tweets:  
    csvWriter.writerow([tweet.author_id,
                        tweet.id,
                        tweet.created_at,
                        tweet.geo,
                        tweet.lang,
                        tweet.context_annotations,
                        tweet.public_metrics,
                        tweet.text,
                        tweet.text.encode('utf-8')])

csvFile.close()


### get user tweets
limit = 10
user_id = 'chanders4'
    
paginator = tweepy.Paginator(
    client.get_users_tweets,               # The method you want to use
    id="chanders4",                            # Some argument for this method
    exclude=['retweets', 'replies'],       # Some argument for this method
    start_time='2006-07-01T00:00:00Z',
    end_time='2022-06-01T00:00:00Z',
    max_results=limit                         # How many tweets per page
)
    
csvFile = open(folder+'user_chanders4.csv', 'a')
csvWriter = csv.writer(csvFile)

for tweet in paginator.flatten(limit=5):
    print(tweet)
    
    
    
    
while next_token is not None:
    users = {
        u[“id”]: u for u in response.includes[“users”]
        } # iterating through users in payload and adding them to users dict
   for tweet in tweets:
       tweet_text = tweet.text
       tweet_text = tweet_text.replace(",", " ")
       line = str(tweet.created_at)+','+tweet_text+'\n'
       
   response = client.get_users_tweets(id=uid,                                  

                                pagination_token=next_token,

                                exclude="retweets", tweet_fields=['created_at'], max_results=100)

tweets = response.data

metadata = response.meta

next_token = metadata.get("next_token")
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
### get user mentions
tweets = client.get_users_mentions(id=id, 
                                   tweet_fields=['context_annotations','created_at','geo'])

for tweet in tweets.data:
    print(tweet)
    

### get tweet counts
query = 'covid -is:retweet'

counts = client.get_recent_tweets_count(query=query, granularity='day')

for count in counts.data:
    print(count)