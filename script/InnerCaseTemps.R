
# Oakville trials 

DataDir = "C:/Users/Devan.McGranahan/GoogleDrive/FireScienceDIY/data/OakvilleRaw"

files <- list.files(path=DataDir, pattern=".TXT$")

tmp_oak <- tibble() 


for(i in 1:length(files)) {
  tmp_oak <-
    file.path(paste(DataDir, "/", files[i], sep="")) %>%
    read_csv(col_types = cols(.default = "c"), 
             col_names = FALSE )  %>%
    select_at(vars(names(.)[1], 
                   names(.)[2],
                   names(.)[length(names(.))])) %>%
    setNames(c("logger","timestamp","CaseTemp")) %>%
    filter(CaseTemp != "nan") %>%
    mutate(timestamp = as.POSIXct(timestamp, 
                                  format = "%Y-%m-%d %H:%M:%OS"), 
           CaseTemp = as.numeric(CaseTemp)) %>%
    group_by(logger, timestamp) %>%
    summarize(CaseTemp = max(CaseTemp)) %>%
    ungroup %>%
    bind_rows(., tmp_oak)
}

tmp_oak %>% filter(day(timestamp) == 25, 
                 hour(timestamp) >= 18, 
                 logger %in% c("1", "2", "4")) %>%
  mutate(logger = case_when(
    logger == "4" ~ "3", 
    T ~ logger  )) %>%
  ggplot() + theme_bw(16) +
  geom_smooth(aes(x=timestamp, y=CaseTemp), lwd=1.25) +
  facet_wrap(~logger, scales = "free_x", 
             labeller = label_both)+
  labs(y = expression("Temperature "^o*C)) 
  

HREC = "C:/Users/Devan.McGranahan/GoogleDrive/R-duino/FeatherFlame/data/HREC/2017/2017_HERC"

files <- list.files(path=HREC, pattern=".TXT$")

tmp_h <- tibble() 


for(i in 1:length(files)) {
  tmp_h <-
    file.path(paste(HREC, "/", files[i], sep="")) %>%
    read_csv(col_types = cols(.default = "c"), 
             col_names = FALSE )  %>%
    select_at(vars(names(.)[1], 
                   names(.)[2],
                   names(.)[length(names(.))])) %>%
    setNames(c("logger","timestamp","CaseTemp")) %>%
    filter(CaseTemp != "nan") %>%
    mutate(timestamp = as.POSIXct(timestamp, 
                                  format = "%Y-%m-%d %H:%M:%OS"), 
           CaseTemp = as.numeric(CaseTemp)) %>%
    group_by(logger, timestamp) %>%
    summarize(CaseTemp = max(CaseTemp)) %>%
    ungroup %>%
    bind_rows(., tmp_h)
}

tmp_h %>%
  mutate(day = day(timestamp), 
         time = format(timestamp, "%H:%M:%S")) %>%
  ggplot() + theme_bw(16) +
  geom_smooth(aes(x=time, y=CaseTemp, 
                  color = day), lwd=1.25) +
  facet_wrap(~ logger, scales = "free_x", 
             labeller = label_both)+
  labs(y = expression("Temperature "^o*C)) 


tmp_h %>%
  filter(CaseTemp >= 5, 
         logger %in% c("1","2","4")) %>%
  mutate(day = day(timestamp), 
         burn = case_when(
           day == "27" & hour(timestamp) <= 14.5 ~ "1",
           logger == "1" & day == "28" & hour(timestamp) <= 12.99 ~ "1",
           logger == "2" & day == "28" & hour(timestamp) <= 12.5 ~ "1",
           logger == "4" & day == "28" & hour(timestamp) <= 12.9 ~ "1",
           T ~ "2"
         )) %>%
  filter(row_number() %% 5 == 1) %>%
  ggplot() + theme_bw(16) +
  geom_point(aes(x=timestamp, y=CaseTemp, 
                 color= burn)) + 
  geom_smooth(aes(x=timestamp, y=CaseTemp, 
                  color = burn), lwd=1.25) +
  facet_wrap(~ day + logger, scales = "free_x", 
             labeller = label_both)+
  labs(y = expression("Temperature "^o*C)) 

tmp_h %>%
  filter(CaseTemp >= 5, 
         logger %in% c("1","2","4")) %>%
  mutate(day = day(timestamp), 
         burn = case_when(
           day == "27" & hour(timestamp) <= 14.5 ~ "1",
           logger == "1" & day == "28" & hour(timestamp) <= 12.99 ~ "1",
           logger == "2" & day == "28" & hour(timestamp) <= 12.5 ~ "1",
           logger == "4" & day == "28" & hour(timestamp) <= 12.9 ~ "1",
           T ~ "2"
         )) %>%
  group_by(day, burn, logger) %>%
  summarize(MaxCaseTemp = max(CaseTemp)) %>%
  ungroup %>% 
  arrange(desc(MaxCaseTemp))
  
