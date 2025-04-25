# Function to create the basic HTML page, filling it with the page content
# Places constant elements like header (slider, navbar) and footer
create_page_layout <- function(title, page_content) {
  #### 1 Navbar links ####

  # Determine active class based on the title or a passed argument if needed
  nav_items <- list(
    list(
      href = "index.html",
      text = "Home",
      class = if (title == "Home") "active" else ""
    ),
    list(
      href = "about.html",
      text = "About",
      class = if (title == "About") "active" else ""
    ),
    list(
      href = "contact.html",
      text = "Contact",
      class = if (title == "Contact") "active" else ""
    )
    # Add more pages here
  )

  #### 2 Image slider ####

  # Note: you must place images manually in www/images folder

  slider_images <- c(
    "images/slider1.png",
    "images/slider2.png",
    "images/slider3.png"
    # Add more images here
  )

  #### 3 Assemble page ####

  site_header <- create_header(
    slider_image_paths = slider_images,
    nav_items = nav_items
  )

  site_footer <- create_footer()

  tags$html(
    lang = "en",

    # Head
    tags$head(
      tags$meta(charset = "utf-8"),
      tags$meta(
        name = "viewport",
        content = "width=device-width, initial-scale=1"
      ),
      tags$title(paste(title, "- My Static Site")),

      # CSS files managed by packer (paths relative to final HTML)
      tags$link(rel = "stylesheet", href = "libs/bootstrap/bootstrap.min.css"),
      tags$link(rel = "stylesheet", href = "libs/slick-carousel/slick.css"),
      tags$link(
        rel = "stylesheet",
        href = "libs/slick-carousel/slick-theme.css"
      ),

      # Custom CSS (path relative to final HTML)
      tags$link(rel = "stylesheet", href = "css/styles.css")
    ),

    # Body (header, page content, footer)
    tags$body(
      class = "d-flex flex-column min-vh-100", # Make body flex to push footer down

      site_header,

      # Main content area for the specific page
      tags$main(
        class = "container my-4", # Add some padding
        role = "main",
        page_content # The specific content for this page
      ),

      site_footer,

      # JS Files managed by packer (paths relative to final HTML)
      # jQuery (needed by Slick, place before Slick)
      tags$script(src = "libs/jquery/jquery.min.js"),
      # Bootstrap JS
      tags$script(src = "libs/bootstrap/bootstrap.bundle.min.js"),
      # Slick Carousel JS
      tags$script(src = "libs/slick-carousel/slick.min.js"),

      # Custom JS (path relative to final HTML)
      tags$script(src = "js/scripts.js")
    )
  )
}

# Function to create the image slider HTML (requires Slick Carousel JS/CSS)
create_slider <- function(image_paths) {
  slides <- lapply(image_paths, function(img_path) {
    tags$div(tags$img(
      src = img_path,
      class = "d-block w-100",
      alt = "Slider Image"
    ))
  })
  tags$div(class = "image-slider", slides) # Add a class for JS targeting
}

# Function to create the Bootstrap Navbar
create_navbar <- function(nav_items) {
  # nav_items should be a list of lists, e.g., list(list(href="index.html", text="Home"), ...)
  nav_links <- lapply(nav_items, function(item) {
    tags$li(
      class = "nav-item",
      tags$a(class = paste("nav-link", item$class), href = item$href, item$text)
    )
  })

  tags$nav(
    class = "navbar navbar-expand-lg navbar-dark bg-dark",
    tags$div(
      class = "container-fluid",
      tags$a(class = "navbar-brand", href = "index.html", "My Site"),
      tags$button(
        class = "navbar-toggler",
        type = "button",
        `data-bs-toggle` = "collapse",
        `data-bs-target` = "#navbarNav",
        `aria-controls` = "navbarNav",
        `aria-expanded` = "false",
        `aria-label` = "Toggle navigation",
        tags$span(class = "navbar-toggler-icon")
      ),
      tags$div(
        class = "collapse navbar-collapse",
        id = "navbarNav",
        tags$ul(class = "navbar-nav ms-auto", nav_links) # ms-auto pushes items to the right
      )
    )
  )
}

# Function to create the Header (Slider + Navbar)
create_header <- function(slider_image_paths, nav_items) {
  tags$header(
    create_slider(slider_image_paths),
    create_navbar(nav_items)
  )
}

# Function to create the Footer
create_footer <- function() {
  tags$footer(
    class = "bg-light text-center text-lg-start mt-auto", # mt-auto pushes footer down
    tags$div(
      class = "text-center p-3",
      style = "background-color: rgba(0, 0, 0, 0.05);",
      paste("©", format(Sys.Date(), "%Y"), "My Static Site - Built with R")
    )
  )
}
