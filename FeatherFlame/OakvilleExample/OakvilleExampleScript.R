#
# Package loading. I'm partial to using pacman ¯\_(ツ)_/¯ 
#
if (!require("pacman")) install.packages("pacman")
  pacman::p_load(tidyverse, magrittr, lubridate)

#
# Example data download. 
# Data are available on github here:
# https://github.com/devanmcg/FireScienceDIY/raw/master/FeatherFlame/OakvilleExample/OakvilleExampleData.zip
# One can either download the .zip file and save/unzip in a local directory,
# or use these lines to download and unzip to a local temp file 

  data_url = "https://github.com/devanmcg/FireScienceDIY/raw/master/FeatherFlame/OakvilleExample/OakvilleExampleData.zip"
  tmp_dir  = tempdir()
  tmp_file = tempfile(tmpdir = tmp_dir, fileext = ".zip")
  download.file(data_url, tmp_file) 
  unzip(tmp_file, exdir = tmp_dir)

#
# Data loading
#

# Get string of raw file names. 
  # Identify the directory. 
  # Assuming you used the download script above:
    DataDir = tmp_dir
  # If you saved & unzipped yourself, uncomment & modify this one: 
    # DataDir = "C:/Users/"
    
  files <- list.files(path=DataDir, pattern=".TXT$")

# Create empty tibble
  oak_d <- tibble() 

# Cycle through individual data files, 
# store as long format tibble, 
# convert timestamp and temperature column classes,
# reduce length: highest temp in each 1 s from 0.5 s data
  
  for(i in 1:length(files)) {
    oak_d <-
      file.path(paste(DataDir, "/", files[i], sep="")) %>%
      read_csv(col_types = cols(.default = "c"), 
               col_names = FALSE )  %>%
      gather("tc","temp", -X1, -X2) %>%
      setNames(c("logger","timestamp","tc","temp")) %>%
        # if logger was programmed to record more than 4 sensors,
        # add additional lines starting with tc == "X7" ~ "5"
        # to the case_when() call as necessary:
      mutate(tc = case_when(  
                tc == "X3" ~ "1", 
                tc == "X4" ~ "2", 
                tc == "X5" ~ "3", 
                tc == "X6" ~ "4")) %>%
      filter(temp != "nan") %>%
      mutate(timestamp = as.POSIXct(timestamp, 
                                    format = "%Y-%m-%d %H:%M:%OS"), 
             temp = as.numeric(temp)) %>%
      group_by(logger, tc, timestamp) %>%
      summarize(temp = max(temp)) %>%
      ungroup %>%
      bind_rows(., oak_d)
  }

#
# Graphing 
#

# View entire afternoon of logger data
  filter(oak_d, tc == "2") %>%
    ggplot() + theme_bw() +
    geom_line(aes(x=timestamp, y=temp)) +
    facet_wrap(~logger, scales = "free_x")+
    labs(y = expression("Temperature "^o*C)) 

# Filter to get relevant data
  oak_d %<>% filter(hour(timestamp) >= 18, 
                    hour(timestamp) <= 18.5, 
                    temp >= 20) 

# View time-temperature curves
  oak_d %>%
    ggplot() + theme_bw(16) +
    geom_line(aes(x=timestamp, y=temp, 
                  color=tc), show.legend = F) +
    facet_wrap(~logger, scales = "free_x", 
               labeller = label_both) +
    scale_color_manual(values = c("blue", "blue", 
                                  "blue", "black")) +
    labs(y = expression("Temperature "^o*C)) + 
    theme(axis.text.x = element_text(size=10)) 

#
#  Analysis
#

# Find the row in which each thermocouple in the
# triangular array recorded peak temperature
  oak_max <- 
    oak_d %>% 
      filter(tc != "4") %>%
        group_by(logger, tc) %>%
          slice(which.max(temp)) %>%
        ungroup 

# Define the sides of the array equilateral triangle 
  D = 1 # 1m

# Create a tibble of rate of spread by FF logger
  ROS <- 
    oak_max %>%
    mutate( Time = format(timestamp, "%T"), 
            Time = seconds(hms(Time))) %>%
    select(-tc, -temp, -timestamp) %>%
    group_by(logger) %>%
    arrange(Time, .by_group = TRUE) %>% 
    mutate(position = order(order(Time, decreasing=FALSE)), 
           position = recode(position, "1"="a", "2"="b", "3"="c"), 
           Time = as.numeric(Time) /60 ) %>%
    spread(position, Time)  %>%
    ungroup %>% 
    mutate( # This performs Eqs. 2 & 3 in Simard et al. (1982) 
            # Fire Technol. https://doi.org/10.1007/BF02473134
            theta_rad = atan((2*c - b - a) / (sqrt(3)*(b - a))), 
            ros = case_when(
              a == b ~ (sqrt(3) / 2) / (c - a) , 
              a != b ~  (D*cos(theta_rad) / (b - a) ) 
            )) %>%
    select(-a, -b, -c, -theta_rad)
  
    

  

