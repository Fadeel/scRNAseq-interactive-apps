# Interactive version of Seurat's FeaturePlot
This R Shiny application can be used to plot and download the expression of a feature (e.g. genes) in reduced dimesions space like UMAP, PCA, ...
## Running the application
There are two ways to run this tool,
### using command line interface
 1. Download "feature_plot_app.R" file.
 2. move your Seurat object file (must be named "seurat.rds") to the same directory with "feature_plot_app.R" file.
 3. In command-line interface, execute the following commands,
  ```
 $ R   # open R 
 
 # the following commands are executed within R
 > if(!"shiny" %in% installed.packages()[,"Package"]) install.packages("shiny")   
 >  shiny::runApp("~/path/to/feature_plot_app.R")   # Note: replace /path/to/ with actual path of the file
 
 ```
 
### using RStudio
 1. Download "feature_plot_app.R" file.
 2. Open `feature_plot_app.R` in RStudio.
 4.  You can run the application by clicking the 'Run App' button
