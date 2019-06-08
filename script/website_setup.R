  pacman::p_load(blogdown)

  setwd("C:/Users/Devan.McGranahan/GoogleDrive/FireScienceDIY/website")
  new_site() 
  install_theme("kishaningithub/hugo-creative-portfolio-theme", theme_example = TRUE, update_config = TRUE)
  
  
  blogdown::new_post("Post Title", ext = '.Rmd')