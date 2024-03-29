no_source()

rm(list = ls())
setwd(r4projects::get_project_wd())
source("1-code/100-tools.R")

library(tidyverse)
library(tidymass)

###load("data)
load(
  "3-data_analysis/combined_omics/data_preparation/Female/cross_section_loess/object_cross_section_loess"
)

dir.create(
  "3-data_analysis/combined_omics/Female/fuzzy_c_means_clustering/cross_section_loess/",
  recursive = TRUE
)

setwd("3-data_analysis/combined_omics/Female/fuzzy_c_means_clustering/cross_section_loess")

object_cross_section_loess

object_cross_section_loess <-
  object_cross_section_loess %>%
  activate_mass_dataset(what = "sample_info") %>%
  dplyr::mutate(age = as.numeric(sample_id)) %>%
  dplyr::arrange(age)

# ###calculate the correlation between age and molecules
# cor_data <-
#   seq_len(nrow(object_cross_section_loess)) %>%
#   purrr::map(function(i){
#     value <-
#       object_cross_section_loess[i,,drop = TRUE] %>%
#       unlist()
#     age <-
#       object_cross_section_loess@sample_info$age
#     test <-
#       cor.test(age, value, method = "spearman")
#     data.frame(variable_id = rownames(object_cross_section_loess)[i],
#                correlation = unname(test$estimate),
#                p_value = test$p.value)
#   }) %>%
#   dplyr::bind_rows() %>%
#   as.data.frame()
# 
# save(cor_data, file = "cor_data")

load("cor_data")

####clustering
library(Mfuzz)

temp_data <-
  object_cross_section_loess@expression_data

expression_data <-
  object_cross_section_loess@expression_data

time <- colnames(temp_data)

temp_data <- rbind(time, temp_data)

row.names(temp_data)[1] <- "time"
rownames(temp_data)

# write.table(
#   temp_data,
#   file = "temp_data.txt",
#   sep = '\t',
#   quote = FALSE,
#   col.names = NA
# )

#read it back in as an expression set
data <- table2eset(filename = "temp_data.txt")
# data.s <- standardise(data)
data.s <- data
m1 <- mestimate(data.s)
m1

# plot <-
#   Dmin(
#     data.s,
#     m = m1,
#     crange = seq(2, 40, 2),
#     repeats = 3,
#     visu = TRUE
#   )
# 
# plot <-
#   plot %>%
#   data.frame(distance = plot,
#              k = seq(2, 40, 2)) %>%
#   ggplot(aes(k, distance)) +
#   geom_point(shape = 21, size = 4, fill = "black") +
#   # geom_smooth() +
#   geom_segment(aes(
#     x = k,
#     y = 0,
#     xend = k,
#     yend = distance
#   )) +
#   theme_bw() +
#   theme(
#     # legend.position = c(0, 1),
#     # legend.justification = c(0, 1),
#     panel.grid = element_blank(),
#     axis.title = element_text(size = 13),
#     axis.text = element_text(size = 12),
#     panel.background = element_rect(fill = "transparent", color = NA),
#     plot.background = element_rect(fill = "transparent", color = NA),
#     legend.background = element_rect(fill = "transparent", color = NA)
#   ) +
#   labs(x = "Cluster number",
#        y = "Min. centroid distance") +
#   scale_y_continuous(expand = expansion(mult = c(0, 0.1)))
# 
# plot
# 
# ggsave(plot,
#        filename = "distance_k_number.pdf",
#        width = 7,
#        height = 7)

cluster_number <- 15

# c <- mfuzz(data.s, c = cluster_number, m = m1)
# 
# save(c, file = "c")
# load("c")
# ####any two clusters with correlation > 0.8 should be considered as one
library(corrplot)
layout(1)
# center <- c$centers

membership_cutoff <- 0.5

center <-
  get_mfuzz_center(data = data.s,
                   c = c,
                   membership_cutoff = 0.5)
rownames(center) <- paste("Cluster", rownames(center), sep = ' ')

corrplot::corrplot(
  corr = cor(t(center)),
  type = "full",
  diag = TRUE,
  order = "hclust",
  hclust.method = "ward.D",
  # addrect = 5,
  col = colorRampPalette(colors = rev(
    RColorBrewer::brewer.pal(n = 11, name = "Spectral")
  ))(n = 100),
  number.cex = .7,
  addCoef.col = "black"
)

