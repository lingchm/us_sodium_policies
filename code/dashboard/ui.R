#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Tutorials:
#  http://shiny.rstudio.com/
#  https://debruine.github.io/shinyintro/first-app.html

library(shiny)
library(data.table)

# Define UI for application that draws a histogram
setwd("/Users/lingchm/Documents/Github/us_sodium_policy_dashboard")
table_master <- fread("data/ncsl_database.csv")
states <- sort(unique(table_master$state))
MIN_YEAR <- min(table_master$effect_year, na.rm=TRUE)
MAX_YEAR <- max(table_master$effect_year, na.rm=TRUE)
`%notin%` <- Negate(`%in%`)

shinyUI(fluidPage(

    # Application title
    titlePanel("U.S. State Efforts in Sodium Reduction"),
    theme = bslib::bs_theme(bootswatch = "flatly"),
    
    navlistPanel(
        "About",
        tabPanel("Dietary Sodium",
                 h4("Cardiovascular Disease and Dietary Sodium"),
                    p("Cardiovascular disease (CVD) deaths in the US approached 1 million in 2019, accounting for 33% of annual
                        mortality (Mensah et al. 2019). Americans consume 3,400 milligrams (mg) of sodium per day, nearly 50%
                        higher than the limit recommended by the US and World Health Organization (WHO) guidelines of 2,300 mg
                        per day (National Academies of Sciences, Engineering, and Medicine 2019). The science indicates that
                        sodium intake is modifiable and population sodium reduction is an effective intervention to reduce CVD deaths."
                    ),
                 
                 # source: https://www.jacc.org/doi/abs/10.1016/j.jacc.2019.11.055
                 imageOutput("salt_reduction_hypertension"),
                 
                 # source: FDA, https://www.fda.gov/food/food-additives-petitions/sodium-reduction
                 h4("The Public Health Need"), 
                 tags$ul(
                     tags$li("Americans consume on average 3,400 milligrams (mg) of sodium per day—nearly 50%more than the 2,300 mg limit recommended by federal guidelines for people 14 years and older. Recommended limits for children 13 and younger are even lower."), 
                     tags$li("Most children and adolescents also eat more sodium than is recommended."), 
                     tags$li("Too much sodium can raise blood pressure, which is a major risk factor for heart disease and stroke."),
                     tags$li("More than 4 in 10 American adults have high blood pressure and that number increases to almost 6 in 10 for non-Hispanic Black adults.  Additionally, about one in 10 children (8-12 years) and one in 8 teens (13-17 years) has elevated or high blood pressure."),
                     tags$li("Reducing sodium intake has the potential to prevent hundreds of thousands of premature deaths and illnesses in the coming years.")
                 ),
                 imageOutput("public_health_need"),

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
                 p("We gathered a database of state-level and national-level dietary sodium reduction policies in the U.S. 
                 (xx states including Washington DC (DC) and US Virgin Islands (VI)). The policies collected have effective date
                 ranging from 1965 to 2022.Data sources include: xxxx"
                 )),
        
        
        tabPanel("Resources"),
        
        "Data & Visualization",
        tabPanel("Summary stats",
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
                                "LOCATION",
                                "Location:",
                                choices = c("All", states),
                                selected = "All",
                                multiple = TRUE
                            ),
                            h6("Type:"),
                            splitLayout(
                                    checkboxInput('LAWS', 'Laws', value=TRUE),
                                    checkboxInput('POLICIES', 'Policies', value=TRUE),
                                    checkboxInput('EXECUTIVE_ORDER', 'Exec Orders', value=TRUE)
                            ),
                            h6("Level:"),
                            splitLayout(
                                    checkboxInput('NATIONAL', 'National', value=TRUE),
                                    checkboxInput('STATE', 'State', value=TRUE)
                                    #checkboxInput('LOCAL', 'Local')
                            )
                     ),
                 column(7,
                    tabsetPanel(
                                id = "tabset",
                                tabPanel("By year", plotOutput("histogram_year")),
                                tabPanel("By category", plotOutput("histogram_organization_type", width="100%")),
                                tabPanel("By detailed category", tableOutput('table_type')),
                                tabPanel("By age group", plotOutput("histogram_age_group", width="100%"))
                    )
                 ))
        ),
        
        tabPanel("Map of state efforts",
                 fluidRow(
                     column(3,
                            sliderInput("YEAR_RANGE_MAP", "Year range:",
                                        min = 1965,max = 2020,
                                        value = c(1965, 2020),
                                        step = 1, ticks = FALSE, sep = ""),
                            h6("Type:"),
                            splitLayout(
                                checkboxInput('LAWS_MAP', 'Laws', value=TRUE),
                                checkboxInput('POLICIES_MAP', 'Policies', value=TRUE),
                                checkboxInput('EXECUTIVE_ORDER_MAP', 'Exec Orders', value=TRUE)
                            ),
                     ),
                     column(7,
                            plotOutput("map_state"))
                 ), 
        ),
        "Analysis",
        tabPanel("TBD"),
        
        # formatting
        widths = c(2,10)
    )
    
))
