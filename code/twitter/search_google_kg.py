import json
from urllib.parse import urlencode
from urllib.request import urlopen
import ssl
import os
ssl._create_default_https_context = ssl._create_unverified_context


API_KEY = os.environ.get("API_KEY")
service_url = 'https://kgsearch.googleapis.com/v1/entities:search'


queries = ['World Health Organization', 
           'Tom Frieden',
           'World Action on Salt',
           'American Heart Association']

for query in queries:
    params = {
        'query': query,
        'limit': 1,
        'indent': True,
        'key': API_KEY,
    }
    url = service_url + '?' + urlencode(params)
    response = json.loads(urlopen(url).read())
    for element in response['itemListElement']:
        print("Search query:", query)
        print("     Entity:", element['result']['name'])
        print("     Confidence score:", str(round(element['resultScore'],2)))
        print("     Category:", element['result']['@type'])
