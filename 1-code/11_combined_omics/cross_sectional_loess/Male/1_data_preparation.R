no_source()

rm(list = ls())
setwd(r4projects::get_project_wd())
source("1-code/100-tools.R")

library(tidyverse)
library(tidymass)
library(microbiomedataset)

###load("data)
load(
  "3-data_analysis/plasma_transcriptome/data_preparation/Male/object_cross_section_loess"
)
transcriptome_object <- object_cross_section_loess

load("3-data_analysis/plasma_proteomics/data_preparation/Male/object_cross_section_loess")
proteomics_object <- object_cross_section_loess

load(
  "3-data_analysis/plasma_metabolomics/data_preparation/metabolite/Male/object_cross_section_loess"
)
metabolomics_object <- object_cross_section_loess

load("3-data_analysis/plasma_cytokine/data_preparation/Male/object_cross_section_loess")
cytokine_object <- object_cross_section_loess

load("3-data_analysis/clinical_test/data_preparation/Male/object_cross_section_loess")
clinical_test_object <- object_cross_section_loess

load("3-data_analysis/plasma_lipidomics/data_preparation/Male/object_cross_section_loess")
lipidomics_object <- object_cross_section_loess

load("3-data_analysis/gut_microbiome/data_preparation/Male/object_cross_section_loess")
gut_microbiome_object <- object_cross_section_loess

load("3-data_analysis/skin_microbiome/data_preparation/Male/object_cross_section_loess")
skin_microbiome_object <- object_cross_section_loess

load("3-data_analysis/oral_microbiome/data_preparation/Male/object_cross_section_loess")
oral_microbiome_object <- object_cross_section_loess

load("3-data_analysis/nasal_microbiome/data_preparation/Male/object_cross_section_loess")
nasal_microbiome_object <- object_cross_section_loess

dir.create("3-data_analysis/combined_omics/data_preparation/Male/cross_section_loess",
           recursive = TRUE)

setwd("3-data_analysis/combined_omics/data_preparation/Male/cross_section_loess")

dim(transcriptome_object)
dim(proteomics_object)
dim(metabolomics_object)
dim(cytokine_object)
dim(clinical_test_object)
dim(lipidomics_object)
dim(gut_microbiome_object)
dim(oral_microbiome_object)
dim(skin_microbiome_object)
dim(nasal_microbiome_object)

intersect_sample_id <-
  BiocGenerics::Reduce(
    f = intersect,
    x =  list(
      colnames(transcriptome_object),
      colnames(proteomics_object),
      colnames(metabolomics_object),
      colnames(cytokine_object),
      colnames(lipidomics_object),
      colnames(clinical_test_object),
      colnames(gut_microbiome_object),
      colnames(oral_microbiome_object),
      colnames(skin_microbiome_object),
      colnames(nasal_microbiome_object)
    )
  )

gut_microbiome_object <-
  gut_microbiome_object %>%
  activate_microbiome_dataset(what = "variable_info") %>%
  dplyr::mutate(variable_id = paste0("gut_microbiome_", variable_id))

oral_microbiome_object <-
  oral_microbiome_object %>%
  activate_microbiome_dataset(what = "variable_info") %>%
  dplyr::mutate(variable_id = paste0("oral_microbiome_", variable_id))

skin_microbiome_object <-
  skin_microbiome_object %>%
  activate_microbiome_dataset(what = "variable_info") %>%
  dplyr::mutate(variable_id = paste0("skin_microbiome_", variable_id))

nasal_microbiome_object <-
  nasal_microbiome_object %>%
  activate_microbiome_dataset(what = "variable_info") %>%
  dplyr::mutate(variable_id = paste0("nasal_microbiome_", variable_id))

proteomics_object <-
  proteomics_object %>%
  activate_microbiome_dataset(what = "variable_info") %>%
  dplyr::mutate(variable_id = paste0("proteomics_", variable_id))

transcriptome_object <-
  transcriptome_object %>%
  activate_microbiome_dataset(what = "variable_info") %>%
  dplyr::mutate(variable_id = paste0("transcriptome_", variable_id))

metabolomics_object <-
  metabolomics_object %>%
  activate_microbiome_dataset(what = "variable_info") %>%
  dplyr::mutate(variable_id = paste0("metabolomics_", variable_id))

cytokine_object <-
  cytokine_object %>%
  activate_microbiome_dataset(what = "variable_info") %>%
  dplyr::mutate(variable_id = paste0("cytokine_", variable_id))

lipidomics_object <-
  lipidomics_object %>%
  activate_microbiome_dataset(what = "variable_info") %>%
  dplyr::mutate(variable_id = paste0("lipidomics_", variable_id))

clinical_test_object <-
  clinical_test_object %>%
  activate_microbiome_dataset(what = "variable_info") %>%
  dplyr::mutate(variable_id = paste0("clinical_test_", variable_id))

