library(knitr)
library(ggplot2)
library(dplyr)
library(tidyr)
library(ComplexHeatmap)
library(ggrepel)
library(ggpubr)
library(ggplotify)
library(ggvenn)
library(ggseqlogo)
library(patchwork)
library(viridis)
library(formatR)
library(edgeR)
library(sva)
library(htmltools)
library(DT)
if (!requireNamespace("downloadthis", quietly = TRUE)) {
  install.packages("downloadthis")
}
library(downloadthis)
knitr::opts_chunk$set(
  echo = F,
  dpi = 150,
  error=FALSE,
  warning = F,
  dev = c("png","pdf"),
  message = F)

#Create directories for analysis
analysis.path<-"output/"
if(!dir.exists(analysis.path))
  dir.create(analysis.path,showWarnings = T,recursive = T)
analysis.tables<-file.path("docs/tables/")
if(!dir.exists(analysis.tables))
  dir.create(analysis.tables, recursive = T)
plots.dir <- file.path("docs/plots/")
if(!dir.exists(plots.dir))
  dir.create(plots.dir, recursive = T)


#Set options to include chunk codes at the end of the report
knitr::opts_chunk$set(fig.path = plots.dir)
# custom hook: after each plot chunk, append a download link
knitr::knit_hooks$set(
  plot = function(x, options) {
    xx <- gsub("png$", "pdf", x)
    fig_link <- xfun::embed_file(xx, text = paste0("Download ", basename(xx)))
    paste0(knitr::hook_plot_md(x, options), "\n\n", fig_link, "\n")
  }
)

#Option plot colours
plot.cols <-
  c(
    "red",
    "blue",
    "green",
    "black",
    "brown",
    "gray",
    "purple",
    "orange",
    "cyan",
    "navy",
    "magenta",
    "peachpuff1",
    "olivedrab",
    "lavender",
    "#635147",
    "#616E00",
    "#008080",
    "#E0B0FF"
  )

generate_datatable <- function(df,
                               show.rownames = F,
                               extra.options=list(scrollX = TRUE, autoWidth = TRUE),
                               width = "100%",include.download=T,...)
{
  button_options<-list(
    dom = 'Bfrtip',
    buttons = c('excel', 'csv', 'copy')
  )
  extensions = NULL
  if(include.download)
  {
    extensions<-"Buttons"
    extra.options<-c(button_options,extra.options)
  }

  DT::datatable(df, rownames = show.rownames,
                options = extra.options,
                extensions = extensions,
                width = width,...)
}

include_file_download<-function(path2file,filename,...){
  download_file(
    path = path2file,
    output_name = gsub(" ","_",filename),
    button_label = paste0("Download ",filename),
    button_type = "primary",
    has_icon = TRUE,
    icon = "fa fa-save",
    ...
  )
}

include_dir_download<-function(path2dir,dirname,...){
  download_dir(
    path = path2dir,
    output_name =gsub(" ","_",dirname),
    button_label = paste0("Download ",dirname),
    button_type = "success",
    icon = "fa fa-save",
    ...
  )
}

plotEnrichment <- function(go_results, go.name)
{
  library(forcats)
  go_plot_data <- go_results %>% mutate(
    Direction = ifelse(P.Up < P.Down, "Upregulated", "Downregulated"),
    SignedCount = ifelse(Direction == "Upregulated", -log10(P.Up), log10(P.Down))
  ) %>% group_by(Direction) %>%
    slice_max(order_by = abs(SignedCount), n = 20) %>%
    ungroup() %>%mutate(Term = fct_reorder(Term, SignedCount))
  gg<-ggplot(go_plot_data, aes(x = SignedCount, y = Term, fill = Direction)) +
    geom_col() +
    geom_vline(xintercept = 0, linetype = "dashed") +
    scale_fill_manual(values = c(
      "Upregulated" = "orange",
      "Downregulated" = "steelblue"
    )) +
    scale_x_continuous(
      labels = function(x)
        abs(x),
      breaks = scales::pretty_breaks()
    ) +
    labs(
      title = paste0(go.name," Enrichment Analysis"),
      x = "log10(p-value)",
      y = go.name,
    ) +
    theme_minimal(base_size = 12) +
    theme(legend.position = "bottom",
          plot.title = element_text(face = "bold"))
  print(gg)
}



plotHeatmap <-
  function(heat.data,
           margin = c(8, 4),
           lhei = c(0.5, 4),
           dendrogram = T,
           cexCol = 0.9,
           labRow = NA,
           colRow = "black",
           cexRow = 0.8,
           main = "Heatmap",
           Colv = T,
           plot.name,
           out.width = 7,
           out.height = 12,
           cex.main = 1,
           key.genes = T,
           ...)
  {
    rowCols <- rep("black", nrow(heat.data))
    if (key.genes)
      rowCols[match(genes.hlight, rownames(heat.data))] <- "purple"
    dendrogram = ifelse(dendrogram, "both", "row")
    linkage.col = ifelse(Colv, "complete", "none")
    for (i in 1:2)
    {
      if (i == 1)
        pdf(
          paste0(heatplots.dir, plot.name, ".pdf"),
          width = out.width,
          height = out.height,
          useDingbats = F
        )
      par(cex.main = cex.main)
      coolmap(
        heat.data,
        lhei = lhei,
        show.dendrogram = dendrogram,
        main = main,
        linkage.col = linkage.col,
        cexCol = cexCol,
        cexRow = cexRow,
        colRow = rowCols,
        ...
      )
      if (i == 1)
        dev.off()
    }
  }


