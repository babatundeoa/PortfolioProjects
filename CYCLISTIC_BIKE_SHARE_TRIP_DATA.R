#Loading necessary packages

install.packages("tidyverse")
install.packages("lubridate")
install.packages("ggplot2")
install.packages("dplyr")
install.packages("geosphere")
library(tidyverse)
library(lubridate)
library(ggplot2)
library(dplyr)
library(geosphere)

#Importing 12 months data to R studio

apr21 <- read_csv("C:/Users/STUDY/Documents/CyclisticTripData/202104-divvy-tripdata.csv")
may21 <-read_csv("C:/Users/STUDY/Documents/CyclisticTripData/202105-divvy-tripdata.csv")
june21 <- read_csv("C:/Users/STUDY/Documents/CyclisticTripData/202106-divvy-tripdata.csv")
july21 <- read_csv("C:/Users/STUDY/Documents/CyclisticTripData/202107-divvy-tripdata.csv")
aug21 <- read_csv("C:/Users/STUDY/Documents/CyclisticTripData/202108-divvy-tripdata.csv")
sep21 <- read_csv("C:/Users/STUDY/Documents/CyclisticTripData/202109-divvy-tripdata.csv")
oct21 <- read_csv("C:/Users/STUDY/Documents/CyclisticTripData/202110-divvy-tripdata.csv")
nov21 <- read_csv("C:/Users/STUDY/Documents/CyclisticTripData/202111-divvy-tripdata.csv")
dec21 <- read_csv("C:/Users/STUDY/Documents/CyclisticTripData/202112-divvy-tripdata.csv")
jan22 <- read_csv("C:/Users/STUDY/Documents/CyclisticTripData/202201-divvy-tripdata.csv")
feb22 <- read_csv("C:/Users/STUDY/Documents/CyclisticTripData/202202-divvy-tripdata.csv")
mar22 <- read_csv("C:/Users/STUDY/Documents/CyclisticTripData/202203-divvy-tripdata.csv")

#Making column consistent and merging them into a single dataframe

trip_data <- bind_rows(apr21, may21, june21, july21, aug21, sep21, oct21, nov21, dec21, jan22, feb22, mar22)
head(trip_data)
view(trip_data)
nrow(trip_data)
summary(trip_data)
str(trip_data)
tail(trip_data)

#Adding coloumns for date, month, year, day of the week into the data frame.

trip_data$date <- as.Date(trip_data$started_at)
trip_data$month <- format(as.Date(trip_data$date), "%m")
trip_data$day <- format(as.Date(trip_data$date), "%d")
trip_data$year <- format(as.Date(trip_data$date), "%y")
trip_data$day_of_week <- format(as.Date(trip_data$date), "%A")
colnames(trip_data)

#Add a ride_length calculation to trip_data

trip_data$ride_length <- difftime(trip_data$ended_at, trip_data$started_at)
str(trip_data)

#Convert ride_length from Factor to Numeric in order to run calculations

trip_data$ride_length <- as.numeric(as.character(trip_data$ride_length))
is.numeric(trip_data$ride_length)

#Add ride_distance calculation to trip_data
trip_data$ride_distance <- distGeo(matrix(c(trip_data$start_lng, trip_data$start_lat),ncol=2), matrix (c(trip_data$end_lng, trip_data$end_lat), ncol=2))
trip_data$ride_distance <- trip_data$ride_distance/1000

#Remove "bad" data

trip_data_clean <-trip_data[!(trip_data$ride_length <= 0),]
glimpse(trip_data_clean)

#ANALYSE STAGE

str(trip_data_clean)
summary(trip_data_clean)


#Descriptive analysis on "ride_length"

trip_data_clean %>%
  group_by(member_casual) %>%
  summarise(average_ride_length = mean(ride_length), median_length = median(ride_length), max_ride_length = max(ride_length), min_ride_length = min(ride_length))
trip_data_clean %>%
  group_by(member_casual) %>%
  summarise(ride_count = length(ride_id))

#Total rides and average ride time by each day for members vs casual riders

#Order the days of the week

trip_data_clean$day_of_week <-ordered(trip_data_clean$day_of_week,
                                      levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))
trip_data_clean %>%
  group_by(member_casual, day_of_week) %>%
  summarise(number_of_rides = n(), average_ride_length = mean(ride_length), .groups="drop") %>%
  arrange(member_casual, day_of_week)

#Visualize the above table by days of the week and number of rides taken by member and casual riders

trip_data_clean%>%
  group_by(member_casual, day_of_week) %>%
  summarise(number_of_rides=n(), .groups="drop")%>%
  arrange(member_casual, day_of_week)%>%
  ggplot(aes(x=day_of_week, y=number_of_rides, fill =member_casual))+
  labs(title="Total rides of Members and Casual riders Vs. Day of the week")+
  geom_col(width=0.5, position=position_dodge(width=0.5))+
  scale_y_continuous(labels=function(x)format(x, scientific = FALSE))

#Visualization of average ride by day of the week

trip_data_clean %>%
  group_by(member_casual, day_of_week) %>%
  summarise(average_ride_length =mean(ride_length), .groups="drop") %>%
  ggplot(aes(x = day_of_week, y = average_ride_length, fill = member_casual)) +
  geom_col(width=0.5, position = position_dodge(width=0.5)) +
  labs(title ="Average ride time of Members and Casual riders Vs. Day of the week")

#Visualization of the total rides taken by members and casuals by month

trip_data_clean %>%
  group_by(member_casual, month) %>%
  summarise(number_of_rides = n(),.groups="drop") %>%
  arrange(member_casual, month)  %>%
  ggplot(aes(x = month, y = number_of_rides, fill = member_casual)) +
  labs(title ="Total rides by Members and Casual riders by Month") +
  theme(axis.text.x = element_text(angle = 45)) +
  geom_col(width=0.5, position = position_dodge(width=0.5)) +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE))

#Visualization Comparison of Members and Casual riders depending on ride distance

trip_data_clean %>%
  group_by(member_casual) %>% drop_na() %>%
  summarise(average_ride_distance = mean(ride_distance)) %>%
  ggplot() +
  geom_col(mapping= aes(x= member_casual, y= average_ride_distance, fill=member_casual), show.legend = FALSE)+
  labs(title = "Mean distance traveled by Members and Casual riders")

#Exporting the Dataframe as .csv file

write.csv(trip_data_clean, "C:/Users/STUDY/Documents/CyclisticTripData/trip.csv")
