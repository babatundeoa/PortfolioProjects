#Installing packages

install.packages("tidyverse")
install.packages("lubridate")
install.packages("ggplot2")
install.packages("anytime")
install.packages("scales")
install.packages("hrbrthemes")
install.packages("qqman")
install.packages("ggpubr")
library(tidyverse)
library(lubridate)
library(ggplot2)
library(anytime)
library(stringr)
library(scales)
install.packages("gridExtra")
install.packages("ggthemes", dependencies = TRUE)
library(gridExtra)
library(ggthemes)
library(hrbrthemes)
library(qqman)
vignette('qqman')
library(ggpubr)


#Importing Datasets

January <- read_csv("Sales_January_2019.csv")
February <- read_csv("Sales_February_2019.csv")
March <- read_csv("Sales_March_2019.csv")
April <- read_csv("Sales_April_2019.csv")
May <- read_csv("Sales_May_2019.csv")
June <- read_csv("Sales_June_2019.csv")
July <- read_csv("Sales_July_2019.csv")
August <- read_csv("Sales_August_2019.csv")
September <- read_csv("Sales_September_2019.csv")
October <- read_csv("Sales_October_2019.csv")
November <- read_csv("Sales_November_2019.csv")
December <- read_csv("Sales_December_2019.csv")


#DATA MANIPULATION

# Marging all datasets into a single data frame

Sales_2019 <- bind_rows(January, 
                        February, 
                        March, 
                        April, 
                        May, 
                        June, 
                        July, 
                        August, 
                        September, 
                        October, 
                        November, 
                        December)

#Changing name of Variables

Sales_2019 <- Sales_2019 %>% 
  rename(Quantity_Ordered = `Quantity Ordered`,
         Order_ID = `Order ID`,
         Price = `Price Each`,
         Order_Date = `Order Date`,
         Purchase_Address = `Purchase Address`)

#checking the datatype of the variables

str(Sales_2019)

#Changing Variable datatype of Order_Date

Sales_2019$Order_Date = as.POSIXct(Sales_2019$Order_Date, format = "%m/%d/%y %H:%M")

#Changing Quantity_Ordered and Price Data Type to integer

Sales_2019$Quantity_Ordered<- as.integer(Sales_2019$Quantity_Ordered)
Sales_2019$Price<- as.integer(Sales_2019$Price)

#Creating Month, Day, Year and Day of the week from Order_Date variable

Sales_2019$Month <- format(Sales_2019$Order_Date, "%B")
Sales_2019$Day <- format(as.Date(Sales_2019$Order_Date), "%d")
Sales_2019$Year <- format(as.Date(Sales_2019$Order_Date), "%y")
Sales_2019$Day_of_Week <- format(as.Date(Sales_2019$Order_Date), "%A")

#Creating Hour variable from Order_Date

Sales_2019$Hour = format(Sales_2019$Order_Date, "%H")

#Separating Address, City and State from Purchase_address

Sales_2019 <- Sales_2019 %>% 
  separate(Purchase_Address, c("Address", "City", "State"),sep = ",")

#Separating State and Zipcode from State

Sales_2019 <- Sales_2019 %>% 
  separate(State, c("EmptySpace","State", "Zipcode"),sep = " ")

# Deleting Variables

Sales_2019$EmptySpace <- NULL

Sales_2019$...1 <- NULL

Sales_2019$Year <- NULL


#Checking out empty Columns (We have 900 entries of not completed rolls/missing values)

Missing_Values <- Sales_2019 %>% 
  select(Order_ID, Product, everything()) %>% 
  filter(!complete.cases(.))


#Cleaned Data Set

Clean_Sales_2019 <- Sales_2019 %>% 
  select(Order_ID, Product, everything()) %>% 
  filter(complete.cases(.))


#Multiplied Quantity Ordered by Price to get Sales column

Clean_Sales_2019$Sales <- Clean_Sales_2019$Quantity_Ordered * Clean_Sales_2019$Price



#DATA VISUALIZATION


#Q: What was the best month for sales? How much was earned that month?


Clean_Sales_2019 %>% 
  group_by(Month) %>% 
  summarise(Sales_Month = sum(Sales)) %>% 
  arrange(desc(Sales_Month)) %>% 
  ggplot(aes(x = Month, y = Sales_Month, color = Month, fill = Month))+
  geom_col(width=0.5, position = position_dodge(width=0.5))+
  theme(axis.text.x = element_text(angle = 45))+
  labs(title = "What was the best month for sales? How much was earned that month?")+
  scale_y_continuous(labels = comma)+
  scale_x_discrete(limits = month.name)
          
#Q: What City had the highest number of sales?

Clean_Sales_2019 %>% 
  group_by(City) %>% 
  summarise(Sales_City = sum(Sales)) %>% 
  arrange(desc(Sales_City)) %>% 
  ggplot(aes(x = City, y = Sales_City, color = City, fill = City))+
  geom_bar(stat="identity", position=position_dodge())+
  coord_polar(theta = "x",start=0)+
  labs(title = "What City had the highest number of sales?")+
  scale_y_continuous(labels = comma)


#Q What time should advertisements be displayed to increase the likelihood of a sale?

