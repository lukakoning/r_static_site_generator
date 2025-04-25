# Static site generator in R

This is a simple static site builder written in R. 
Contains a live preview server to preview the site while building.

See 'main.R' for the basic process and explanation.
'dependencies.R' defines the NPM dependencies and assets to copy 
to the static site. 'build.R' contains functions to build the site.
'preview.R' launches a live preview server to view the site while building;
it watches for changes in dependencies.R' and in the 'R/' folder. When
a change is detected, it rebuilds the site and refreshes the browser.

Pages are defined in the R folder. In 'R/components.R', there are
functions to create common components for each page (header, footer, etc.).
'R/pages.R' contains functions which contain the specific page content.
