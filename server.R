source("functions.R")
server <- function(input, output, session) {
  options(shiny.maxRequestSize = 10000 * 1024^2)  # 10 GB
  
  log_messages <- reactiveVal(character(0))
  
  observeEvent(input$file, {
    if (!is.null(input$file)) {
      shinyjs::show("submit")
      log_messages(c(log_messages(), paste0(Sys.time(), ": Files uploaded")))
    } else {
      shinyjs::hide("submit")
    }
  }, ignoreNULL = FALSE)
  
  observeEvent(input$submit, {
    if (is.null(input$file)) {
      shinyjs::alert("Please choose files")
      return()
    }
    
    show_modal_spinner()
    input_files <- input$file$datapath
    input_file_names <- input$file$name
    output_files <- character(0)
    
    for (i in seq_along(input_files)) {
      input_file <- input_files[i]
      input_name <- input_file_names[i]
      output_file <- file.path(dirname(input_file), paste0("modified_", input_name))
      output_files <- c(output_files, output_file)
      
      log_messages(c(log_messages(), paste0(Sys.time(), ": Converting file ", input_name)))
      convert_to_BD_FacsDiva(input_file, output_file)
    }
    
    shinyjs::runjs("$('#submit').addClass('stop');")
    
    if (length(output_files) > 0) {
      zip_file <- file.path(dirname(output_files[1]), "zip.zip")
      zip(zip_file, output_files, flags = "-r9Xj")
      
      output$download <- downloadHandler(
        filename = function() {
          # Show modal before download starts
          showModal(modalDialog("Preparing your download...", footer = NULL))
          basename(zip_file)
        },
        content = function(file) {
          file.copy(zip_file, file)
          # Remove modal after copy
          removeModal()
        }
      )
      
      remove_modal_spinner()
      notify_success("Files converted successfully!")
      shinyjs::show("download_box")
      log_messages(c(log_messages(), paste0(Sys.time(), ": Files converted successfully!")))
    } else {
      remove_modal_spinner()
      shinyjs::alert("No output files generated.")
    }
  })
  
  output$log <- renderText({
    paste(log_messages(), collapse = "\n")
  })
}
