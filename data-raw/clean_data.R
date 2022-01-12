library(tidyverse)
library(readxl)
library(lubridate)

# 7 datasets

# Environmental
raw_environmental <- read_excel("data-raw/Data/Updated -- 01-10-2022/Environmentals.xlsx")

raw_environmental %>%
  mutate(Date = as.Date(Date)) %>%
  glimpse()
table(raw_environmental$subSiteName)
hist(raw_environmental$turbidity)# couple of instances of high turbidity
raw_environmental %>% filter(turbidity > 30) # Some comments on high water depth at these times (likely high flows leading to turbid conditions)

write_excel_csv(raw_environmental, "data/Environmentals.csv")


# Raw Catch - ByCatch
raw_bycatch <- read_excel("data-raw/Data/Updated -- 01-10-2022/Raw Catch - ByCatch.xlsx")

raw_bycatch %>%
  mutate(Date = as.Date(Date)) %>%
  glimpse()

table(raw_bycatch$commonName)
hist(raw_bycatch$totalLength) # Couple very large bycatch (total length)
hist(raw_bycatch$n) # All catch describe 1 fish

write_excel_csv(raw_bycatch, "data/ByCatch.csv")

# Raw Catch - Chinook
raw_chinook <- read_excel("data-raw/Data/Updated -- 01-10-2022/Raw Catch - Chinook.xlsx", col_types = c("date", "numeric", "text", "numeric",
                                                                                                        "numeric", "text", "numeric", "text", "text",
                                                                                                        "text", "text", "numeric", "numeric", "text", "text",
                                                                                                        "text", "text", "numeric", "text", "text"))

raw_chinook %>%
  mutate(Date = as.Date(Date)) %>%
  glimpse()

table(raw_chinook$markType) # no comments
hist(raw_chinook$forkLength)


write_excel_csv(raw_chinook, "data/Chinook.csv")

# Raw Catch - Steelhead
## Only 2 steelhead caught

raw_steelhead <- read_excel("data-raw/Data/Updated -- 01-10-2022/Raw Catch - Steelhead.xlsx")
raw_steelhead %>%
  mutate(Date = as.Date(Date)) %>%
  glimpse()

table(raw_steelhead$markType)
hist(raw_steelhead$n)

write_excel_csv(raw_steelhead, "data/Steelhead.csv")

# Trap Efficiency Release FL

raw_trap_efficency <- read_excel("data-raw/Data/Updated -- 01-10-2022/Trap Efficiency Release FL.xlsx", col_types = c("numeric", "numeric", "numeric", "text"))
raw_trap_efficency %>%
  glimpse()

table(raw_trap_efficency$ReleaseFish.comments) # no comments
hist(raw_trap_efficency$forkLength)

write_excel_csv(raw_trap_efficency, "data/TrapEfficiencyRelease.csv")

# Trap Efficiency Summary
raw_trap_summary <- read_excel("data-raw/Data/Updated -- 01-10-2022/Trap Efficiency Summary.xlsx")
raw_trap_summary %>%
  mutate(includeTestComments = str_replace_all(string = includeTestComments, ",", ""),
         Release.comments = str_replace_all(string = Release.comments, ",", "")) %>%
  glimpse()

table(raw_trap_summary$targetSiteName)
hist(raw_trap_summary$nReleased)

write_excel_csv(raw_trap_summary, "data/TrapEfficiencySummary.csv")
# Trap Operations
raw_trap_operations <- read_excel("data-raw/Data/Updated -- 01-10-2022/Trap Operations.xlsx")
raw_trap_operations %>%
  mutate(Date = as.Date(Date)) %>%
  glimpse()

table(raw_trap_operations$includeCatch)
hist(raw_trap_operations$debrisVolume)

# save cleaned data to `data/`
write_excel_csv(raw_trap_operations, "data/TrapOperations.csv")


read_csv("data/Environmentals.csv") %>% glimpse()
read_csv("data/ByCatch.csv") %>% glimpse()
read_csv("data/Chinook.csv") %>% glimpse()
read_csv("data/Steelhead.csv") %>% glimpse()
read_csv("data/TrapEfficiencyRelease.csv") %>% glimpse()
read_csv("data/TrapEfficiencySummary.csv") %>% glimpse()
read_csv("data/TrapOperations.csv") %>% glimpse()