transcriptome_object@expression_data <-
  transcriptome_object@expression_data %>%
  apply(1, function(x) {
    (x - mean(x)) / sd(x)
  }) %>%
  t() %>%
  as.data.frame()

proteomics_object@expression_data <-
  proteomics_object@expression_data %>%
  apply(1, function(x) {
    (x - mean(x))
  }) %>%
  t() %>%
  as.data.frame()

metabolomics_object@expression_data <-
  metabolomics_object@expression_data %>%
  `+`(1) %>%
  log(2) %>%
  apply(1, function(x) {
    (x - mean(x)) / sd(x)
  }) %>%
  t() %>%
  as.data.frame()

cytokine_object@expression_data <-
  cytokine_object@expression_data %>%
  `+`(1) %>%
  log(2) %>%
  apply(1, function(x) {
    (x - mean(x)) / sd(x)
  }) %>%
  t() %>%
  as.data.frame()

clinical_test_object@expression_data <-
  clinical_test_object@expression_data %>%
  apply(1, function(x) {
    (x - mean(x)) / sd(x)
  }) %>%
  t() %>%
  as.data.frame()

lipidomics_object@expression_data <-
  lipidomics_object@expression_data %>%
  apply(1, function(x) {
    (x - mean(x))
  }) %>%
  t() %>%
  as.data.frame()

gut_microbiome_object@expression_data <-
  gut_microbiome_object@expression_data %>%
  apply(1, function(x) {
    (x - mean(x)) / sd(x)
  }) %>%
  t() %>%
  as.data.frame()

skin_microbiome_object@expression_data <-
  skin_microbiome_object@expression_data %>%
  apply(1, function(x) {
    (x - mean(x)) / sd(x)
  }) %>%
  t() %>%
  as.data.frame()

oral_microbiome_object@expression_data <-
  oral_microbiome_object@expression_data %>%
  apply(1, function(x) {
    (x - mean(x)) / sd(x)
  }) %>%
  t() %>%
  as.data.frame()

nasal_microbiome_object@expression_data <-
  nasal_microbiome_object@expression_data %>%
  apply(1, function(x) {
    (x - mean(x)) / sd(x)
  }) %>%
  t() %>%
  as.data.frame()

object_cross_section_loess <-
  rbind(
    transcriptome_object[, intersect_sample_id],
    proteomics_object[, intersect_sample_id],
    metabolomics_object[, intersect_sample_id],
    cytokine_object[, intersect_sample_id],
    clinical_test_object[, intersect_sample_id],
    lipidomics_object[, intersect_sample_id],
    gut_microbiome_object[, intersect_sample_id],
    skin_microbiome_object[, intersect_sample_id],
    oral_microbiome_object[, intersect_sample_id],
    nasal_microbiome_object[, intersect_sample_id]
  )

variable_info <-
  object_cross_section_loess@variable_info %>%
  dplyr::mutate(
    class = stringr::str_extract(
      variable_id,
      "transcriptome|proteomics|metabolomics|cytokine|clinical_test|lipidomics|gut_microbiome|skin_microbiome|oral_microbiome|nasal_microbiome"
    )
  )

metabolomics_variable_info <-
  extract_variable_info(metabolomics_object) %>%
  dplyr::select(variable_id:Level) %>%
  dplyr::select(-c(na_freq, na_freq.1, mz, rt,
                   polarity.x, column.x,
                   mode.x))

variable_info <-
  variable_info %>%
  dplyr::left_join(metabolomics_variable_info, by = "variable_id")

variable_info <-
  variable_info %>%
  dplyr::mutate(
    mol_name =
      case_when(
        class == "transcriptome" ~ SYMBOL,
        class == "proteomics" ~ stringr::str_replace(variable_id, "proteomics_", ""),
        class == "metabolomics" ~ Compound.name,
        class == "cytokine" ~ stringr::str_replace(variable_id, "cytokine_", ""),
        class == "clinical_test" ~ stringr::str_replace(variable_id, "clinical_test_", ""),
        class == "lipidomics" ~ Lipid_Name,
        class == "gut_microbiome" ~ stringr::str_replace(variable_id, "Genus", ""),
        class == "skin_microbiome" ~ stringr::str_replace(variable_id, "Genus", ""),
        class == "oral_microbiome" ~ stringr::str_replace(variable_id, "Genus", ""),
        class == "nasal_microbiome" ~ stringr::str_replace(variable_id, "Genus", "")
      )
  )

object_cross_section_loess@variable_info <- variable_info

object_cross_section_loess@sample_info$age <- 
  as.numeric(object_cross_section_loess@sample_info$sample_id)

save(object_cross_section_loess, file = "object_cross_section_loess")
