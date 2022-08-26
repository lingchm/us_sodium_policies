####################################
# user-interface definition of a Shiny web application
# Author: Lingchao Mao
# Last modified: 8/24/2022
####################################

library(shiny)
library(data.table)
library(shinydashboard)
library(shinyWidgets)
#shinyWidgets::shinyWidgetsGallery()

# load data
#setwd("/Users/lingchm/Documents/Github/us_sodium_policies/Rshiny")
table_master <- fread("data/central_database_cleaned_20220824.csv")

states <- sort(unique(table_master$state))
N_STATES <- length(states) - 1
MIN_YEAR <- min(table_master$effect_year, na.rm=TRUE)
MAX_YEAR <- max(table_master$effect_year, na.rm=TRUE)
`%notin%` <- Negate(`%in%`)

# define dashboard 

shinyUI(fluidPage(

    # Application title
    titlePanel("Sodium Reduction Efforts in the U.S."),
    theme = bslib::bs_theme(bootswatch = "flatly"),
    
    navlistPanel(
        
        ################################# 
        "About",
        tabPanel("Sodium Reduction",
                 h4("Cardiovascular Disease and Dietary Sodium"),
                 p("Cardiovascular disease (CVD) deaths in the US approached 1 million in 2019, accounting for 33% of annual
                        mortality (Mensah et al. 2019). Americans consume 3,400 milligrams (mg) of sodium per day, nearly 50%
                        higher than the limit recommended by the US and World Health Organization (WHO) guidelines of 2,300 mg
                        per day (National Academies of Sciences, Engineering, and Medicine 2019). The science indicates that
                        sodium intake is modifiable and population sodium reduction is an effective intervention to reduce CVD deaths."
                 ),
                 
                 # source: https://www.jacc.org/doi/abs/10.1016/j.jacc.2019.11.055
                 #imageOutput("salt_reduction_hypertension"),
                 
                 # source: FDA, https://www.fda.gov/food/food-additives-petitions/sodium-reduction
                 h4("The Public Health Need"), 
                 tags$ul(
                     tags$li("Americans consume on average 3,400 milligrams (mg) of sodium per day—nearly 50%more than the 2,300 mg limit recommended by federal guidelines for people 14 years and older. Recommended limits for children 13 and younger are even lower."), 
                     tags$li("Most children and adolescents also eat more sodium than is recommended."), 
                     tags$li("Too much sodium can raise blood pressure, which is a major risk factor for heart disease and stroke."),
                     tags$li("More than 4 in 10 American adults have high blood pressure and that number increases to almost 6 in 10 for non-Hispanic Black adults.  Additionally, about one in 10 children (8-12 years) and one in 8 teens (13-17 years) has elevated or high blood pressure."),
                     tags$li("Reducing sodium intake has the potential to prevent hundreds of thousands of premature deaths and illnesses in the coming years.")
                 ),
                 #imageOutput("public_health_need"),

                h4("Sodium Reduction Efforts"),
                    p("The WHO recommends four ‘best buys’ for sodium intake reduction: product reformulation, nutrition labeling,
                        institutional procurement, and public educational campaigns. The Food and Drug Administration (FDA) set two
                        goals to reduce sodium consumption (Collins et al. 2019). The first is a short-term goal of 3,000 mg per day to
                        be achieved within two years, and the second is a long-term goal of 2,300 mg per day within ten years.
                        Unfortunately, a gap exists between current sodium evidence and policy implementation in the US. Closing this
                        gap will require understanding about how to reach the FDA goals."
                      ),
                
        ),
        
        tabPanel("This Project",
                 
                 h4("Objectives"),
                 p("This project has the following aims:"),
                 tags$ul(
                     tags$li("Compile a database of sodium reduction laws and administrative laws across all states in the U.S."),
                     tags$li("Analyze the trends and characteristics of sodium reduction policies in the past."), 
                     tags$li("Stimulate awareness of salt reduction and provide resources"),
                 ),
                  
                 h4("Database of Sodium Reducation Policies"),
                 
                 p(paste("We gathered national, state-level, and local dietary sodium-related policies in the U.S., 
                 from a total of", N_STATES, "states including Washington DC (DC) and US Virgin Islands (VI)). 
                 The policies collected have effective date ranging from", MIN_YEAR, "to", MAX_YEAR, ".
                 Data sources included:")),
                 
                 tags$ul(
                     tags$li(tags$a(href="http://www.ncsl.org/research/health/analysis-of-state-laws-related-to-dietary-sodium.aspx", 
                             "The National Conference of State Legislature's sodium policy listings")), 
                     tags$li(tags$a(href="https://cspinet.org/sites/default/files/attachment/examples2_0.pdf",
                             "The Center for Science in the Public's Interest sodium policy listings")), 
                     tags$li(tags$a(href="https://healthyfoodpolicyproject.org/policy-database",
                                    "Healthy food policy project database")),
                     tags$li(tags$a(href="https://legal.thomsonreuters.com/en/products/westlaw-edge",
                                    "Westlaw"))
                 ),
                 
                 p("Each policy was manually verified by one researcher in terms of effect year, location, policy category (WHO's four best buys), 
                   policy type (law or administrative rule). Additionally, we used automated text mining methods based on keyword search
                   to extract additional variables from each policy, including venue, age group, and policy details. 
                   Duplication across different databases was manually checked."),

                 h4("Hypothesis"),
                 
        ),
        
        tabPanel("Resources",
                 h4("References"),
                 tags$ul(
                     tags$li("Sloan, Arielle A., Thomas Keane, Jennifer Rutledge Pettie, Aunima R. Bhuiya, Lauren N. Taylor, Marlana Bates, Stephanie Bernard, Fahruk Akinleye, and Siobhan Gilchrist. “Mapping and Analysis of US State and Urban Local Sodium Reduction Laws.” Journal of Public Health Management and Practice 26, no. 2 (March 2020): S62–70. https://doi.org/10.1097/PHH.0000000000001124. "),
                     tags$li("Santos, Joseph Alvin, et al. A systematic review of salt reduction initiatives around the world: a midterm evaluation of progress towards the 2025 global non-communicable diseases salt reduction target. Advances in Nutrition 12.5 (2021): 1768-1780."),
                 ),
                 h4("Organizations"),
                 tags$ul(
                     tags$li(tags$a(href="https://www.worldactiononsalt.com", 
                                    "The World Action on Salt")), 
                     tags$li(tags$a(href="https://www1.nyc.gov/site/doh/health/health-topics/national-salt-sugar-reduction-initiative.page",
                                    "National Salt and Sugar Reduction Initiative (NSSRI)")), 
                     tags$li(tags$a(href="https://www.cdc.gov/salt/sodium_reduction_initiative.htm",
                                    "CDC Sodium Reduction Efforts")),
                     tags$li(tags$a(href="https://www.who.int/news-room/fact-sheets/detail/salt-reduction",
                                    "WHO Recommendations for Salt Reduction")),
                     tags$li(tags$a(href="http://www.iom.edu/sodiumstrategies",
                                    "Institute of Medicine, Strategies to Reduce Sodium in the United States")),
                       
                 ),
                 h4("Policy Databases"),
                 tags$ul(
                     tags$li(tags$a(href="https://www.congress.gov/advanced-search/legislation", 
                                    "Congress.gov Legistration Database")), 
                     tags$li(tags$a(href="https://www.federalregister.gov/documents/search#advanced",
                                    "Federal Register National Archive")), 
                     tags$li(tags$a(href="https://library.municode.com/mo/belton/codes/code_of_ordinances", 
                                    "Municode")), 
                     tags$li(tags$a(href="https://codelibrary.amlegal.com",
                                    "American Legal Publishing's Code Library")), 
                     tags$li(tags$a(href="https://www.cdc.gov/salt/sodium_reduction_initiative.htm",
                                    "Lexis")),
                     tags$li(tags$a(href="https://legal.thomsonreuters.com/en/products/westlaw-edge",
                                    "Westlaw"))
                 ),
        ),
        tabPanel("Contact us",
                 #imageOutput("contact_us", height = "100px"),
                     h6(tags$b("    Yanfang Su")),
                     p("    Assistant Professor, Department of Global Health, University of Washington"),
                     p("    Hans Rosling Center 715, Seattle, WA, United States"),
                     p("    Phone number: 206-616-5418 "),
                     p("    Email: ", tags$a(href="htyfsu@uw.edu","yfsu@uw.edu")),
                     p("    Homepage:", tags$a(href="https://globalhealth.washington.edu/faculty/yanfang-su",
                                               "https://globalhealth.washington.edu/faculty/yanfang-su")),
                     br(),
                     p(tags$i("Please note, this dashboard is a preliminary result of an ongoing research project. 
                    We are unable to respond to data sharing requests as we are continuing collecting and curating data
                    to improve our databse. We welcome feedback and suggestions. 
                    We hope you find the analysis and interactive dashboard insightful."))
        ),
        
        #################################
        
        "Data & Visualization",
        
        tabPanel("Summary statistics",
                 fluidRow(
                 column(3,
                        h4("Overview"),
                        textOutput("num_policies"),
                        textOutput("num_states"),
                        hr(),
                        h4("Selections"),
                        sliderInput("YEAR_RANGE", "Year range:",
                                        min = MIN_YEAR, max = MAX_YEAR,
                                        value = c(MIN_YEAR, MAX_YEAR),
                                        step = 1, ticks = FALSE, sep = ""),
                            selectInput(
                                "LOCATION", "Location:",
                                choices = c("All", states),
                                selected = "All",
                                multiple = TRUE
                            ),
                            h6("Type:"),
                            splitLayout(
                                    checkboxInput('LAWS', 'Laws', value=TRUE),
                                    checkboxInput('RULES', 'Adminitrative Rules', value=TRUE)
                            ),
                            h6("Level:"),
                            splitLayout(
                                    checkboxInput('NATIONAL', 'National', value=TRUE),
                                    checkboxInput('STATE', 'State', value=TRUE),
                                    checkboxInput('LOCAL', 'Local', value=TRUE)
                            )
                     ),
                 column(7,
                    tabsetPanel(
                                id = "tabset",
                                tabPanel("By year", plotOutput("histogram_year")),
                                tabPanel("By policy category", plotOutput("histogram_policy_category", width="100%")),
                                tabPanel("By venue", plotOutput("histogram_organization_type", width="100%")),
                                tabPanel("By detailed category",
                                         br(),
                                         tableOutput('table_policy_details'), width="100%"),
                                tabPanel("By age group", plotOutput("histogram_age_group", width="100%"))
                    )
                 ))
        ),

        tabPanel("Map of efforts",
                 fluidRow(
                     column(3,
                            h4("Overview"),
                            textOutput("num_policies_map"),
                            textOutput("num_policies_nacional_map"),
                            textOutput("num_policies_state_map"),
                            textOutput("num_policies_local_map"),
                            hr(),
                            h4("Selections"),
                            sliderInput("YEAR_RANGE_MAP", "Year range:",
                                        min = MIN_YEAR, max = MAX_YEAR,
                                        value = c(MIN_YEAR, MAX_YEAR),
                                        step = 1, ticks = FALSE, sep = ""),
                            h6("Type:"),
                            splitLayout(
                                checkboxInput('LAWS_MAP', 'Laws', value=TRUE),
                                checkboxInput('RULES_MAP', 'Adminitrative Rules', value=TRUE)
                            ),
                            hr(),
                            h4("Map View"),
                                splitLayout(
                                    radioGroupButtons(
                                        inputId = "LEVEL_MAP",
                                        #label = "Map View", 
                                        choices = c("State", "State and Local"),
                                        status = "success",
                                        #size = "lg",
                                        #value="State"
                                    )

                                    # actionButton("STATE_MAP", "State", class = "btn-success"),
                                    # actionButton("LOCAL_MAP", "Local", class = "btn-success"),
                                    # actionButton("STATE_LOCAL_MAP", "State and Local", class = "btn-success"),
                                    #checkboxInput('STATE_MAP', 'State', value=TRUE),
                                    #checkboxInput('LOCAL_MAP', 'Local', value=TRUE)
                            ),
                     ),
                     column(7,
                            h4(textOutput("map_title"),),
                            plotOutput("map_state"))
         )),
        

        ################################# 
        "Analysis",

        tabPanel("Panel Analysis",
                 h4("Methods"),
                 p("We build a state-year panel data using the policy database.
                   "),
                 
                 p("Additionally, we collected U.S. Population data of 1969 to 2020 from the", 
                   tags$a(href="https://seer.cancer.gov/popdata/download.html#single ", "National Cancer Institute"),
                   "We extracted the age group and race at state level.")
                 ),
        tabPanel("Group comparisons",
                 h4(),
                 h4("Relationship between state race diversity and number of policies"),
                 h4("Relationship between state age and number of policies"),
                 h4("Relationship between state CVD burden and number of policies"),
                 h4("Relationship between urbanicity index and number of policies"),
                 h4("Relationship between GDP and number of policies"),
                 # Based on XX databases, we have 52 state and local policies for children (out of 252 policies). Not enough to run regression but okay for summary statistics: 
                 #     
                 #     What is the % of children targeted policies within total policies per year? --> line chart by year   
                 # 
                 # Within the children policies, which ones are accessible to children from low income families? --> look at some policies description and see? 
                 #     
                 #     What states have children-related sodium policies? --> map 
                 # 
                 # Do states with a higher low-income population % have less children policies? --> Boxplots of total # policies per state (N=52) by average GDP or income  
                 # 
                 # Do states with higher colored-race children % have less children policies? --> Boxplot  
                 # 
                 # What kind of children policies are most successful or popular within U.S.? --> summary table like Sloan or bar chart of most popular children policy types (e.g. nutrition standards, through school programs, what amount mg of sodium, whether just sodium or also sugar and fat, through lunch or drink, how many voluntary vs mandatory) 
                 # 
                 # Check timeline / pattern by year 
        ),
        
        # tabPanel("Stakeholder Behavior on Twitter",
        #          h4("Introduction"),
        #          p(""),
        #          h4("Methodology"),
        #          p(""),
        #          h4("Results"),
        #          h5("Graphical summary"),
        #          includeHTML("results/graph_all_tweets.html"),
        #          includeHTML("results/graph_sodium_tweets.html"),
        #          ),
        
        # formatting
        widths = c(2,10)
    )
    
))
