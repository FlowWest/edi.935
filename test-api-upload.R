
# Practice Upload in staging area

# LOAD IN PACKAGES -------------------------------------------------------------
library(EMLaide)
library(tidyverse)
library(readxl)
library(EML)

# PULL EDI USER INFO FROM SYSTEM -----------------------------------------------
user_id <- Sys.getenv("user_id")
password <- Sys.getenv("password")

# DEFINE ALL DATA PACKAGE ELEMENTS ---------------------------------------------

datatable_metadata <-
  dplyr::tibble(filepath = "data/Environmentals.csv",
                attribute_info = "data-raw/Metadata/Environmentals - Metadata.xlsx",
                datatable_description = "Environmental Variables",
                datatable_url = "https://raw.githubusercontent.com/FlowWest/stanislaus_rst_edi/main/data/Environmentals.csv")

excel_path <- "data-raw/Metadata/Environmentals - Metadata.xlsx"
sheets <- readxl::excel_sheets(excel_path)
metadata <- lapply(sheets, function(x) readxl::read_excel(excel_path, sheet = x))
names(metadata) <- sheets

abstract_docx <- "data-raw/Metadata/abstract.docx"
methods_docx <- "data-raw/Metadata/methods.docx"


# GIT EDI NUMBER FOR STAGING AREA ----------------------------------------------
# response <-httr::POST(
#     url = "https://pasta-s.lternet.edu/package/reservations/eml/edi",
#     config = httr::authenticate(paste("uid=", user_id, ",o=EDI", ",dc=edirepository,dc=org"), password))
#
#
# edi_number <- httr::content(response, as = "text", encoding = "UTF-8")
# edi_number <- paste0("edi.", edi_number, ".1", sep = "")

edi_number <- "edi.828.1"


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

custom_units <- data.frame(id = c("nephelometric turbidity units"),
                           unitType = c("dimensionless"),
                           parentSI = c(NA),
                           multiplierToSI = c(NA),
                           description = c("Nephelometric turbidity units, common unit for measuring turbidity"))

unitList <- EML::set_unitList(custom_units)

eml <- list(packageId = edi_number,
            system = "EDI",
            access = add_access(),
            dataset = dataset,
            additionalMetadata = list(metadata = list(unitList = unitList)))
edi_number
EML::write_eml(eml, "edi.828.1.xml")
EML::eml_validate("edi.828.1.xml")

# EVALUATE DATA PACKAGE --------------------------------------------------------
generate_report_df <- function(response) {
  report <- httr::content(response, as = 'text', encoding = 'UTF-8')
  name <- stringr::str_extract_all(report, "(?<=<name>)(.*)(?=</name>)")[[1]]
  status <- stringr::str_extract_all(report, '[:alpha:]+(?=</status>)')[[1]]
  suggestion <- stringr::str_extract_all(report, "(?<=<suggestion>)(.*)(?=</suggestion>)")[[1]]

  report_df <- dplyr::tibble("Status" = as.vector(status),
                             "Element Checked" = as.vector(name),
                             "Suggestion to fix/imporve" = as.vector(suggestion))
  if (nchar(report) <= 500){
    print(report)
  }
  return(report_df)
}

eval_response <- httr::POST(
  url = "https://pasta-s.lternet.edu/package/evaluate/eml",
  config = httr::authenticate(paste('uid=', user_id, ",o=EDI", ',dc=edirepository,dc=org'), password),
  body = httr::upload_file("edi.828.1.xml")
)

transaction_id <- httr::content(eval_response, as = 'text', encoding = 'UTF-8')
transaction_response<- httr::GET(
  url = paste0("https://pasta-s.lternet.edu/package/evaluate/report/eml/", transaction_id),
  config = httr::authenticate(paste('uid=', user_id, ",o=EDI", ',dc=edirepository,dc=org'), password)
)
report_df <- generate_report_df(transaction_response) # ERRORS IN THE ENTITY SIZE +

View(report_df)

# UPLOAD DATA PACKAGE TO STAGING AREA ------------------------------------------
post_upload_response <- httr::POST(
  url = "https://pasta-s.lternet.edu/package/eml/",
  config = httr::authenticate(paste('uid=', user_id, ",o=EDI", ',dc=edirepository,dc=org'), password),
  body = httr::upload_file("edi.828.1.xml")
)

post_transaction_id <- httr::content(post_upload_response, as = 'text', encoding = 'UTF-8')


check_error <- httr::GET(url = paste0("https://pasta-s.lternet.edu/package/error/eml/", post_transaction_id),
                         config = httr::authenticate(paste('uid=', user_id, ",o=EDI", ',dc=edirepository,dc=org'), password))

# If check error = 200 it means the package is not valid - we must view errors in error report dataframe
error_report <- generate_report_df(check_error)
View(error_report)

check_upload <- httr::GET(url = paste0("https://pasta-s.lternet.edu/package/report/eml/",
                                stringr::str_replace_all(basename("edi.828.1.xml"), "\\.", "/")),
                                config = httr::authenticate(paste('uid=', user_id, ",o=EDI", ',dc=edirepository,dc=org'), password))
