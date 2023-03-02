from linkedin_scraper import Person, actions
from selenium import webdriver
driver = webdriver.Chrome()
# https://pypi.org/project/linkedin-scraper/ does not work. driver is chrome 
#email = "xxx" 
#password = "xxx"
#actions.login(driver, email, password) # if email and password isnt given, it'll prompt in terminal
person = Person(name="Lingchao Mao", driver=driver)
print(person)
