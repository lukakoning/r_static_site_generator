# dependencies.R
# Defines the NPM dependencies & assets to copy from node_modules to
#   the libs directory of the static site

# Define and install npm dependencies into ./node_modules/
# This will create/update package.json and download packages
install_npm_dependencies <- function(scope = c("dev", "prod")) {
  # Check if packer is installed
  if (!requireNamespace("packer", quietly = TRUE)) {
    stop(
      "The 'packer' package is required but not installed. Please install it first."
    )
  }

  # Check if node_modules directory exists
  if (!dir.exists("node_modules")) {
    dir.create("node_modules")
  }

  # Install npm dependencies
  scope <- match.arg(scope)
  packer::npm_install(
    "jquery@3.7.1",
    "bootstrap@5.3.3",
    # "@popperjs/core@2.11.8",
    "slick-carousel@1.8.1",
    scope = scope
  )
}

# Get assets to copy from node_modules to libs
get_assets <- function() {
  list(
    # jQuery (Seems correct already)
    list(
      src = "jquery/dist/jquery.min.js",
      dest = "jquery/jquery.min.js",
      dir = FALSE
    ),

    # Bootstrap (includes Popper)
    list(
      src = "bootstrap/dist/css/bootstrap.min.css",
      dest = "bootstrap/bootstrap.min.css",
      dir = FALSE
    ),
    list(
      src = "bootstrap/dist/js/bootstrap.bundle.min.js",
      dest = "bootstrap/bootstrap.bundle.min.js",
      dir = FALSE
    ),

    # Slick Carousel
    list(
      src = "slick-carousel/slick/slick.min.js",
      dest = "slick-carousel/slick.min.js",
      dir = FALSE
    ),
    list(
      src = "slick-carousel/slick/slick.css",
      dest = "slick-carousel/slick.css",
      dir = FALSE
    ),
    list(
      src = "slick-carousel/slick/slick-theme.css",
      dest = "slick-carousel/slick-theme.css",
      dir = FALSE
    ),
    list(
      src = "slick-carousel/slick/ajax-loader.gif",
      dest = "slick-carousel/ajax-loader.gif",
      dir = FALSE
    ),
    list(
      # Fonts need to be relative to the CSS.
      # If slick.css and slick-theme.css are now in /libs/slick-carousel/,
      # they will look for fonts in ./fonts/ relative to themselves.
      src = "slick-carousel/slick/fonts",
      dest = "slick-carousel/fonts",
      dir = TRUE
    )
  )
}
