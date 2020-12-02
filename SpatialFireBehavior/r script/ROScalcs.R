pacman::p_load(tidyverse, lubridate)

setwd("C:/Users/Devan.McGranahan/GoogleDrive/Research/Projects/SpatialFireBehavior")

load("./r objects/temps.Rdata")

# Distance between thermocouples (m)
D = 1 

ROS <- 
  temps %>%
  mutate( Time = format(timestamp, "%T"), 
          Time = seconds(hms(Time))) %>%
  select(-TC, -tempC, -timestamp, -location, -block) %>%
  group_by(FireCode, plot, array) %>%
  arrange(Time, .by_group = TRUE) %>% 
  mutate(position = order(order(Time, decreasing=FALSE)), 
         position = recode(position, "1"="a", "2"="b", "3"="c"), 
         Time = as.numeric(Time) /60 ) %>%
  spread(position, Time)  %>%
  ungroup %>% 
  mutate( theta_rad = atan((2*c - b - a) / (sqrt(3)*(b - a))), 
          ros = case_when(
            a == b ~ (sqrt(3) / 2) / (c - a) , 
            a != b ~  (D*cos(theta_rad) / (b - a) ) 
          )) %>%
  select(-a, -b, -c, -theta_rad)

# save(ROS, file="./r objects/ROS.Rdata")