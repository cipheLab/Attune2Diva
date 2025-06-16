# Attune2Diva

**Attune2Diva** is a specialized tool designed to streamline the conversion of FCS files from the **ThermoFisher Attune NxT format** into a format compatible with **BD FACSDiva software**.

## ✨ Features

- **File Upload**: Easily upload FCS files from your local machine.
- **Automated Conversion**: Files are automatically processed and converted upon upload.
- **Download Converted Files**: Download the converted files directly.
- **Activity Log**: View a detailed log of all steps performed during the session.

## 🚀 Getting Started

### 1. Install R

Download and install R from:  
👉 https://cran.r-project.org/

### 2. Install Required R Packages

Open R or RStudio and run the following commands to install required packages:

```r
install.packages(c("shiny", "shinydashboard", "shinyjs", "shinybusy"))

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("flowCore")
```
