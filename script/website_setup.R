  pacman::p_load(blogdown)

  setwd("C:/Users/Devan.McGranahan/GoogleDrive/FireScienceDIY/")
  new_site() 
  install_theme("kishaningithub/hugo-creative-portfolio-theme", theme_example = TRUE, update_config = TRUE)
  
  
  blogdown::new_post("Welcome to DIY Fire Science", ext = '.Rmd')
  