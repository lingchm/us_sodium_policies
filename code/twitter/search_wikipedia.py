import wikipedia

wikipedia.set_lang("en")  


queries = ['World Health Organization', 
           'Tom Frieden',
           'World Action on Salt',
           'American Heart Association']

for name in queries:

    query = wikipedia.suggest(name)
    print(query)

    if query is None:
        candidates = wikipedia.search(name, results=5)
        #print(candidates)    
        query = candidates[0]

    # summary
    # print(wikipedia.summary(query))

    # categories 
    print("Search query:", query)
    print("     Categories:", wikipedia.page(query).categories)


