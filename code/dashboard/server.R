#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# install.packages("devtools")
# devtools::install_github("debruine/shinyintro")
library(shiny)
library(readr)
library(dplyr)
library(ggplot2)

library(usmap)
library(ggplot2)
library(knitr)
library(ggsci)

setwd("/Users/lingchm/Documents/Github/us_sodium_policy_dashboard")

# read in data
table_master <- fread("data/ncsl_database.csv")

# exclude local
table_master <- table_master %>% filter(level != "local")

# formatting
# unique(table_master$organization)
table_master$age_group <- factor(table_master$age_group, 
                                 levels = c("child", "youth", "elder", "other"))
table_master$organization <- factor(table_master$organization, 
                                    levels = c("school", "restaurant", "farmer's market", "groceries", 
                                               "public-owned or \nleased facilities", "healthcare facilities", "other") )
table_master$policy_category_4 <- factor(table_master$policy_category_4, 
                                         levels = c("Institutional Procurement",
                                                    "Nutrition Labeling",
                                                    "Nutrition Standards",
                                                    "Educational Campaign",
                                                    "Product Reformulation", 
                                                    "Other"))

# The palette with grey:
cbp1 <- c("#999999", "#E69F00", "#56B4E9", "#009E73",
          "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
# scale_color_brewer(palette = "Dark2")
# scale_color_npg()
# scale_color_lancet()

# define useful functions
`%notin%` <- Negate(`%in%`)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    YEAR_RANGE <- reactive(input$YEAR_RANGE)

    TABLE_TEMP <- reactive({
      table_temp <- table_master %>% 
        filter(effect_year <= YEAR_RANGE()[2] & effect_year >= YEAR_RANGE()[1])
      if ("All" %notin% input$LOCATION) {
        table_temp <- table_temp %>% filter(state %in% input$LOCATION)
      }
      if (input$NATIONAL == FALSE) {
        table_temp <- table_temp %>% filter(level != "national")
      } 
      if (input$STATE == FALSE) {
        table_temp <- table_temp %>% filter(level != "state")
      } 
      if (input$LAWS == FALSE) {
        table_temp <- table_temp %>% filter(policy_type_3 != "Law")
      }
      if (input$POLICIES == FALSE) {
        table_temp <- table_temp %>% filter(policy_type_3 != "Policy")
      }
      if (input$EXECUTIVE_ORDER == FALSE) {
        table_temp <- table_temp %>% filter(policy_type_3 != "Executive Order")
      }
      return(table_temp)
    }
    )
    
    TABLE_STATE <- reactive({
      table_temp <- table_master %>% 
        filter(effect_year <= input$YEAR_RANGE_MAP[2] & effect_year >= input$YEAR_RANGE_MAP[1]) 
      if (input$LAWS_MAP == FALSE) {
        table_temp <- table_temp %>% filter(policy_type_3 != "Law")
      }
      if (input$POLICIES_MAP == FALSE) {
        table_temp <- table_temp %>% filter(policy_type_3 != "Policy")
      }
      if (input$EXECUTIVE_ORDER_MAP == FALSE) {
        table_temp <- table_temp %>% filter(policy_type_3 != "Executive Order")
      }
      table_temp <- table_temp %>% group_by(state) %>% summarize(n=n())
      return (table_temp)
    }
    )

    output$histogram_year <- renderPlot(
        {
            TABLE_TEMP() %>% 
            ggplot(aes(x=effect_year)) + 
            geom_histogram(binwidth=1) + 
            ylab("Number of efforts") + xlab("Effect year") +
            scale_x_continuous(breaks = seq(YEAR_RANGE()[1], YEAR_RANGE()[2], 2)) + 
            theme_light() + scale_fill_npg()
    },
    height=450)   
    
    output$histogram_age_group <- renderPlot(
        {
            TABLE_TEMP() %>% count(age_group = factor(age_group)) %>% mutate(pct = prop.table(n)) %>% 
                ggplot(aes(x = age_group, y = pct, label = scales::percent(pct))) + 
                geom_col(position = 'dodge') + 
                geom_text(position = position_dodge(width = .9),  vjust = -0.5,  size = 3) + 
                ylab("Percentage %") + xlab("age group") + ylim(0,1) + 
                theme_light() + scale_fill_npg()
        },
        height=500
        )   
    
    output$histogram_organization_type <- renderPlot(
        {
            TABLE_TEMP() %>% group_by(policy_category_4) %>% count(organization) %>% 
                ggplot(aes(policy_category_4, n, fill=organization)) + 
                ylab("Number of efforts") + xlab("WHO ‘best buy’ category") +
                geom_col() + 
                scale_x_discrete(labels = function(x) stringr::str_wrap(x, width = 15)) +  #+
                theme_light() + scale_fill_npg() + theme(legend.key.height=unit(.6, "cm")) 
        },
        height=550)   
    
    output$table_type <- renderTable({
        TABLE_TEMP() %>% group_by(policy_category_12) %>% count(policy_category_12) %>%
            rename(`Type of effort` = policy_category_12, `Total number` = n)
        })
    
    output$map_state <- renderPlot({
            plot_usmap(data = TABLE_STATE(), values="n", labels=TRUE, label_color="black") +
            scale_fill_continuous(low = "white", high = "darkgreen", name = "Number of efforts") +
                                #label = scales::label_number(accuracy = 1)) 
               theme(legend.position = "right") 
         }, height=600) 
    
    output$salt_reduction_hypertension <- renderImage({
        list(src = "images/salt reduction hypertension.png",
             contentType = 'image/png',
             height = 400,
             alt = "This is alternate text")
        }, deleteFile=FALSE)
    
    output$public_health_need <- renderImage({
      list(src = "images/public health need.png",
           contentType = 'image/png',
           height = 400,
           alt = "This is alternate text")
    }, deleteFile=FALSE)
    
    output$num_policies <- renderText({
        paste("Total number of policies:", nrow(TABLE_TEMP())) 
        })
    output$num_states <- renderText({ 
        paste("Total unique states:", length(unique(TABLE_TEMP()$state)))
    })
    
})


