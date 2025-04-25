# preview.R
# Responsible for serving a preview of the static site and
#   watching for changes in the source files
# Will automatically rebuild the site when changes are detected
# Inserts JavaScript to force a page refresh in your browser
#   when changes are detected

serve_static_site <- function(
    port = 8081,
    dir = "www",
    watch = TRUE,
    watch_dir = "R",
    watch_dependencies_file = "dependencies.R"
) {
  if (!dir.exists(dir)) {
    stop(paste("Output directory not found:", dir))
  }
  if (watch && !dir.exists(watch_dir)) {
    stop(paste("Watch directory not found:", watch_dir))
  }

  last_mtime <- NULL

  update_timestamp <- function() {
    write(as.character(Sys.time()), file.path(dir, "timestamp.txt"))
  }

  # File watcher function
  check_for_changes <- function() {
    current_files <- fs::dir_info(watch_dir, recurse = TRUE)
    current_mtime <- current_files$modification_time
    names(current_mtime) <- current_files$path

    # Handle dependencies file separately
    if (file.exists(watch_dependencies_file)) {
      dep_mtime <- fs::file_info(watch_dependencies_file)$modification_time
      names(dep_mtime) <- watch_dependencies_file
      current_mtime <- c(current_mtime, dep_mtime)
    }

    if (is.null(last_mtime)) {
      last_mtime <<- current_mtime
    } else {
      common_files <- intersect(names(last_mtime), names(current_mtime))
      changed <- current_mtime[common_files] != last_mtime[common_files]

      if (any(changed, na.rm = TRUE)) {
        changed_files <- names(changed)[changed]

        if (watch_dependencies_file %in% changed_files) {
          cli::cli_alert_info(
            paste0(
              "`", watch_dependencies_file,
              "` changed. Re-installing dependencies and rebuilding + refreshing site..."
            )
          )
          try(source(watch_dependencies_file), silent = TRUE)
          try(install_npm_dependencies(), silent = TRUE)
          try(build_site(), silent = TRUE)
          update_timestamp()
        } else if (any(grepl(watch_dir, changed_files))) {
          cli::cli_alert_info("Changes detected in watch directory. Rebuilding + refreshing site...")
          try(build_site(), silent = TRUE)
          update_timestamp()
        }

        last_mtime <<- current_mtime
      }
    }

    later::later(check_for_changes, delay = 1)
  }

  # HTTP request handler
  request_handler <- function(req) {
    path <- req$PATH_INFO
    if (grepl("^/$", path)) {
      path <- "/index.html"
    }
    full_path <- file.path(dir, substring(path, 2))

    if (file.exists(full_path)) {
      content_type <- mime::guess_type(full_path)

      if (grepl("\\.html?$", full_path)) {
        content <- readChar(full_path, file.info(full_path)$size, useBytes = TRUE)
        reload_script <- "
          <script>
          setInterval(() => {
            fetch('/timestamp.txt')
              .then(r => r.text())
              .then(ts => {
                if (window.lastTimestamp && window.lastTimestamp !== ts) {
                  location.reload();
                }
                window.lastTimestamp = ts;
              });
          }, 2000);
          </script>
        "
        # Inject before </body> or append to end
        if (grepl("</body>", content, ignore.case = TRUE)) {
          content <- sub("</body>", paste0(reload_script, "\n</body>"), content, ignore.case = TRUE)
        } else {
          content <- paste0(content, reload_script)
        }

        return(list(
          status = 200L,
          headers = list('Content-Type' = content_type),
          body = charToRaw(content)
        ))
      } else {
        return(list(
          status = 200L,
          headers = list('Content-Type' = content_type),
          body = readBin(full_path, "raw", file.info(full_path)$size)
        ))
      }
    } else {
      list(
        status = 404L,
        headers = list('Content-Type' = 'text/plain'),
        body = "File not found"
      )
    }
  }

  httpuv::stopAllServers()
  server <- httpuv::startServer("0.0.0.0", port, request_handler)

  cli::cli_alert_success(paste(
    "Serving static site from",
    dir,
    "on http://localhost:",
    port
  ))
  browseURL(paste0("http://localhost:", port))

  if (watch) {
    later::later(check_for_changes, delay = 1)
    cli::cli_alert_info(paste0(
      "Watching for changes in '",
      watch_dependencies_file,
      "' and '",
      watch_dir,
      "'; will automatically rebuild site..."
    ))
  } else {
    cli::cli_alert_info(paste0(
      "Not watching for changes; rebuild site manually with",
      " 'install_npm_dependencies()' and 'build_site()' (refresh page after)"
    ))
  }

  repeat {
    httpuv::service()
    later::run_now(0.001)
    Sys.sleep(0.001)
  }

  on.exit(
    {
      httpuv::stopServer(server)
      cli::cli_alert_info("Server stopped")
    },
    add = TRUE
  )
}
