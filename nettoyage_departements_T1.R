library(readxl) # read excel files
library(stringr) # manipulate string of characters
library(LireMinInterieur) # transform electoral files
library(tidyverse) # the tidyverse...

pres_2017_R1_departements <- read_excel("./Presidentielle_2017_Resultats_Tour_1.xls", skip = 3, guess_max = 25, sheet = "Départements Tour 1")

pres_2017_R1_departements_cleaned <- lire(pres_2017_R1_departements, keep = c("Code du département", "Libellé du département", "Inscrits", "Abstentions", "Exprimés", "Blancs", "Nuls"), col = seq(18, 78, 6), gap = 2)

pres_2017_R1_departements_cleaned <- pres_2017_R1_departements_cleaned %>% 
  # put geographical codes in the right format
  mutate(CodeDépartement = str_pad(`Code du département`, 2, "left", "0")) %>% 
  mutate(Votants = Inscrits - Abstentions) %>% 
  mutate(Votants_ins = Votants / Inscrits * 100) %>% 
  mutate(Abstentions_ins = Abstentions / Inscrits * 100) %>% 
  mutate(Blancs_ins = Blancs/ Inscrits * 100) %>% 
  mutate(Blancs_vot = Blancs / Votants * 100) %>% 
  mutate(Nuls_ins = Nuls / Inscrits * 100) %>% 
  mutate(Nuls_vot = Nuls / Votants * 100) %>% 
  mutate(Exprimés_ins = Exprimés / Inscrits * 100) %>% 
  mutate (Exprimés_vot = Exprimés / Votants * 100) %>% 
  # specify integers %>% 
  mutate_at(vars(Inscrits, Abstentions, Votants, Blancs, Nuls, Exprimés, `LE PEN`:CHEMINADE), as.integer) %>% 
  # reorder
  select(CodeDépartement, Département = `Libellé du département`, Inscrits, Abstentions, Abstentions_ins, Votants, Votants_ins, Blancs, Blancs_ins, Blancs_vot, Nuls, Nuls_ins, Nuls_vot, Exprimés, Exprimés_ins, Exprimés_vot, `LE PEN`:CHEMINADE, `LE PEN_ins`:CHEMINADE_exp) %>% 
  # nicer, more modern dataframe class
  as_tibble()

write_excel_csv(pres_2017_R1_departements_cleaned, path = "./Presidentielle_2017_Resultats_Département_T1_clean.csv")
