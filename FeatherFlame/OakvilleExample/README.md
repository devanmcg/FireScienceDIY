
## Packages \& data 

I'm partial to using *pacman* for package installation and loading ¯\\_(ツ)_/¯ 

``` r
if (!require("pacman")) install.packages("pacman")
  pacman::p_load(tidyverse, magrittr, lubridate)
```
Two options for downloading the example data from Oakville Prairie:

* If you think you want to keep the files, download the `.zip` file yourself and put the raw files somewhere you can find them: [OakvilleExampleData.zip](https://github.com/devanmcg/FireScienceDIY/raw/master/FeatherFlame/OakvilleExample/OakvilleExampleData.zip)
* If you just want to see how this all works, use this script to have **R** download and unzip by itself to a temporary folder that will go away eventually:

``` r

  data_url = "https://github.com/devanmcg/FireScienceDIY/raw/master/FeatherFlame/OakvilleExample/OakvilleExampleData.zip"
  tmp_dir  = tempdir()
  tmp_file = tempfile(tmpdir = tmp_dir, fileext = ".zip")
  download.file(data_url, tmp_file) 
  unzip(tmp_file, exdir = tmp_dir)
```
Either way you need to tell **R** where to find the raw data files. 
Specify a directory as `DataDir`:

``` r
# Get string of raw file names. 
  # Identify the directory. 
  # Assuming you used the download script above:
    DataDir = tmp_dir
  # If you saved & unzipped yourself, uncomment & modify this one: 
    # DataDir = "C:/Users/"
```

This script goes and gets the individual files from each FeatherFlame datalogger and combines them into a single `tibble` object in your **R** workspace. 
It does a few other things along the way:
* stores in long format 
* converts timestamp and temperature classes
* Reduces length by finding the highest temp for each 1 s from the half-second resolution data

``` r
# Get string of file names
  files <- list.files(path=DataDir, pattern=".TXT$")
  
# Create empty tibble
  oak_d <- tibble() 

# Load & process individual data files 
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
```

## Graphing 

Since the loggers were deployed prior to ignition, there are hours of meaningless data on the ambient air temperature on either side of the few seconds we're interested in -- when the flame front passes. 
Let's just look at one thermocouple as an example:

<img src="https://github.com/devanmcg/FireScienceDIY/raw/master/FeatherFlame/OakvilleExample/AllAfternoonLogger2.png" width="600">

So we should filter down to get the relevant data. 
This is a tough process to automate.
For now, we'll just filter down to the 30 min or so of action:

``` r
  oak_d %<>% filter(hour(timestamp) >= 18, 
                    hour(timestamp) <= 18.5, 
                    temp >= 20)
```
Now we can get a good look at our time-temperature curves:

``` r 
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
```

<img src="https://github.com/devanmcg/FireScienceDIY/raw/master/FeatherFlame/OakvilleExample/TTcurves.png" width="600">

There are some interesting things going on here: 
* Lag effects between standing fuel and litter. 
  - The time-temperature trends for the three thermocouple probes held above the ground in the triangular array are plotted in blue, while the probe placed on the soil surface is plotted in black. 
  - Note how the soil surface probe temp generally raises more slowly, and later, than the other probes. 
  This is a consequence of post-frontal combustion, or smouldering, in the litter layer after the main flame front passes. 
  - Without multiple sensors per logger, it would be difficult to get these data at the same point. 
  And without the synchronised timestamp from the common logger here, it would be a lot of work to ensure timestamps lined up enough to detect the lag effect.
* Differences between peak temps = rate of spread.
  - The numerals represent rate of spread through the triangular array, as calculated below. 
  - Those calculations basically quantify what we can see among the peaks.

## Analysis

First, we find the row in which each thermocouple in the triangular array recorded peak temperature: 

``` r
  oak_max <- 
    oak_d %>% 
      filter(tc != "4") %>%
        group_by(logger, tc) %>%
          slice(which.max(temp)) %>%
        ungroup 
```
This chunk is where the magic happens: via a *dplyr* pipe we crunch the equations provided by [Simard et al. (1982)](https://doi.org/10.1007/BF02473134) to calculate how fast the flame front moved through the triangular array, using the seconds of peak temperature as the arrival time at each point:

``` r
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
    mutate( theta_rad = atan((2*c - b - a) / (sqrt(3)*(b - a))), 
            ros = case_when(
              a == b ~ (sqrt(3) / 2) / (c - a) , 
              a != b ~  (D*cos(theta_rad) / (b - a) ) 
            )) %>%
    select(-a, -b, -c, -theta_rad)
```
|logger |      ros|
|:------|--------:|
|1      | 2.002970|
|2      | 3.375264|
|3      | 3.511234|
|4      | 4.610840|
|5      | 2.559961|
|6      | 3.273268|  
    

  

