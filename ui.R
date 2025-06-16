library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinybusy)
library(flowCore)

ui <- dashboardPage(
  skin = "black",
  dashboardHeader(title = "FCS Converter"),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    add_busy_spinner(spin = "fading-circle"),
    includeCSS("www/styles.css"),
    useShinyjs(),
    
    fluidRow(
      column(12,
             box(
               id = "info_box",
               title = "About this tool",
               status = "primary",
               solidHeader = TRUE,
               collapsible = TRUE,
               collapsed = TRUE,
               "This tool is designed to convert FCS files from the ThermoFisher Attune NxT format to a format compatible with BD FACSDiva software.
                Users can upload files from their local machine. Once uploaded, files are processed and converted, and the user
                is then able to download the converted files. A log of actions taken during a session is also available for users to view."
             ),
             box( 
               id = "log_box",
               title = "Log Messages",
               status = "primary",
               solidHeader = TRUE,
               collapsible = TRUE,
               collapsed = TRUE,
               verbatimTextOutput("log")
             )
      )
    ),
    
    fluidRow(
      column(
        width = 12,
        box(
          title = "Upload FCS Files",
          fileInput("file", "Choose local files",
                    multiple = TRUE,
                    accept = c("FCS files" = ".fcs")),
          hidden(actionButton("submit", "Convert", class = "shine"))
        )
      )
    ),
    
    fluidRow(
      hidden(
        div(
          id = "download_box",
          box(
            title = "Download FCS Files",
            downloadButton("download", "Download Converted Files", class = "shine")
          )
        )
      )
    )
  )
)
