library(readr)
library(dplyr)
library(ggplot2)
library(data.table)
library(usmap)
library(ggplot2)
library(knitr)

setwd("/Users/lingchm/Dropbox (GaTech)/I-research/9_su/updates/1-policies")

##################
# Visualization
##################


table_master <- fread("ncsl_database.csv")

start <- 1980
end <- 2012
table_master <- table_master %>% filter(effect_year <= end & effect_year >= start)
# total of 112



ggplot(table_master,aes(x=effect_year)) + 
  geom_histogram(binwidth=1) + 
  #geom_text(data=table_master, aes(label=count), colour="white", size=2.5) + 
  #stat_bin(binwidth=1, geom="text", size=2.5,
  #         aes(label=..count..), position=position_stack(vjust=1.1)) +
  ylab("Number of efforts") + xlab("Effect year") +
  scale_x_continuous(breaks = seq(start, end, 5)) + 
  labs(
    title = "Number of State Efforts by Year (1980-2012)",
    caption = "Figure 2: State efforts in sodium reduction, 1980-2012"
  ) + theme_light() + theme(
    plot.title = element_text(hjust=0),
    plot.caption = element_text(hjust=0, size=12)) #


length(unique(table_master$state))
unique(table_master$state)
table(table_master$effect_year, table_master$policy_type)# %>% kable()

table(table_master$organization, table_master$policy_category_4)
table(table_master$effect_year)
table_master %>% 
  count(policy_type = factor(policy_type)) %>% 
  mutate(pct = prop.table(n)) %>% 
  ggplot(aes(x = policy_type, y = pct, label = scales::percent(pct))) + 
  geom_col(position = 'dodge') + 
  geom_text(position = position_dodge(width = .9),    # move to center of bars
            vjust = -0.5,    # nudge above top of bar
            size = 3) + 
  #scale_y_continuous(labels = scales::percent) +
  ylab("Percentage %") + xlab("policy type") + ylim(0,1) +  
  ggtitle("Number of Policies by Type") + theme_light()

table_master %>% 
  count(age_group = factor(age_group)) %>% 
  mutate(pct = prop.table(n)) %>% 
  ggplot(aes(x = age_group, y = pct, label = scales::percent(pct))) + 
  geom_col(position = 'dodge') + 
  geom_text(position = position_dodge(width = .9),    # move to center of bars
            vjust = -0.5,    # nudge above top of bar
            size = 3) + 
  #scale_y_continuous(labels = scales::percent) +
  ylab("Percentage %") + xlab("age group") + ylim(0,1) +  
  ggtitle("Number of Policies by Type") + theme_light()

table_master %>% 
  count(organization = factor(organization)) %>% 
  mutate(pct = prop.table(n)) %>% 
  ggplot(aes(x = organization, y = pct, label = scales::percent(pct))) + 
  geom_col(position = 'dodge') + 
  geom_text(position = position_dodge(width = .9),    # move to center of bars
            vjust = -0.5,    # nudge above top of bar
            size = 3) + 
  #scale_y_continuous(labels = scales::percent) +
  ylab("Percentage %") + xlab("organization") + ylim(0,0.5) +  
  ggtitle("Number of Policies by Type") + theme_light() + 
  scale_x_discrete(labels = function(x) stringr::str_wrap(x, width = 10)) 


unique(table_master$organization)
x = c("school", "restaurant", "farmer's market", "groceries", 
      "public-owned or \nleased facilities", "other" ) #"hospital", "companies", 
table_master$organization <- factor(table_master$organization, levels = x)
table_master$policy_category_4 <- factor(table_master$policy_category_4, 
                                         levels = c("Institutional Procurement",
                                                    "Nutrition Labeling",
                                                    "Educational Campaign",
                                                    "Product Reformulation", 
                                                    "Other"))
table_master %>% group_by(organization) %>% count(organization) 

table_master %>% group_by(policy_category_4) %>% count(organization) %>% 
  ggplot(aes(policy_category_4, n, fill=organization)) + 
  ylab("Number of efforts") + xlab("Effort category") +
  geom_col() + ggtitle("Number of efforts by four categories") +
  scale_x_discrete(labels = function(x) stringr::str_wrap(x, width = 15)) +  #+
  labs(
    title = "Number of State Efforts by WHO ‘best buy’ category ",
    caption = "Figure 1. State efforts by WHO ‘best buy’ category"
  ) + theme_light() + theme(
    plot.title = element_text(hjust=0),
    plot.caption = element_text(hjust=0, size=12),
    legend.key.height=unit(0.6, "cm")) + 
  scale_color_manual(values = c("#E7B800", "#2E9FDF", "#FC4E07","#E7B800", "#2E9FDF", "#FC4E07")) 
  

  
