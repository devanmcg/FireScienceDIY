

tc_data <- GetHeatingCurves(
                FilePath = 'S:/DevanMcG/FireBehavior/DroughtPlots/',
                type = 'FF',
                MinTemp = '40',
                ExcludeColumns = c("logger", "timestamp")
                  )

GetHeatingCurves(   
                FilePath = 'S:/DevanMcG/FireBehavior/DroughtPlots/', 
                type = 'FF', 
                MinTemp = '40', 
                ExcludeColumns = c("logger", "timestamp") )


HeatingCurves %>%
    ggplot() + theme_bw() + 
    geom_line(aes(x = obs, 
                  y = degC, 
                  color = TC, 
                  group = TC)) +
    facet_wrap(event ~ logger, scales = "free_x")