mfuzz.plot(
  eset = data.s,
  min.mem = 0.5,
  cl = c,
  mfrow = c(4, 4),
  time.labels = time,
  new.window = FALSE
)

library(ComplexHeatmap)

cluster_info <-
  data.frame(
    variable_id = names(c$cluster),
    c$membership,
    cluster = c$cluster,
    stringsAsFactors = FALSE
  ) %>%
  arrange(cluster)

####plot for each cluster
idx <- 1

temp_data <-
  data.s %>% as.data.frame() %>%
  t() %>% as.data.frame()

variable_info <-
  object_cross_section_loess@variable_info

# for (idx in 1:cluster_number) {
#   cat(idx, " ")
# 
#   cluster_data <-
#     cluster_info %>%
#     # dplyr::filter(cluster == idx) %>%
#     dplyr::select(1, 1 + idx, cluster)
# 
#   colnames(cluster_data)[2] <- c("membership")
# 
#   cluster_data <-
#     cluster_data %>%
#     dplyr::filter(membership > membership_cutoff)
# 
#   path <- paste("cluster", idx, sep = "_")
#   dir.create(path)
# 
#   openxlsx::write.xlsx(
#     cluster_data,
#     file = file.path(path, paste("cluster", idx, ".xlsx", sep = "")),
#     asTable = TRUE,
#     overwrite = TRUE
#   )
# 
#   temp_center <-
#     center[idx, , drop = TRUE] %>%
#     unlist() %>%
#     data.frame(time = names(.),
#                value = .,
#                stringsAsFactors = FALSE) %>%
#     dplyr::mutate(time = as.numeric(time))
# 
#   temp <-
#     expression_data[cluster_data$variable_id,] %>%
#     data.frame(
#       membership = cluster_data$membership,
#       .,
#       stringsAsFactors = FALSE,
#       check.names = FALSE
#     ) %>%
#     tibble::rownames_to_column(var = "variable_id") %>%
#     tidyr::pivot_longer(
#       cols = -c(variable_id, membership),
#       names_to = "time",
#       values_to = "value"
#     ) %>%
#     dplyr::mutate(time = as.numeric(time)) %>%
#     dplyr::left_join(variable_info[, c("variable_id", "class")],
#                      by = "variable_id")
# 
#   plot <-
#     temp %>%
#     dplyr::arrange(membership, variable_id) %>%
#     dplyr::arrange(desc(class)) %>%
#     dplyr::mutate(variable_id = factor(variable_id, levels = unique(variable_id))) %>%
#     ggplot(aes(time, value, group = variable_id)) +
#     geom_line(aes(color = class), alpha = 0.7) +
#     theme_bw() +
#     theme(
#       legend.position = "bottom",
#       legend.justification = c(0, 1),
#       panel.grid = element_blank(),
#       axis.title = element_text(size = 13),
#       axis.text = element_text(size = 12),
#       axis.text.x = element_text(size = 12),
#       panel.background = element_rect(fill = "transparent", color = NA),
#       plot.background = element_rect(fill = "transparent", color = NA),
#       legend.background = element_rect(fill = "transparent", color = NA)
#     ) +
#     labs(
#       x = "",
#       y = "Z-score",
#       title = paste("Cluster ",
#                     idx,
#                     " (",
#                     nrow(cluster_data),
#                     " molecules)",
#                     sep = "")
#     ) +
#     geom_line(
#       mapping = aes(time, value, group = 1),
#       data = temp_center,
#       size = 2
#     ) +
#     geom_hline(yintercept = 0) +
#     scale_color_manual(values = omics_color)
#   # viridis::scale_color_viridis()
# 
#   plot
# 
#   ggsave(
#     plot,
#     filename = file.path(path, paste("cluster", idx, ".pdf", sep = "")),
#     width = 8,
#     height = 7
#   )
# }

table(cluster_info$cluster)

