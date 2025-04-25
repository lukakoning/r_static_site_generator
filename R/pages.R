# pages.R
# Defines content of individual pages, which are wrapped in a common layout
#   as defined in components.R

page_home_content <- function() {
  tagList(
    tags$h1("Welcome to the Home Page!!!!"),
    tags$p("This is the main page of our static website built with R."),
    tags$p(
      "The slider and navbar above are common elements defined in the layout."
    )
  )
}
attr(page_home_content, "title") <- "Home"
attr(page_home_content, "filename") <- "index.html"

page_about_content <- function() {
  tagList(
    tags$h1("About Us"),
    tags$p("Information about the website or organization goes here!!"),
    tags$p("We used R, htmltools, and packer to build this.....")
  )
}
attr(page_about_content, "title") <- "About"
attr(page_about_content, "filename") <- "about.html"

page_contact_content <- function() {
  tagList(
    tags$h1("Contact Us"),
    tags$p("Contact details or a contact form could go here.")
  )
}
attr(page_contact_content, "title") <- "Contact"
attr(page_contact_content, "filename") <- "contact.html"