# Count of policies per state
df <- table_master %>% group_by(state) %>%
  summarize(`Number of laws`=n()) %>%
  rename(state="state", n="Number of laws")
# p <- plot_usmap(data = df, values="n", labels=TRUE, color="blue", label_color="black") +
#   scale_fill_continuous(low = "white", high = "blue", name = "Number of Policies", label = scales::comma) +
#   labs(title = "Dietary Sodium Related State Laws", subtitle = "NCSL data from 1965-2020") +
#   theme(legend.position = "right")
# p$layers[[2]]$aes_params$size <- 3
# p

max(df$n)
p <- plot_usmap(data = df, values="n", labels=TRUE, label_color="black") +
  scale_fill_stepsn(breaks = c(1,4,7,10), #limits=c(min(df$n),max(df$n)), 
                    labels = c("1-4", "4-7", "7-10", ">=10"),
                    colors=c("yellow","green","darkblue"),
                    guide = guide_colorsteps(even.steps = FALSE), 
                    name = "Number of Laws") +
  labs(title = "Dietary Sodium Related State Laws", subtitle = "NCSL data from 1965-2020") +
  theme(legend.position = "right") 
p$layers[[2]]$aes_params$size <- 3
p

df <- table_master %>% filter(policy_type=="Laws") %>% 
  group_by(state) %>%
  summarize(`Number of efforts`=n()) %>%
  rename(state="state", n="Number of efforts")
max(df$n)
p <- plot_usmap(data = df, values="n", labels=TRUE, label_color="black") +
  scale_fill_stepsn(breaks = c(1,4,7), #limits=c(min(df$n),max(df$n)), 
                    labels = c("1-3", "4-6", ">6"),
                    colors=c("yellow", "purple"),
                    guide = guide_colorsteps(even.steps = FALSE), 
                    name = "Number of laws") +
  labs(
  caption = "Panel A. State laws"
  ) + theme(
  plot.caption = element_text(hjust=0, size=12),
  legend.position = "right") 
p$layers[[2]]$aes_params$size <- 3
p

df <- table_master %>% filter(policy_type=="Policy") %>% 
  group_by(state) %>%
  summarize(`Number of efforts`=n()) %>%
  rename(state="state", n="Number of efforts")
max(df$n)
p <- plot_usmap(data = df, values="n", labels=TRUE, label_color="black") +
  scale_fill_continuous(low = "white", high = "green", name = "At least one policy", label = scales::comma) +
  labs(
    caption = "Panel B. State policies"
  ) + theme(
    plot.caption = element_text(hjust=0, size=12),
    legend.position = "right") 
p$layers[[2]]$aes_params$size <- 3
p



df <- table_master %>% filter(policy_type=="Executive Order") %>% 
  group_by(state) %>%
  summarize(`Number of policies`=n()) %>%
  rename(state="state", n="Number of policies")
p <- plot_usmap(data = df, values="n", labels=TRUE, label_color="black") +
  scale_fill_continuous(low = "white", high = "blue", name = "Number of Laws", label = scales::comma) +
  labs(title = "Dietary Sodium Related State Laws (Executive Order)", subtitle = "NCSL data from 1965-2020") +
  theme(legend.position = "right")
p$layers[[2]]$aes_params$size <- 3
p

df <- table_master %>% filter(policy_type=="Policy") %>% 
  group_by(state) %>%
  summarize(`Number of Laws`=n()) %>%
  rename(state="state", n="Number of Laws")
p <- plot_usmap(data = df, values="n", labels=TRUE, label_color="black") +
  scale_fill_continuous(low = "white", high = "green", name = "Number of Laws", label = scales::comma) +
  labs(title = "Dietary Sodium Related State Laws (Policies)", subtitle = "NCSL data from 1965-2020") +
  theme(legend.position = "right")
p$layers[[2]]$aes_params$size <- 3
p


#### Count number of policeys by state by category 


# Count of policies per state by type
df <- table_master %>% group_by(state, policy_category_4) %>%
  summarize(`Number of policies`=n()) %>%
  rename(n="Number of policies")

category = unique(table_master$policy_category_4)[2] # change here
df1 <- df %>% filter(policy_category_4 == category)
max(df1$n)
p <- plot_usmap(data = df1, values="n", labels=TRUE, label_color="black") +
  scale_fill_stepsn(breaks = c(1,2), #limits=c(min(df$n),max(df$n)), 
                    labels = c("1", ">1"),
                    colors=c("yellow", "green"),
                    guide = guide_colorsteps(even.steps = FALSE), 
                    name = "Number of Laws") +
  labs(title = paste("Dietary Sodium Related State Laws (", category, ")"), subtitle = "NCSL data from 1965-2020") +
  theme(legend.position = "right")
p$layers[[2]]$aes_params$size <- 3
p
