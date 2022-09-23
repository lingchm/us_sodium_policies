####################################
# server logic of a Shiny web application. 
# Author: Lingchao Mao
# Last modified: 8/24/2022
####################################

# install.packages("devtools")
# devtools::install_github("debruine/shinyintro")
library(shiny)
library(readr)
library(dplyr)
library(ggplot2)
library(usmap)
#library(knitr)
library(ggsci)
library(data.table)
library(DT)
library(stringr)

########### SETUP ###########
#setwd("/Users/lingchm/Documents/Github/us_sodium_policies/RShiny")
table_master <- as.data.frame(fread("data/central_database_cleaned_20220824.csv"))
df_state <- as.data.frame(fread("data/df_state.csv")) 
df_state_year <- as.data.frame(fread("data/df_state_year.csv")) 

mapping_y = c("Total population"="total_population", 
            "White race %"="race_white_pct", 
            "Black race %"="race_black_pct", 
            "Other race %"="race_other_pct",
            "Children %"="age_children_pct", 
            "Elderly %"="age_elderly_pct", 
            "Female %"="sex_female_pct",
            "Urbanicity index"="urbanicity_index",
            "CVD death rate"="cvd_death_rate",
            "CVD incidence rate"="cvd_incidence_rate",
            "Median household income"="median_household_income")
mapping_x = c("Number of efforts"="number_efforts_cat1",
              "Number of efforts (3 categories)"="number_efforts_cat3",
              "Number of efforts (6 categories)"="number_efforts_cat5",
              "Number of pro-children efforts"="number_efforts_children_cat",
              "Number of pro-elderly efforts"="number_efforts_elderly_cat"
              #"Number of educational campaign efforts"="number_efforts_educational_campaign",
              #"Number of institutional campaign efforts"="number_efforts_institutional_procurement",
              #"Number of nutrition standard efforts"="number_efforts_nutrition_standards",
              #"Number of product reformulation efforts"="number_efforts_product_reformulation"
)

# preparation 
cbp1 <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
PLOT_AXIS_SIZE = 14
PLOT_AXIS_TITLE_SIZE = 14
INTERVAL = 5
# scale_color_brewer(palette = "Dark2")
# scale_color_npg()
# scale_color_lancet()

# define useful functions
`%notin%` <- Negate(`%in%`)


########### SERVER ###########