cluster_info <-
  unique(cluster_info$cluster) %>%
  purrr::map(function(x) {
    temp <-
      cluster_info %>%
      # dplyr::filter(cluster == x) %>%
      dplyr::select(variable_id, paste0("X", x), cluster)
    colnames(temp)[2] <- "membership"
    temp <-
      temp %>%
      dplyr::filter(membership >= membership_cutoff)
    temp <-
      temp %>%
      dplyr::mutate(cluster_raw = cluster) %>%
      dplyr::mutate(cluster = x)
    temp
  }) %>%
  dplyr::bind_rows() %>%
  as.data.frame()

cluster_info %>%
  dplyr::count(cluster)

cluster_info %>%
  dplyr::filter(membership > 0.5) %>%
  dplyr::count(cluster)

final_cluster_info <-
  cluster_info

save(final_cluster_info, file = "final_cluster_info")

openxlsx::write.xlsx(
  final_cluster_info,
  file = "final_cluster_info.xlsx",
  asTable = TRUE,
  overwrite = TRUE
)

dim(final_cluster_info)

dim(expression_data)

# final_cluster_info %>%
#   dplyr::filter(
#     variable_id %in% c(
#       "clinical_test_A1C",
#       "clinical_test_MONO",
#       "clinical_test_MONOAB",
#       "clinical_test_RDW",
#       "cytokine_PDGFBB",
#       "transcriptome_LIPM",
#       "transcriptome_NOB1"
#     )
#   )
# 
# ###heatmap
# library(ComplexHeatmap)
# library(circlize)
# col_fun = colorRamp2(c(-2, 0, 2),
#                      c(
#                        viridis::viridis(n = 3)[1],
#                        viridis::viridis(n = 3)[2],
#                        viridis::viridis(n = 3)[3]
#                      ))
# 
# temp_data <-
#   unique(final_cluster_info$cluster) %>%
#   purrr::map(function(i) {
#     x <-
#       final_cluster_info$variable_id[final_cluster_info$cluster == i]
#     variable_info %>%
#       dplyr::filter(variable_id %in% x) %>%
#       dplyr::count(class) %>%
#       dplyr::mutate(cluster = i) %>%
#       dplyr::mutate(n = n * 100 / sum(n))
#   }) %>%
#   dplyr::bind_rows() %>%
#   dplyr::mutate(class = factor(class, levels = names(omics_color))) %>%
#   tidyr::pivot_wider(names_from = "class", values_from = "n") %>%
#   tibble::column_to_rownames(var = "cluster")
# 
# temp_data[is.na(temp_data)] <- 0
# 
# temp_data <-
#   temp_data[, names(omics_color)]
# 
# temp_cor <-
#   unique(final_cluster_info$cluster) %>%
#   purrr::map(function(i) {
#     x <-
#       final_cluster_info$variable_id[final_cluster_info$cluster == i]
#     cor_data %>%
#       dplyr::filter(variable_id %in% x) %>%
#       dplyr::mutate(cluster = i) %>%
#       dplyr::select(cluster, correlation) %>%
#       dplyr::mutate(id = dplyr::row_number())
#   }) %>%
#   dplyr::bind_rows() %>%
#   tidyr::pivot_wider(names_from = "id", values_from = "correlation") %>%
#   tibble::column_to_rownames(var = "cluster") %>%
#   t() %>%
#   as.data.frame()
# 
# ha <-
#   rowAnnotation(
#     Molecule_class = anno_barplot(
#       x = temp_data,
#       gp = gpar(fill = omics_color, col = "black"),
#       bar_width = 1,
#       height = unit(13, "cm")
#     ),
#     correlation = anno_boxplot(
#       x = t(temp_cor),
#       gp = gpar(outline = FALSE,
#                 col = ggsci::pal_aaas()(n = 5)[3]),
#       height = unit(7, "cm")
#     )
#   )
# 
# plot <-
#   Heatmap(
#     center,
#     show_column_names = TRUE,
#     show_row_names = TRUE,
#     cluster_columns = FALSE,
#     cluster_rows = TRUE,
#     show_row_dend = TRUE,
#     col = col_fun,
#     border = TRUE,
#     name = "Z-score",
#     right_annotation = ha
#   )
# 
# plot
# 
# plot <-
#   ggplotify::as.ggplot(plot)
# plot
# 
# # ggsave(plot,
# #        file = "cluster_heatmap.pdf",
# #        width = 14,
# #        height = 3)
