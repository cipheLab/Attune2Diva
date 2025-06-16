library(flowCore)

convert_to_BD_FacsDiva <- function(inputFile, outputFile) {
  # Read FCS file
  fcs_data <- read.FCS(inputFile, emptyValue = FALSE)
  
  # Modify SRC description
  fcs_data@description$'SRC' <- fcs_data@description$'ORIGINALGUID'
  
  # Find indices of names matching "max" and "P\d+R" in the description
  indices_max <- grep("max", names(fcs_data@description))
  indices_PnR <- grep("P\\d+R$", names(fcs_data@description))
  
  # Compute the maximum value among these parameters
  max_value_max <- 262144
  max_value_PnR <- 262144
  
  # Set these parameters to their respective maximum value
  for (index in indices_max){
    fcs_data@description[[index]] <- max_value_max
  }
  for (index in indices_PnR){
    fcs_data@description[[index]] <- max_value_PnR
  }
  
  # Extract the expression matrix
  expr_matrix <- exprs(fcs_data)
  
  # Get parameter data, including max ranges
  params <- parameters(fcs_data)
  
  # Extract maxRanges using varLabels
  max_ranges <- as.numeric(params$`maxRange`)
  
  # Identify columns without "-W" or "time" in their names for scaling
  valid_cols <- !grepl("Time", params$name, ignore.case = TRUE)
  
  # Extract maxRanges for valid columns
  valid_max_ranges <- max_ranges[valid_cols]
  
  # Compute the scaling factors by dividing the valid maxRange by 262143
  scaling_factors <- valid_max_ranges / 262143
  
  # Scale the expression matrix using the valid columns
  expr_matrix[, valid_cols] <- sweep(expr_matrix[, valid_cols], 2, scaling_factors, `/`)
  
  # Replace the original expression matrix with the scaled matrix
  exprs(fcs_data) <- expr_matrix
  
  # Update the maxRange to 262143 for ALL parameters
  params$`maxRange`[] <- 262143
  params$`range`[] <- 262143
  parameters(fcs_data) <- params
  
  # Write the result to a new FCS file
  print("done in function")


  
  write.FCS(fcs_data, outputFile)
  
  
  
}
