

# AUTENTICACIÓN
googledrive::drive_auth(path = "key.json")
gs4_auth(token = googledrive::drive_token())

ss <- "1QoeU6cqkADhu91loXfKhQC6ErcG54bafe1vQj_-nQis"

sheets <- sheet_properties(ss)$name


for (sheet_name in sheets) {

  df_name <- sheet_name |>
    str_to_upper() |>
    str_replace_all("[^A-Z0-9]+", "_") |>  
    str_replace_all("^_|_$", "")           
  
  df_data <- read_sheet(ss, sheet = sheet_name)
  assign(df_name, df_data, envir = .GlobalEnv)
}

CAPACITY_PLAN_TO_SKILLS <-
  CAPACITY_PLAN_TO_SKILLS |> 
  separate_rows(SKILLSET_NAME, sep = ",") |> 
  mutate(SKILLSET_NAME = str_trim(SKILLSET_NAME)) |> 
  distinct()

SKILL_DATA <-
  SKILL_DATA |> 
  mutate(Skill_type = str_extract(Skill, "^[^|]+") %>% str_trim()) |> 
  left_join(CAPACITY_PLAN_TO_SKILLS,
            by = c("Skill ID" = "SKILLSET_NAME"))
  

rm(df_data)


x <- 
SKILL_DATA |> 
  mutate(
    inv_rcr = 1-`[RCR %]`
  ) 

x |> 
  e_charts(AHT) |> 
  e_scatter(
    inv_rcr
  ) |> 
  e_tooltip(trigger = "axis") |> 
  e_y_axis(min = min(x$inv_rcr, na.rm = T))







