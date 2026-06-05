source("functions.R")

server <- function(input, output, session) {
  options(shiny.maxRequestSize = 10000000000 * 1024^2)
  
  # Initialize a reactive value to store the log messages
  log_messages <- reactiveVal(list())
  # Observe if files are uploaded
  observeEvent(input$file, {
    if (!is.null(input$file)) {
      shinyjs::show("submit")
      # Add a message to the log
      log_messages(c(log_messages(), paste0(Sys.time(), ": Files uploaded")))
    } else {
      shinyjs::hide("submit")
    }
  }, ignoreNULL = FALSE)
  
  # Observe the submit button
  observeEvent(input$submit, {
    if (is.null(input$file)) {
      shinyjs::alert("Please choose files")
    } else {
      show_modal_spinner()
      # Use the uploaded files
      input_files <- input$file$datapath
      input_files_names <- input$file$name
      output_files <- list() # Initialize an empty list to store output file paths
      
      for (i in seq_along(input_files)) {
        input_file <- input_files[i]
        input_file_name <- input_files_names[i]
        
        input_dir <- dirname(input_file)
        file_base <- tools::file_path_sans_ext(input_file_name)
        file_ext <- tools::file_ext(input_file_name)
        
        # Pattern: an underscore followed by 1 uppercase letter and 1+ digits at the end
        pattern <- "_([A-Z])([0-9]+)$"
        
        matches <- regexec(pattern, file_base)
        match_data <- regmatches(file_base, matches)
        
        if (length(match_data[[1]]) > 0) {
          # Extract parts
          letter <- match_data[[1]][2]
          number_str <- match_data[[1]][3]
          
          # Safe conversion to integer
          number <- suppressWarnings(as.integer(number_str))
          
          if (!is.na(number)) {
            # Pad number if needed
            number_padded <- ifelse(number < 10, sprintf("0%d", number), as.character(number))
            
            # Remove the matched suffix from original base
            file_base_clean <- sub(pattern, "", file_base)
            
            # Build the new file name
            new_name <- paste0(letter, number_padded, "_", "modified_", file_base_clean, ".", file_ext)
          } else {
            # If conversion fails, fallback
            new_name <- paste0("modified_", input_file_name)
          }
        } else {
          # If no match, fallback
          new_name <- paste0("modified_", input_file_name)
        }
        
        output_file <- file.path(input_dir, new_name)
        output_files <- c(output_files, output_file)
        
        log_messages(c(log_messages(), paste0(Sys.time(), ": Converting file ", input_file_name)))
        convert_to_BD_FacsDiva(input_file, output_file)
      }
      
      
      shinyjs::runjs("$('#submit').addClass('stop');")  # Add the 'stop' class to stop the animation
      
      # Create a zip file from the output files
      zip_file <- paste0(dirname(unlist(output_files[1])),"/zip.zip") # Replace with your desired path
      zip(zip_file, unlist(output_files), flags = '-r9Xj')
      
      # Provide the zip file for download
      output$download <- downloadHandler(
        filename = function() {
          basename(zip_file)
        },
        content = function(file) {
          file.copy(zip_file, file)
        }
      )
      remove_modal_spinner()
      notify_success("Files converted successfully!")
      shinyjs::show("download_box") # Show the download box
      # Add a message to the log
      log_messages(c(log_messages(), paste0(Sys.time(), ": Files converted successfully!")))
    }
  })
  
  # Observe the download button
  observeEvent(input$download_button, {
    shinyjs::runjs("$('#download_button').addClass('stop');")  # Add the 'stop' class to stop the animation
    shinyjs::runjs("$('#download')[0].click();")  # Programmatically click the actual download link
  })
  
  # Render the log messages as text
  output$log <- renderText({
    paste(unlist(log_messages()), collapse = "\n")
  })
  
}
