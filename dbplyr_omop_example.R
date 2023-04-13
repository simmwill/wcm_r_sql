# dbplyr example with OMOP data


# packages ----------------------------------------------------------------

library(tidyverse)
library(dbplyr)

# connect -----------------------------------------------------------------

# this code will look a little different on a Windows machine
con <- DBI::dbConnect(odbc::odbc(),
                      Driver = "FreeTDS",
                      Server = "VITS-ARCHSQLP04.a.wcmc-ad.net",
                      Database = "FULL_OMOP",
                      Port = 1433,
                      # enter cumc\cwid at the prompt
                      uid = rstudioapi::askForPassword("Enter username (cumc\\[your CWID]"),
                      # cwid password
                      pwd = rstudioapi::askForPassword("CWID password")
)

# function to create lazy tables ------------------------------------------

# this won't load entire tables into your R session, but you can still refer to these tables in dbplyr code

lazy_tbl <- function(table, schema = "peds", catalog = "full_omop") {
  dplyr::tbl(con, in_catalog(catalog, schema, table))
}

# standard vocabulary table
concept <- lazy_tbl("concept")

person <- lazy_tbl("person")
condition <- lazy_tbl("condition_occurrence")

# get every patient diagnosed with pediatric epilepsy/infantile spasms ----

# find concepts associated ICD codes of interest: G40.82x, 345.6x
concepts_spasms <- concept |> 
  filter(
    # ICD codes - use concept_code field
    str_like(concept_code, "g40.82%") | str_like(concept_code, "345.6%") |
    # can also just use string search on concept_name (this will help you find diagnoses that aren't recorded with an ICD code, e.g., SNOMED diagnosis codes)
    str_like(concept_name, "%infantile spasm%") 
  ) 

# get patients
infantile_spasm_pts <- person |> 
  inner_join(
    condition |>  # get only relevant conditions by inner joining on the epilepsy concepts
      rename(condition_provider_id = provider_id) |> 
      inner_join(concepts_spasms, by = c("condition_concept_id" = "concept_id")),
    by = "person_id"
  ) |> 
  collect()  
  # by using collect(), you'll actually execute the full SQL query and pull the data into your R console (here, the joined dataframe)
  # this took my computer 5-10 minutes to run

# get earliest diagnosis date per patient
# note: I'm now working with an R dataframe, not a dbplyr lazy table 
diagnosis_dates <- infantile_spasm_pts |> 
  summarise(
    first_diagnosis_date = min(condition_start_date),
    .by = person_id
  )
