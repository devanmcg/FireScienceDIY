
GetHeatingCurves <- function(FilePath, MinTemp) {
  require(tidyverse)
  require(FSA)
tc_files <- list.files(FilePath) 

HeatingCurves <- tibble() 

for(i in 1:length(tc_files)){
  rd <- 
  paste0(hobo_fp, tc_files[i]) %>%
    read_csv(skip = 2, col_names = c('obs', 'timestamp', 'degC')) 
  
  x11() 
  plot(degC ~ obs, rd, 
       type = 'l', las = 1, 
       main = tc_files[i]) 
    pts <- identify(rd$obs, 
                    rd$degC, 
                    labels = "^", 
                    col = "red") ; dev.off() 
  
  events <- 
    pts %>%
      as_tibble(rownames = "click") %>%
      rename(obs = value) %>%
      mutate( click = as.numeric(click), 
              rough_endpt = ifelse(FSA::is.odd(click), "start", "stop"), 
              file = str_remove(tc_files[i], ".csv")) %>%
          group_by(rough_endpt) %>%
          mutate(event = seq(1:n())) %>%
        ungroup() %>%
        select(-click) 
  
  rough_windows <- tibble()
  for(e in 1:length(unique(events$event))) {
    event = filter(events, event == e) 
    filter(rd, between(obs, event$obs[1], event$obs[2])) %>%
      mutate(file = str_remove(tc_files[i], ".csv"), 
             event = e) %>%
      select(file, event,obs, timestamp, degC) %>%
      bind_rows(rough_windows) -> rough_windows
  }
  
  rough_windows <- filter(rough_windows, degC >= MinTemp) 
  
  rough_windows %>%
    ggplot() + theme_bw(14) +
      geom_line(aes(x = obs, y = degC)) +
      facet_wrap(~event, scales = 'free_x')

  maxes <- 
    rough_windows %>%
        group_by(event, obs) %>%
        summarize(Max = max(degC)) %>%
      slice(which.max(Max)) %>%
        ungroup() 
  
  for(e in 1:max(maxes$event)) {
    m = filter(maxes, event == e)$obs
    rough_windows %>%
    filter(event == e ,  
           obs <= m) %>%
      bind_rows(HeatingCurves) -> HeatingCurves
  }
  
}
  return(HeatingCurves)
}
