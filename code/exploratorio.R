# exploratorio.R

library(dplyr)
library(ggplot2)

source("utils.R")

theme_set(theme_bw(base_size = 20))

##############################################
## Determinar el dataset con el que se va a trabajar
##############################################

# Si el script se ejecuta en forma interactiva (desde algún IDE), entonces toma el dataset de movielens. Si se ejecuta automáticamente desde otro script o desde la terminal, debe llevar como argumento cuál dataset se quiere analizar

if(!interactive()){ 
  args <- commandArgs(TRUE)
  dataset <- args[1]
  time <- args[2]
  if(length(args) == 0) {
    cat("No especificaste dataset ni carpeta de salida\n\n")
    quit(save = "no", status = 0, runLast = FALSE)
  } 
} else {
  # dataset <- "MovieLens"
  dataset <- "BookCrossing"
  time <- substr(Sys.time(), 1, 19) %>% gsub("[ :]", "_", .)
}

folder <- paste0("../out/", dataset)
folder_plots <- paste0(folder, "/plots")
folder_models <- paste0(folder, "/models")
folder_tables <- paste0(folder, "/tables")
# 
# system(paste("mkdir", folder))
system(paste("mkdir", folder_plots))
# system(paste("mkdir", folder_models))
# system(paste("mkdir", folder_tables))

file_name_train <- paste0("../out/", dataset, "/train.rds")
file_name_test <- paste0("../out/", dataset, "/test.rds")

cat("Leyendo archivos de calificaciones\n")

# train_data <- readRDS(file_name_train)
# test_data <- readRDS(file_name_test)

ratings <- read_csv(paste0("../data/", dataset, "/ratings.csv"))
items <- read_csv(paste0("../data/", dataset, "/items.csv"))

num_usuarios <- ratings$userId %>% unique() %>% length()
num_items <- ratings$itemId %>% unique() %>% length()
num_calis <- nrow(ratings)

cat("Número de usuarios:", num_usuarios, "\n")
cat("Número de items:", num_items, "\n")
cat("Número de calificaciones:", num_calis, "\n")
cat("Porcentaje de matriz llena: ", round(100*num_calis/(num_items*num_items), 3), "%\n", sep = "")

(ratings %>% 
    group_by(rating) %>% 
    tally() %>% 
    ggplot() +
    geom_bar(aes(rating, n), stat = 'identity') +
    xlab("Calificación") +
    ylab("Número de artículos") +
    ggtitle("Frecuencias de calificaciones de artículos") +
    theme(plot.title = element_text(hjust = 0.5))
  ) %>% 
  ggsave(filename = paste0(folder_plots, 
                           "/frecuencia_calificaciones_", 
                           dataset, 
                           ".pdf"),
         device = "pdf")


ratings_prom <- ratings %>% 
  group_by(itemId) %>% 
  summarize(rating_prom = mean(rating),
            num_ratings = n()) %>% 
  left_join(items)


# Calificación promedio de cada artículo
(ratings_prom %>% 
    ggplot() +
    geom_histogram(aes(rating_prom)) +
    xlab("Calificación promedio") +
    ylab("Número de artículos")
) %>% 
  ggsave(filename = paste0(folder_plots, 
                           "/calificacion_promedio_articulo_", 
                           dataset, 
                           ".pdf"),
         device = "pdf")


# Long tail distribution
(ratings_prom %>% 
    arrange(desc(num_ratings)) %>% 
    mutate(ix = 1:nrow(.)) %>% 
    ggplot(aes(ix, num_ratings)) + 
    geom_line() +
    xlab("Artículos") +
    ylab("Número de calificaciones")
) %>% 
  ggsave(filename = paste0(folder_plots, 
                           "/long_tail_", 
                           dataset, 
                           ".pdf"),
         device = 'pdf')

# 
# 
# plot_histogram_quantiles <- function(data, 
#                                      variable, 
#                                      quantiles, 
#                                      cut_quantile = 1){
#   ix_col <- which(names(data) == variable)
#   quantiles2 <- c(cut_quantile, quantiles)
#   q <- quantile(data[[ix_col]], quantiles2)
#   data %>% 
#     rename_("variable2" = variable) %>% 
#     filter(variable2 <= q[1]) %>% 
#     ggplot() +
#     geom_histogram(aes(variable2)) +
#     geom_vline(xintercept = q[2:length(q)], color = 'red')
# }
# 
# plot_histogram_quantiles(ratings_prom, 
#                          "num_ratings", 
#                          c(0.5, 0.7, 0.9)) +
#   ggtitle("Histograma del número de calificaciones de cada artículo") +
#   xlab("Número de calificaciones") +
#   ylab("Número de artículos")
# 
# plot_histogram_quantiles(ratings_prom, 
#                          "num_ratings", 
#                          c(0.5, 0.7), 0.75) +
#   ggtitle("Histograma del número de calificaciones de cada artículo") +
#   xlab("Número de calificaciones") +
#   ylab("Número de artículos") +
#   theme_minimal()
# 
# ratings_prom %>% 
#   arrange(desc(rating_prom)) %>% 
#   head(15)
# 
# ratings_prom %>% 
#   filter(num_ratings > quantile(num_ratings, 0.7)) %>% 
#   arrange(desc(rating_prom)) %>% 
#   head(30)
# 
# 
# 
# 
