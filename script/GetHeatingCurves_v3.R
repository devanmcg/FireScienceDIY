#
# U S E   C A S E   E X A M P L E
#
# NOT RUN:
#
# tc_data <- GetHeatingCurves(
#                 FilePath = 'C:/.../FireBehavior/DroughtPlots/',
#                 type = 'FF',
#                 MinTemp = '40',
#                 ExcludeColumns = c("logger", "timestamp")
#                   )

GetHeatingCurves <- function(FilePath, 
                             type, 
                             MinTemp, 
                             ExcludeColumns = NULL) {

  # Function depends on these packages:
    require(tidyverse)
    suppressMessages(require(FSA))
  # directions to pop up as a message before clicking 
     Directions = ("An external graphics window will open. (might be minimized)
                  D I R E C T I O N S
                  Graph displays the entire period of data on the channel named.
                  You are to identify the beginning and end of heating curves
                  by clicking the crosshairs right below the line of data
                  where you would like to trim the data down. 
                  Only data between pairs of clicks will be retained. 
                  There must be an even number of clicks.
                  (An odd number of clicks will prompt a re-do.)
                 
                  When done, click Stop, Stop locator in upper left.
                
                                     _
                                    _ _
                                   _   __
                                  _      __
                                 _         ___
                                _             ___
                               _                 ____
                              _                      ____
                             _                           ______
                            _                                  _______
                  _________                                           ________________
                        ^                                               ^
                    First click                                   Second click
                  
                P R O  T I P:  Keep the crosshairs low when you click
             (Basically, use the top of the vertical bar as your pointer)
               
                MAKE A MISTAKE? Ensure an odd number of clicks, then click Stop. 
                  You'll be prompted for a re-do for that channel.")
  # Process user input on datalogger type
  if (type %in% c('HOBO', 'hobo', 'H', 'h')) {
      t = 'h'
      } else if (type %in% c('FF', 'ff', 'FeatherFlame', 'featherflame', 'feather')) {
      t = 'f'
    } else stop("Unexpected argument: type. Must be one of 'HOBO' or 'FeatherFlame'. ")
    
  
  tc_files <- list.files(FilePath)
  message(paste0(length(tc_files), ' files found.'))
  
  # Add R object for results to global environment 
  if(exists('HeatingCurves')){
    exist <- readline(prompt = message("I need to create an object called 'HeatingCurves',\nbut there is already one in your Global Environment.\nTo reassign it before I proceed, enter a new object name.\nIf I can overwrite it, press Enter.") )
  }
  HeatingCurves <<- tibble() 
  
  if (t == 'h') {
# Main single-channel logger work loop
  for(i in 1:length(tc_files)){ 
    message(paste0("Loading file ", tc_files[i]), '...')
    rd <- 
      paste0(FilePath, tc_files[i]) %>%
      read_csv(skip = 2, col_names = c('obs', 'timestamp', 'degC')) 
    message(paste0("...file ", tc_files[i], ' loaded.'))
    
    message(Directions)
    x11()
    plot(degC ~ obs, rd, 
         type = 'l', las = 1, 
         main = tc_files[i]) 
    pts <- identify(rd$obs, 
                    rd$degC, 
                    labels = "^", 
                    col = "red") ; dev.off()
    
    # perform check on incorrect/empty input
    if(FSA::is.odd(length(pts)) || length(pts) == 0) {
      
     oops <- readline(prompt = message("Looks like that didn't go right.\nWant to try that logger again?\n 1: Yes, re-do that logger\n 0: No, skip to next logger") ) 
    
    if(oops == "1") { 
      # Allow user to re-do a channel 
      x11()
      plot(degC ~ obs, rd, 
           type = 'l', las = 1, 
           main = tc_files[i]) 
      pts <- identify(rd$obs, 
                      rd$degC, 
                      labels = "^", 
                      col = "red") ; dev.off() 
    } else{ next }# skip to next channel 
    } # close check on incorrect/empty input
    
     # Proceed with processing logger data 
    while(FSA::is.even(length(pts))) {
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
    for(e in 1:length(unique(events$event))) { # rough windows for unique events
      event = filter(events, event == e) 
      filter(rd, between(obs, event$obs[1], event$obs[2])) %>%
        mutate(file = str_remove(tc_files[i], ".csv"), 
               event = e) %>%
        select(file, event,obs, timestamp, degC) %>%
        bind_rows(rough_windows) -> rough_windows
    } # close rough windows unique event loop
    
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
    
    for(e in 1:max(maxes$event)) { # get max C event rows
      m = filter(maxes, event == e)$obs
      rough_windows %>%
        filter(event == e ,  
               obs <= m) %>%
        bind_rows(HeatingCurves) -> HeatingCurves
    } # close while loop for even number of clicks 
    } # close max C event loop
    
  } # close single channel work loop
    # return(HeatingCurves)
    message("Processing complete.\nPlease find object 'HeatingCurves' in Global Environment.")
  } # close loop for single-channel logger option
  else { # Move to multi-channel logger option
    message(Directions) # Give the directions via the console once
    if (is.null(ExcludeColumns)) { # Test that ExcludeColumns has been entered
      stop("ExcludeColumns empty. Specify one or more columns to pivot on.")
    } 
    else{ # work through muli-channel logger after passing ExcludeColumns check
    for(i in 1:length(tc_files)){ # loop through files (main work loop)
      # get i-th file from the file path
      message(paste0("Loading file ", tc_files[i]), '...')
        rd1 <- 
          paste0(FilePath, tc_files[i]) %>%
          read_csv(col_names = FALSE)
      message(paste0("...file ", tc_files[i], ' loaded.'))
      # Prepare data for pivoting
        tcs <- dim(rd1)[2] - length(ExcludeColumns)
        colnames(rd1) <- c(ExcludeColumns, seq(1, tcs, 1))
      # Pivot logger data into long format
      rd <-
        rd1 %>%
          pivot_longer(values_to = 'degC', 
                       names_to = 'TC', 
                       -paste(ExcludeColumns)) %>%
          group_by(TC) %>%
          mutate(obs = seq(1, n(), 1)) %>%
          ungroup() 
  #
  # Allow user to select channels to input
  #
    # Show all channels 
    #x11() 
    dl_plot <-
      rd %>%
        ggplot() + theme_bw(14) + 
          geom_line(aes(x = obs, 
                        y = degC)) + 
        labs(title = paste0("Logger ", unique(rd$logger))) + 
          facet_wrap(~TC, scales = "free_y")
    print(dl_plot)
    # Prompt channel selection 
      channels <- readline(prompt = message("Select channels to import (see graphics device) by entering numbers of desired channels separated by commas, or...\n Enter: select all channels\n 0: None (and skip to next file)\n Q: quit (then select Cancel to avoid closing R altogether)")) # \nTo *exclude* certain channels, precede channel number with negative sign (-)."))
      
      if(channels == "Q") { 
        quit(save = 'ask') 
        } else {
      if(channels == "") { 
          selections <- unique(rd$TC) 
          } else {
           selections <- ifelse(channels %in% c('0', 'O'), 'NULL', channels) 
           selections <- unlist(strsplit(selections, ",")) %>% 
                                  trimws()  
                 } 
               }

       # message(Directions) # Give the directions via the console for each file
    if(selections != "NULL") {
     for(j in 1:length(selections)) { # loop through multi-channel data on logger file
       tc = as.numeric(selections[j] ) 
        rd_j <- filter(rd, TC == unique(rd$TC)[tc])
      # User interaction section. 
      # Open external window
      x11()
      plot(degC ~ obs, 
           rd_j,  
           type = 'l', las = 1, 
           main = paste0('Logger ', unique(rd_j$logger),', sensor ', unique(rd_j$TC)) )  
      pts <- identify(rd_j$obs,
                      rd_j$degC, 
                      labels = "^", 
                      col = "red") ; dev.off() 
      # perform check on incorrect/empty input
      if(FSA::is.odd(length(pts)) || length(pts) == 0) {
        
        oops <- readline(prompt = message("Looks like that didn't go right.\nWant to try that channel again?\n 1: Yes, re-do that channel\n 0: No, skip to next channel\n Q: quit (then select Cancel to avoid closing R altogether)") ) 
        
        if(oops == "Q") { 
          quit(save = 'ask') 
        } else{
          if(oops == "1") { 
          # Allow user to re-do a channel 
          x11()
          plot(degC ~ obs, 
               rd_j,  
               type = 'l', las = 1, 
               main = paste0('Logger ', unique(rd_j$logger),', sensor ', unique(rd_j$TC)) ) 
          pts <- identify(rd$obs, 
                          rd$degC, 
                          labels = "^", 
                          col = "red") ; dev.off() 
        } else{ next }# skip to next channel 
      } # close non-Q oops handling
        } # close check on incorrect/empty input
      
      # Proceed with processing logger data 
      # process user-defined events
      # identify beginning and end points of rough windows
      events <- 
        pts %>%
        as_tibble(rownames = "click") %>%
        rename(obs = value) %>%
        mutate( click = as.numeric(click), 
                rough_endpt = ifelse(FSA::is.odd(click), "start", "stop"), 
                logger = unique(rd_j$logger), 
                tc = unique(rd_j$TC)) %>%
        group_by(rough_endpt) %>%
        mutate(event = seq(1:n())) %>%
        ungroup() %>%
        select(-click) 
      
      rough_windows <- tibble()
      for(e in 1:length(unique(events$event))) { # Loop through fire events on channel
        event = filter(events, event == e) 
        filter(rd_j, between(obs, event$obs[1], event$obs[2])) %>%
          mutate(logger = unique(rd_j$logger),
                 event = e) %>%
          select(logger, TC, event,obs, timestamp, degC) %>%
          bind_rows(rough_windows) -> rough_windows
      } # close events loop
      
      rough_windows <- filter(rough_windows, degC >= MinTemp) 
      
      # rough_windows %>%
      #   ggplot() + theme_bw(14) +
      #   geom_line(aes(x = obs, y = degC)) +
      #   facet_wrap(~event, scales = 'free_x') +
      #   labs(title = paste0('Logger ', unique(rd_j$logger),', sensor ', unique(rd_j$TC)), 
      #        subtitle = "User-identified rough windows of flame front passage")
      
      maxes <- 
        rough_windows %>%
        group_by(event, obs) %>%
        summarize(Max = max(degC), 
                  .groups = 'drop_last') %>%
        slice(which.max(Max)) %>%
        ungroup() 
      hc <- tibble() 
      for(e in 1:max(maxes$event)) { # loop through events, take out max C rows
        m = filter(maxes, event == e)$obs
        rough_windows %>%
          filter(event == e ,  
                 obs <= m) %>%
             bind_rows(hc) -> hc
      } # close max loop
     HeatingCurves <<- bind_rows(HeatingCurves, hc)
    } # close multi-channel loop
      message("Finished with that file.")
      } # closes main work loop 
      # return(HeatingCurves)
  } # closes ExcludeCOlumns check
    }
  } # close loop for multi-channel logger option
  message("\nProcessing complete.\nPlease find object 'HeatingCurves' in Global Environment.")
}   # closes function. EL FIN.

