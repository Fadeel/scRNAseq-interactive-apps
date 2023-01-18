# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#

list.of.packages <- c("ggplot2", "Seurat","shinythemes","shiny")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

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
                     numericInput("ncols" , "Number of columns (in case of multiple plots)" , 
                                  value = 1 , min = 1 , max = 10 , step = 1) ,
                     #selectInput("split.by", "Split By", c("None","group")),
                     numericInput("width" , "Width of the saved plot" , 
                                  7 , min = 1 , 50 , step = 1),
                     numericInput("height" , "Height of the saved plot" , 
                                  7 , min = 1 , 50 , step = 1),
                     
                     downloadButton("download")
                   ),
                   
                   mainPanel(
                    tabsetPanel(
                      tabPanel( "UMAP plot", 
                                plotOutput("umap", height = "600px"),

                      )
                    )
                  )
)


server <- function(input, output,session) {
  seurat_object <- readRDS("seurat.rds")
  updateSelectizeInput(session, 'assay', choices = Assays(seurat_object), server = TRUE)
  updateSelectizeInput(session, 'reduction', choices = Reductions(seurat_object), server = TRUE)
  
  features = eventReactive(input$assay, {
    
    rownames(seurat_object@assays[[input$assay]])
  })
  
  observeEvent(input$assay,{
    updateSelectizeInput(session, 'gene', choices = features(), server = TRUE)
    
  })
  
  plot <- eventReactive({
    input$assay
    input$reduction
    input$gene
    input$pt.size
    input$ncols
    input$max.cutoff
    input$min.cutoff
  }  , { 
    DefaultAssay(seurat_object) = input$assay
    
    FeaturePlot(seurat_object ,features = input$gene, max.cutoff =paste0("q", input$max.cutoff), reduction = input$reduction,
                min.cutoff = paste0("q",input$min.cutoff), pt.size = input$pt.size, ncol = input$ncols )
  })
  
  output$umap <- renderPlot(
    plot()
  ) 
  
  
  filename <- reactive({ paste0(paste0(input$gene,collapse = "_"),".png") })
  
  output$download <- downloadHandler(
    filename = function() {
      filename()
    },
    content = function(file) {
      ggsave( filename = file, plot(), device = "png", units = "in", width = input$width, height = input$height)
      
    }
  )
  
}


# Run the application 
shinyApp(ui = ui, server = server)


