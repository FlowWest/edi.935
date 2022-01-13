library(EMLaide)
library(tidyverse)
library(readxl)
library(EML)

datatable_metadata <-
  dplyr::tibble(filepath = c("data/Environmentals.csv",
                             "data/ByCatch.csv",
                             "data/Chinook.csv",
                             "data/Steelhead.csv",
                             "data/TrapEfficiencyRelease.csv",
                             "data/TrapEfficiencySummary.csv",
                             "data/TrapOperations.csv"),
                attribute_info = c("data-raw/Metadata/Environmentals - Metadata.xlsx",
                                   "data-raw/Metadata/Raw Catch - ByCatch - Metadata.xlsx",
                                   "data-raw/Metadata/Raw Catch - Chinook - Metadata.xlsx",
                                   "data-raw/Metadata/Raw Catch - Steelhead - Metadata.xlsx",
                                   "data-raw/Metadata/Trap Efficiency Release FL - Metadata.xlsx",
                                   "data-raw/Metadata/Trap Efficiency Summary - Metadata.xlsx",
                                   "data-raw/Metadata/Trap Operations - Metadata.xlsx"),
                datatable_description = c("Environmental Variables",
                                          "Raw Catch - ByCatch",
                                          "Raw Catch - Chinook Salmon",
                                          "Raw Catch - Steelhead",
                                          "Trap Efficiency Release Fork Length",
                                          "Trap Efficiency Summary",
                                          "Trap Operations"),
                datatable_url = paste0("https://raw.githubusercontent.com/FlowWest/lower-american-river-rst-edi/main/data/",
                                       c("Environmentals.csv",
                                         "ByCatch.csv",
                                         "Chinook.csv",
                                         "Steelhead.csv",
                                         "TrapEfficiencyRelease.csv",
                                         "TrapEfficiencySummary.csv",
                                         "TrapOperations.csv")))
# save cleaned data to `data/`
excel_path <- "data-raw/Metadata/Environmentals - Metadata.xlsx"
sheets <- readxl::excel_sheets(excel_path)
metadata <- lapply(sheets, function(x) readxl::read_excel(excel_path, sheet = x))
names(metadata) <- sheets

abstract_docx <- "data-raw/Metadata/abstract.docx"
methods_docx <- "data-raw/Metadata/methods.docx"

# edi_number <- reserve_edi_id(user_id = Sys.getenv("user_id"), password = Sys.getenv("password"))
edi_number <- "edi.935.1"

dataset <- list() %>%
  add_pub_date() %>%
  add_title(metadata$title) %>%
  add_personnel(metadata$personnel) %>%
  add_keyword_set(metadata$keyword_set) %>%
  add_abstract(abstract_docx) %>%
  add_license(metadata$license) %>%
  add_method(methods_docx) %>%
  add_maintenance(metadata$maintenance) %>%
  add_project(metadata$funding) %>%
  add_coverage(metadata$coverage, metadata$taxonomic_coverage) %>%
  add_datatable(datatable_metadata)

# GO through and check on all units
custom_units <- data.frame(id = c("number of fish", "rotations per minute", "rotations", "nephelometric turbidity units", "days"),
                           unitType = c("density", "dimensionless", "dimensionless", "dimensionless", "dimensionless"),
                           parentSI = c(NA, NA, NA, NA, NA),
                           multiplierToSI = c(NA, NA, NA, NA, NA),
                           description = c("Fish density in the enclosure, number of fish in total enclosure space",
                                           "Number of trap rotations in one minute",
                                           "Total rotations",
                                           "Nephelometric turbidity units, common unit for measuring turbidity",
                                           "The day sampling occured"))

unitList <- EML::set_unitList(custom_units)

eml <- list(packageId = edi_number,
            system = "EDI",
            access = add_access(),
            dataset = dataset,
            additionalMetadata = list(metadata = list(unitList = unitList)))
edi_number
EML::write_eml(eml, "edi.935.1.xml")
EML::eml_validate("edi.935.1.xml")

EMLaide::evaluate_edi_package(Sys.getenv("user_ID"), Sys.getenv("password"), "edi.935.1.xml")
EMLaide::upload_edi_package(Sys.getenv("user_ID"), Sys.getenv("password"), "edi.935.1.xml")
