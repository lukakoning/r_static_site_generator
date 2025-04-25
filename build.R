# build.R
# These functions are responsible for building the static site
# Loads page functions from R folder, builds each page,
#   and copies it to the output directory together with assets

build_site <- function(
  assets = get_assets(),
  output_dir = "www",
  libs_dir = file.path(output_dir, "libs"),
  node_modules_dir = "node_modules",
  also_source_main_script = TRUE,
  page_funcs = load_page_functions()
) {
  #### 1 Directories ####

  cli::cli_alert_info("Creating output directories...")

  # Ensure directories exist
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

  # Clean and recreate libs directory for a fresh build
  if (dir.exists(libs_dir)) unlink(libs_dir, recursive = TRUE)
  dir.create(libs_dir, recursive = TRUE)

  # Remove all pre-existing .html files which are not in folders css, images, js, or libs
  html_to_remove <- list.files(
    output_dir,
    pattern = "\\.html$",
    full.names = TRUE,
    recursive = TRUE
  )
  html_to_remove <- html_to_remove[
    !grepl("/(css|images|js|libs)/", html_to_remove)
  ]
  file.remove(html_to_remove)

  #### 2 Copy assets ####

  cli::cli_alert_info(paste0(
    "Copying required files from ",
    node_modules_dir,
    " to ",
    libs_dir,
    "..."
  ))

  copy_results <- sapply(assets, function(asset) {
    copy_asset(
      asset$src,
      file.path(asset$dest),
      asset$dir,
      node_modules_dir,
      libs_dir
    )
  })

  # Check if all copies were successful
  if (!all(copy_results)) {
    stop("One or more assets failed to copy. Check warnings")
  }

  #### 3 Build each page ####

  cli::cli_alert_info("Building pages...")

  if (length(page_funcs) == 0) {
    stop(
      "No page functions found. Please define page functions in the global environment"
    )
  }

  for (page_func in page_funcs) {
    title <- attr(page_func, "title")
    filename <- attr(page_func, "filename")

    if (is.null(title) || is.null(filename)) {
      warning(
        "Skipping page_function with missing title or filename attribute."
      )
      next
    }

    cat("Building page:", filename, "...\n")
    page_body_content <- page_func()
    full_page_html <- create_page_layout(
      title = title,
      page_content = page_body_content
    )

    output_path <- file.path(output_dir, filename)
    save_html(html = full_page_html, file = output_path)
    cat("Saved page to:", output_path, "\n")
  }

  cli::cli_alert_success("Done building site!")
}

# Helper function to copy files/dirs and create destination subdirs
copy_asset <- function(
  source_path,
  dest_subdir,
  is_dir = FALSE,
  node_modules_dir = "node_modules",
  libs_dir = "www/libs"
) {
  full_source_path <- file.path(node_modules_dir, source_path)
  full_dest_path <- file.path(libs_dir, dest_subdir)
  parent_dest_dir <- dirname(full_dest_path)

  # Create destination parent directory if it doesn't exist
  if (!dir.exists(parent_dest_dir)) {
    dir.create(parent_dest_dir, recursive = TRUE)
    cat("  Created directory:", parent_dest_dir, "\n")
  }

  # Check if source exists
  if (!file.exists(full_source_path) && !dir.exists(full_source_path)) {
    warning("  Source not found: ", full_source_path)
    return(invisible(FALSE)) # Exit function if source doesn't exist
  }

  # Perform the copy
  success <- FALSE
  if (is_dir) {
    # For directories, copy the source dir INTO the parent destination directory
    # Ensure the target directory itself doesn't already exist from a previous failed copy attempt inside parent
    if (dir.exists(full_dest_path)) unlink(full_dest_path, recursive = TRUE)
    success <- file.copy(
      full_source_path,
      parent_dest_dir,
      recursive = TRUE,
      overwrite = TRUE
    )
    # file.copy recursive copies the directory *into* parent_dest_dir,
    # effectively creating full_dest_path if successful.
    # We check if the target directory now exists.
    success <- dir.exists(full_dest_path)
  } else {
    # For files, copy the source file TO the full destination path
    success <- file.copy(
      full_source_path,
      full_dest_path,
      recursive = FALSE,
      overwrite = TRUE
    )
  }

  # Report outcome
  if (success) {
    # For directories, report the intended final path
    cat("  Copied:", source_path, "to", full_dest_path, "\n")
  } else {
    warning("  Failed to copy: ", source_path, " to ", full_dest_path)
  }
  return(invisible(success))
}

# Helper function to load page functions
load_page_functions <- function() {
  # Source files into the global environment
  source_files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
  for (file in source_files) {
    source(file, local = globalenv()) # <--- IMPORTANT
  }

  # Find all page_* functions in the global environment
  page_functions <- Filter(
    is.function,
    mget(ls(pattern = "^page_", envir = globalenv()), envir = globalenv())
  )

  if (length(page_functions) == 0) {
    stop(
      "No page functions found. Please define page functions in the global environment"
    )
  }

  return(page_functions)
}
