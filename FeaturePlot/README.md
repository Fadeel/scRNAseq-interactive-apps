# Interactive Seurat FeaturePlot to visualize gene expression level
This R Shiny application can be used to plot and download the expression of a feature (e.g. genes) in reduced dimesions space like UMAP, PCA, ...

## Running the application
1. Download the feature_plot_shiny.R and add the folder into PATH
2. In terminal, run with seurat object rds file
```bash
>> feature_plot_shiny.R <path/to/seurat.rds>
```

- In the first run, it will automatically check and install required packges.
- After running, it may take some time to load the seurat object file depending on the file size.
- Once loaded, assay and dimension reduction menu will be filled default items.
- Then, enter gene symbol(s) to draw feature plots.
- Adjust asthetic paramters such as pt.size, min/max colors.
- Download the plot
