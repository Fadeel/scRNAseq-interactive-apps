#!/usr/bin/env Rscript


# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#

suppressPackageStartupMessages(library('optparse', quiet=TRUE))



# command line option handling
option_list <- list(
)
parser <- OptionParser(usage = "%prog [options] <seurat R object file>",
			description="Start Shiny App that draw Seurat feature plot interactively
Input:
	- Seurat object rds file",
			option_list=option_list)
arguments <- parse_args(parser, positional_arguments = TRUE)
if(length(arguments$args) < 1){
	print_help(parser)
	stop("Error: Requires a data file")
} else {
	src <- arguments$args[1]
}

if(!file.exists(src)) stop( sprintf("% does not exist.", src) )



list.of.packages <- c("ggplot2", "Seurat","shinythemes","shiny")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
require(shiny)




require(Seurat)
require(shinythemes)
require(shiny)
require(ggplot2)


# app  UI -----------------------------------------------------------------
ui <- fluidPage( theme = shinytheme("cosmo") , 
                 
                 titlePanel("" , ),
                 
                   sidebarPanel(
                     selectizeInput("gene",
                                 "Select gene symbols:",
                                 choices = NULL,
                                 multiple = T
                     ),
                     
                     selectizeInput("assay",
                                    "Select assay (e.g. RNA,integrated,...):",
                                    choices = NULL,
                                    multiple = F
                     ),
                     
                     selectizeInput("reduction",
                                    "Select dimesion reduction (e.g. UMAP,PCA)",
                                    choices = NULL,
                                    multiple = F
                     ),
                     
                     numericInput("max.cutoff" , "Set max expression value (in terms of percentile)" , 
                                  value = 95 , min = 0 , max = 100, step = 1 ),
                     numericInput("min.cutoff" , "Set min expression value (in terms of percentile)" , 
                                  value = 5 , min = 0 , max = 100, step = 1 ),
                     numericInput("pt.size" , "Point size" , 
                                  value =  0.5 , min = 0 ,max = 2 , step = 0.1) ,
                     textInput("min.col" , "Color for minimum value", value = "lightgrey") ,
                     textInput("max.col" , "Color for maximum value", value = "blue") ,
                     
                     numericInput("ncols" , "Number of columns (in case of multiple plots)" , 
                                  value = 1 , min = 1 , max = 10 , step = 1) ,
                     #selectInput("split.by", "Split By", c("None","group")),
                     numericInput("width" , "Width of the saved plot (inch)" , 
                                  7 , min = 1 , 50 , step = 1),
                     numericInput("height" , "Height of the saved plot (inch)" , 
                                  7 , min = 1 , 50 , step = 1),
                     
                     downloadButton("download")
                   ),
                   
                   mainPanel(
                    tabsetPanel(
                      tabPanel( "Feature Plot", 
                                plotOutput("featureplot", height = "600px"),

                      )
                    )
                  )
)


server <- function(input, output,session) {
  #src="seurat.rds"
  write(sprintf("Loading %s", src), stderr())
  seurat_object <- readRDS(src)
  write(sprintf("Done", src), stderr())
  updateSelectizeInput(session, 'assay', choices = Assays(seurat_object), selected="RNA", server = TRUE)
  updateSelectizeInput(session, 'reduction', choices = Reductions(seurat_object), selected="umap", server = TRUE)

## Currently, default gene symbol upon start up the app is not working.
#  updateSelectizeInput(session, 'gene', choices = rownames(seurat_object@assays$RNA), selected = intersect(c("Gapdh","GAPDH"), rownames(seurat_object@assays$RNA)), server = TRUE)
  

## Commented out because it works without this block
#  features = eventReactive(input$assay,
#    {
#      rownames(seurat_object@assays[[input$assay]])
#    }
#  )
  
## What's the order of this observeEvent and the following plot <- eventReactive?
  observeEvent(input$assay,
    {
      gene.current = input$gene
      #gene.all = features()
      gene.all = rownames(seurat_object@assays[[input$assay]])
      gene.selected = intersect(gene.current, gene.all)
      #updateSelectizeInput(session, 'gene', choices = features(), server = TRUE)
      updateSelectizeInput(session, 'gene', choices = gene.all, selected = gene.selected, server = TRUE)
    }
  )
  
  plot <- eventReactive({
    input$assay
    input$reduction
    input$gene
    input$pt.size
    input$min.col
    input$max.col
    input$ncols
    input$max.cutoff
    input$min.cutoff
  }  , { 
    DefaultAssay(seurat_object) = input$assay

    if(length(input$gene)>0) FeaturePlot(seurat_object ,features = input$gene, 
                cols = c(input$min.col, input$max.col),
                max.cutoff =paste0("q", input$max.cutoff),
                reduction = input$reduction,
                min.cutoff = paste0("q",input$min.cutoff),
                pt.size = input$pt.size,
                ncol = input$ncols )
  })
  
  output$featureplot <- renderPlot(
    plot()
  ) 
  
  
  filename <- reactive({ paste0(paste0(input$gene, collapse = "_"),".png") })
  
  output$download <- downloadHandler(
    filename = function() {
      filename()
    },
    content = function(file) {
      ggsave( filename = file, plot(), device = "png", units = "in", width = input$width, height = input$height)
      
    }
  )
  
}


app = shinyApp(ui = ui, server = server)





# Run the application 
write("Starting shiny app", stderr())
runApp(app, launch.browser=TRUE)