Clean_Sales_2019 %>% 
  group_by(Hour) %>% 
  summarise(Sales_by_hours = sum(Sales)) %>% 
  arrange(desc(Sales_by_hours)) %>% 
  tail(24) %>%
  ggplot( aes(x=Hour, y=Sales_by_hours)) +
  geom_line( color="black") +
  geom_point(shape=21, color="black", fill="#69b3a2", size=3) +
  theme_ipsum() +
  ggtitle("What time should advertisements be displayed to increase the likelihood of a sale?")


#What Day of the week has the most sales?

Clean_Sales_2019 %>% 
  group_by(Day_of_Week) %>% 
  summarise(Sales_Month = sum(Sales)) %>% 
  arrange(desc(Day_of_Week)) %>% 
  ggplot(aes(x = Day_of_Week, y = Sales_Month, color = Day_of_Week, fill = Day_of_Week))+
  geom_col(width=0.5, position = position_dodge(width=0.5))+
  theme(axis.text.x = element_text(angle = 45))+
  labs(title = "What was the best month for sales? How much was earned that month?")+
  scale_y_continuous(labels = comma)+
  rotate()



#Q What products are most often sold together?


Products_Sold_Together <- Clean_Sales_2019[duplicated(Clean_Sales_2019$Order_ID) | duplicated(Clean_Sales_2019$Order_ID, fromLast = TRUE), ]


Products_Sold_Together <- Products_Sold_Together %>%
  group_by(Order_ID) %>%
  mutate(`Group_Product` = paste0(Product, collapse = ", ")) %>%
  ungroup()

###########################

Products_Sold_Count <- Products_Sold_Together %>% 
  group_by(Group_Product) %>% 
  summarise(total_count=n(), .groups = 'drop') %>% 
  arrange(desc(total_count))

Plot <- Products_Sold_Together %>% group_by(Group_Product) %>%
  summarise(count = n()) %>%
  top_n(n = 5, wt = count)

ggplot(Plot, aes(x = Group_Product, y = count, color = Group_Product, fill = Group_Product))+
  geom_col(width=0.5, position = position_dodge(width=0.5))+
  theme(axis.text.x = element_text(angle = 45))+
  labs(title = "What products are most often sold together??")
 


#Q What product sold the most? Why do you think it sold the most?

Clean_Sales_2019 %>% 
  group_by(Product) %>% 
  summarise(Quantity_sold = sum(Quantity_Ordered)) %>% 
  arrange(desc(Quantity_sold)) %>% 
  ggplot(aes(x = Product, y = Quantity_sold, color = Product, fill = Product))+
  geom_col(width=0.5, position = position_dodge(width=0.5))+
  theme(axis.text.x = element_text(angle = 45))+
  labs(title = "What product sold the most? Why do you think it sold the most?")+
  scale_y_continuous(labels = comma)

#Q Which product generated most sales?

Clean_Sales_2019 %>% 
  group_by(Product) %>% 
  summarise(Product_sales = sum(Sales)) %>% 
  arrange(desc(Product_sales)) %>% 
  ggplot(aes(x = Product, y = Product_sales, color = Product, fill = Product))+
  geom_col(width=0.5, position = position_dodge(width=0.5))+
  theme(axis.text.x = element_text(angle = 45))+
  labs(title = "Which product generated most sales??")+
  scale_y_continuous(labels = comma)


#How many did each product sell each month?

By_Month <- Clean_Sales_2019 %>% 
  group_by(Month, Product) %>% 
  summarise(Quantity_sold = sum(Quantity_Ordered)) %>% 
  arrange(desc(Month))

  ggplot(By_Month, aes(x = Product, y= Quantity_sold, color = Month, fill = Month))+
  geom_col(width=0.5, position = position_dodge(width=0.5))+
  theme(axis.text.x = element_text(angle = 45))+
  labs(title = "How many did each product sell each month??")+
  scale_y_continuous(labels = comma)+
  facet_wrap(~Month)+
    rotate()
  
  #How much did each product sell each month?
  
  By_Sales <- Clean_Sales_2019 %>% 
    group_by(Month, Product) %>% 
    summarise(Sales = sum(Sales)) %>% 
    arrange(desc(Month))
  
  ggplot(By_Sales, aes(x = Product, y= Sales, color = Month, fill = Month))+
    geom_col(width=0.5, position = position_dodge(width=0.5))+
    theme(axis.text.x = element_text(angle = 45))+
    labs(title = "How much did each product sell each month??")+
    scale_y_continuous(labels = comma)+
    facet_wrap(~Month)+
    rotate()

  #How many of each product did we sell in each city?
  By_City <- Clean_Sales_2019 %>% 
    group_by(City, Product) %>% 
    summarise(Quantity_sold = sum(Quantity_Ordered)) %>% 
    arrange(desc(City))
  
  ggplot(By_City, aes(x = Product, y= Quantity_sold, color = City, fill = City))+
    geom_col(width=0.5, position = position_dodge(width=0.5))+
    theme(axis.text.x = element_text(angle = 45))+
    labs(title = "How many of each product did we sell in each city?")+
    scale_y_continuous(labels = comma)+
    facet_wrap(~City)+
    rotate()