shinyServer(function(input, output) {
    
  
    ########### SUMMARY STATS ###########
  
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
      if (input$LOCAL == FALSE) {
        table_temp <- table_temp %>% filter(level %notin% c("local", "city", "county"))
      }
      if (input$LAWS == FALSE) {
        table_temp <- table_temp %>% filter(policy_type_simple != "Law")
      }
      if (input$RULES == FALSE) {
        table_temp <- table_temp %>% filter(policy_type_simple != "Administrative Rule")
      }
      return(table_temp)
    }
    )
    
    observe({
      # when user selects All, removes previously selected regions 
      x <- input$LOCATION
      if  (length(x) > 1)  {
        if (x[1] == "All"){
          x <- x[! x %in% c('All')]
        } else if ("All" %in% x){
          x <- "All"
        }
      } 
      updateSelectInput(session = getDefaultReactiveDomain(),
                        inputId="LOCATION", 
                        selected = x)
    })

    # observe({
    #   # when user selects All, removes previously selected regions 
    #   x <- input$TIMEPLOT_X
    #   if  (length(x) > 1)  {
    #     if (x[1] == "USA"){
    #       x <- x[! x %in% c('USA')]
    #     } else if ("USA" %in% x){
    #       x <- "USA"
    #     }
    #   } 
    #   updateSelectInput(session = getDefaultReactiveDomain(),
    #                     inputId="TIMEPLOT_X", 
    #                     selected = x)
    # })
    
    output$histogram_year <- renderPlot(
        {
            TABLE_TEMP() %>% 
            ggplot(aes(x=effect_year)) + 
            geom_histogram(binwidth=1) + 
            ylab("Number of efforts") + xlab("Effect year") +
            scale_x_continuous(breaks = seq(YEAR_RANGE()[1], YEAR_RANGE()[2], INTERVAL)) + 
            theme_light() + scale_fill_npg() + theme(axis.title=element_text(size=PLOT_AXIS_TITLE_SIZE))
    },
    height=450)   
 
    output$histogram_policy_category <- renderPlot(
      {
        count <- colSums(TABLE_TEMP() %>% select("category_nutrition_labeling","category_nutrition_standards",
                                                 "category_institutional_procurement","category_educational_campaign", 
                                                 "category_product_reformulation","category_other" )) 
                                            
        df_policy_count <- as.data.frame(count)
        df_policy_count$pct <- df_policy_count$count / sum(df_policy_count$count)
        df_policy_count$category <- c("Nutrition \nlabeling","Nution \nstandards",
                                      "Institutional \nprocurement",  "Educational \ncampaign",
                                      "Product \nreformulation","Other")
        ggplot(data=df_policy_count, aes(x=category, y=count, label = scales::percent(pct))) +
          geom_bar(stat="identity") + 
          geom_col(position = 'dodge') + 
          geom_text(position = position_dodge(width = .9),  vjust = -0.5,  size = 4) + 
          ylab("Number of efforts") + xlab("Policy Category") + ylim(0, max(df_policy_count$count) + 50) + 
          theme_light() + scale_fill_npg() + theme(axis.text=element_text(size=PLOT_AXIS_SIZE),
                                                   axis.title=element_text(size=PLOT_AXIS_TITLE_SIZE)) +
          scale_x_discrete(limits = df_policy_count$category) 
        
      },
      height=500
    )   
    
    output$histogram_age_group <- renderPlot(
        {
            count <- colSums(TABLE_TEMP() %>% select('age_children', 'age_elderly', 'age_other')) 
            df_age_count <- as.data.frame(count)
            df_age_count$pct <- df_age_count$count / sum(df_age_count$count)
            df_age_count$category <- c("pro-children", "pro-elderly", "other")
            ggplot(data=df_age_count, aes(x=category, y=count, label = scales::percent(pct))) +
              geom_bar(stat="identity") + 
              geom_col(position = 'dodge') + 
              geom_text(position = position_dodge(width = .9),  vjust = -0.5,  size = 4) + 
              ylab("Number of efforts") + xlab("Age group") + ylim(0, max(df_age_count$count) + 50) + 
              theme_light() + scale_fill_npg() + theme(axis.text=element_text(size=PLOT_AXIS_SIZE),
                                                       axis.title=element_text(size=PLOT_AXIS_TITLE_SIZE)) +
              scale_x_discrete(limits = df_age_count$category) 
        },
        height=500
        )   
    
    output$histogram_organization_type <- renderPlot(
        {
            count <- colSums( TABLE_TEMP() %>% select("org_vendingmachine","org_public",          
                                                     "org_farmers","org_school","org_restaurant",  
                                                     "org_hospital","org_groceries","org_army", "org_other")) 
            df_organization_count <- as.data.frame(count)
            df_organization_count$pct <- df_organization_count$count / sum(df_organization_count$count)
            df_organization_count$category <- c("Vending \nmachines", "Public-owned or\nleased facilities",
                                                "Farmer's \nmarket", "School", "Restaurants", "Healthcare \nfacilities",
                                                "Groceries", "Military \nrelated", "Other")
            ggplot(data=df_organization_count, 
                   aes(x=category, y=count, label = scales::percent(pct))) +
              geom_bar(stat="identity", width=0.6) + 
              #geom_col(position = 'dodge') + 
              geom_text(position = position_dodge(width = .9),  vjust = -0.5,  size = 4) + 
              ylab("Number of efforts") + xlab("Venue") + ylim(0, max(df_organization_count$count) + 20) + 
              theme_light() + scale_fill_npg() + theme(axis.text=element_text(size=PLOT_AXIS_SIZE),
                                                       axis.title=element_text(size=PLOT_AXIS_TITLE_SIZE)) +
              scale_x_discrete(limits = df_organization_count$category) + 
              scale_color_brewer(palette = "Dark2")
          
        },
        height=550)   
    
    output$table_policy_details <- renderTable(
      {
      count <- colSums(TABLE_TEMP() %>% select("details_voluntary",                 
                                               "details_taskforce",                 
                                                "details_studies",  
                                               "details_pricing",                   
                                               "details_suggarfat")) 
      df_details_count <- as.data.frame(count)
      df_details_count$pct <- df_details_count$count / nrow(TABLE_TEMP()) * 100
      df_details_count$category <- c("Voluntary",
                                          "Information-gathering through task forces", 
                                          "Information-gathering through studies or reports", 
                                          "Pricing strategies and incentives", 
                                          "Suggar/fat along with sodium reduction")
      rownames(df_details_count) <- NULL
      df_details_count <- df_details_count %>% select(category, count, pct) %>% 
        rename(`Effort details` = category, `Number of Efforts` = count, `Percentage %` = pct)
    }, digits=0)
    
    
    ########### MAP ###########
    
    YEAR_RANGE_MAP <- reactive(input$YEAR_RANGE_MAP)
    
    TABLE_MAP <- reactive({
      table_temp <- table_master %>% 
        filter(effect_year <= YEAR_RANGE_MAP()[2] & effect_year >= YEAR_RANGE_MAP()[1])
      if (input$LAWS_MAP == FALSE) {
        table_temp <- table_temp %>% filter(policy_type_simple != "Law")
      }
      if (input$RULES_MAP == FALSE) {
        table_temp <- table_temp %>% filter(policy_type_simple != "Administrative Rule")
      }
      return (table_temp)
     }
    )

    output$map_state <- renderPlot({
      selected_location = c()
      if (input$LEVEL_MAP == "State") {
        selected_location = c("state")
      } else {
        selected_location = c("state", "local", "city", "county")
      }
      table_state <- TABLE_MAP() %>% filter(level %in% selected_location) %>% group_by(state) %>% summarize(n=n())
      plot_usmap(data = table_state, values="n", labels=TRUE, label_color="black") +
            scale_fill_gradient(low= "lightyellow", high = "darkgreen", name="Number of efforts", 
                            labels = c("0","5","10","15","20","25","30"),
                            breaks = c(0,5,10,15,20,25,30)) +
            #scale_fill_continuous(low = "lightyellow", high = "darkgreen", name = "Number of efforts") +
               theme(legend.position = "right",
                     legend.title = element_text(size=PLOT_AXIS_TITLE_SIZE), #change legend title font size
                     legend.text = element_text(size=PLOT_AXIS_TITLE_SIZE)) #change legend text font size#) 
         }, height=550, width=750) 
    
    ########### BOXPLOTS ###########
    BOXPLOT_X <- reactive(input$BOXPLOT_X)
    BOXPLOT_Y <- reactive(input$BOXPLOT_Y)

    output$boxplot_state <- renderPlot({
      x = BOXPLOT_X()
      y = BOXPLOT_Y()
      
      temp <- df_state %>% filter(state != "USA") %>% select(mapping_x[x], mapping_y[y])
      if ( mapping_y[y] == "cvd_death_rate" | mapping_y[y] == "cvd_incidence_rate"){
        temp <- temp <- df_state %>% filter(state != "DC")%>% select(mapping_x[x], mapping_y[y]) 
      }
      colnames(temp) <- c("x", "y")
      ylim <- c(min(temp$y), max(temp$y) + sd(temp$y)*0.5)
      if (mapping_y[y] == "race_other_pct"){
        ylim <- c(0, 0.23)
      } 
      boundaries <- boxplot(temp$y ~ temp$x, 
                            main=paste("Relationship between state-level", y,"\n and ", x, delim=""), 
                            col="#69b3a2",ylim=ylim,xlab=x, ylab=y)
      text( 
        x=c(1:nlevels(as.factor(temp$y))), 
        y= boundaries$stats[nrow(boundaries$stats),] + sd(temp$y)/2,
        paste("n = ",table(temp$x),sep="")  
      )
      
    },
    height=500)
    
    ########### TIMELINE PLOTS ###########
    TIMEPLOT_X <- reactive(input$TIMEPLOT_X)
    TIMEPLOT_Y <- reactive(input$TIMEPLOT_Y)
    
    output$timeplot_year <- renderPlot({
      x = TIMEPLOT_X()
      y = TIMEPLOT_Y()
      temp <- df_state_year %>% filter(state %in% x) %>% select(year, mapping_y[y], state) 
      colnames(temp) <- c("x", "y", "location")
      if (length(x) == 1) {
        p <- temp %>% 
          ggplot( aes(x=x, y=y)) +
          geom_area(fill="#69b3a2", alpha=0.5) +
          geom_line(color="#69b3a2") +
          ylab(y) + xlab("year") + theme_light() +
          ggtitle(paste("Trend of", y, "over time in", x)) +
          theme(plot.title = element_text(size = PLOT_AXIS_TITLE_SIZE+5,hjust=0.5))
      } else{
        p <- temp %>% ggplot( aes(x=x, y=y, group=location, color=location)) +
          geom_line() +
          ylab(y) + xlab("year") + theme_light() +
          ggtitle(paste("Trend of", y, "over time")) +
          theme(plot.title = element_text(size = PLOT_AXIS_TITLE_SIZE+5,hjust=0.5))
      }
      p
    },
    height=500)
    
    ########### IMAGES ###########
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
    
    output$contact_us <- renderImage({
      list(src = "images/contact_us2.png",
           contentType = 'image/png',
           height = 100,
           alt = "This is alternate text")
    }, deleteFile=FALSE)
    
    ####### OTHERS  ####### 
    output$num_policies <- renderText({
        paste("Total number of policies:", nrow(TABLE_TEMP())) 
        })
    output$num_states <- renderText({ 
        paste("Total unique states:", length(unique(TABLE_TEMP()$state)))
    })
    
    output$num_policies_map <- renderText({
      paste("Total number of policies:   ", nrow(TABLE_MAP())) 
    })
    output$num_policies_nacional_map <- renderText({
      paste("Number of national efforts: ", nrow(TABLE_MAP() %>% filter(level=="national"))) 
    })
    output$num_policies_state_map <- renderText({
      paste("Number of state efforts:    ", nrow(TABLE_MAP() %>% filter(level=="state"))) 
    })
    output$num_policies_local_map <- renderText({ 
      paste("Number of local efforts:    ", nrow(TABLE_MAP() %>% filter(level %in% c("local","county","city")))) 
    })
    output$map_title <- renderText({
      if (input$LEVEL_MAP == "State") {
        text = "State"
      } else  {
        text = "State and Local"
      }
      paste("Map of", text, " Level Sodium Reduction Efforts", delim=" ")
    })
    output$hawaii_other_race <- renderText({
      if (input$BOXPLOT_Y == "Other race %") {
        text = "Note: State of HI has over 70% of other race, not shown on boxplot."
      } else if (input$BOXPLOT_Y == "CVD death rate") {
        text = "Note: CVD age-adjusted death rate per 100,000 total population. CVD death rate of DC was not included."
      }
      else {
        text = ""
      }
    })
    
})


