library(readr)
library(stringr) # manipulate string of characters
library(LireMinInterieur)
library(tidyverse) # the tidyverse...

pres_2017_R1_BV <- read_csv2("./définitifs/PR17_BVot_T1_FE.csv", guess_max = 80000)

pres_2017_R1_BV_cleaned <- lire(pres_2017_R1_BV, keep = c("Code du département", "Libellé du département", "Code de la circonscription", "Code de la commune", "Libellé de la commune", "Code du b.vote", "Inscrits", "Abstentions", "Exprimés", "Blancs", "Nuls"), col = seq(24, 94, 7), gap = 2)

pres_2017_R1_BV_cleaned <- pres_2017_R1_BV_cleaned %>% 
  # put geographical codes in the right format
  mutate(CodeDepartement = str_pad(string = `Code du département`, width = 2, side = "left", pad = "0")) %>% # has to be in a format like "02"
  mutate(NumeroCirco = str_pad(`Code de la circonscription`, 2, "left", "0")) %>%
  mutate(CodeCirco = paste0(CodeDepartement, NumeroCirco)) %>% 
  mutate(CodeCommune = str_pad(string = `Code de la commune`, width = 3, side = "left", pad = "0")) %>% 
  mutate(CodeInsee = paste0(CodeDepartement, CodeCommune)) %>%  # unique commune ID
  # computing missing values
  mutate(NumeroBV = str_pad(`Code du b.vote`, width = "4", side = "left", pad = "0")) %>% 
  mutate(CodeBV = paste0(CodeInsee, NumeroBV)) %>% 
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
  select(CodeBV, CodeInsee, CodeDepartement, Département = `Libellé du département`, CodeCirco, Commune = `Libellé de la commune`, NumeroBV, Inscrits, Abstentions, Abstentions_ins, Votants, Votants_ins, Blancs, Blancs_ins, Blancs_vot, Nuls, Nuls_ins, Nuls_vot, Exprimés, Exprimés_ins, Exprimés_vot, `LE PEN`:CHEMINADE, `LE PEN_ins`:CHEMINADE_exp) %>% 
  # nicer, more modern dataframe class
  as_tibble()

write_excel_csv(pres_2017_R1_BV_cleaned, path = "./Presidentielle_2017_Resultats_BV_T1_clean_def.csv")
