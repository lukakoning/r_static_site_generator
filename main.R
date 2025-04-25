#### 1 Libraries ####

# Run 'renv::restore()' to install required R packages
library(htmltools)

#### 2 Functions ####

# Load functions to build & preview the site
source("dependencies.R")
source("build.R")
source("preview.R")

#### 3 Build site ####

install_npm_dependencies()
build_site()

#### 4 Run site preview ####

# Will serve a local site preview,
#   while listening for changes in 'dependencies.R' and 'R/',
#   rebuilding the site when changes are detected
# JavaScript code is injected to force a page refresh in your browser;
#   this way, you can see changes automatically

serve_static_site()

#### 5 Deploy to production ####

# To deploy the site, run:
#   install_npm_dependencies("prod")
#   build_site()
# Then upload the contents of the 'www' folder to your web server
