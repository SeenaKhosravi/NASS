### Overview_Graphs.R

### HCUP NASS 2020 Data Analysis
### Author: SgtKlinger
### Date: 2025-02-10

### Description: This script generates overview graphs
### for the HCUP NASS 2020 data

# Load required libraries
library(data.table)
library(ggplot2)
library(dplyr)
library(ComplexHeatmap)

# Load the cleaned NASS 2020 data
NASS_2020_all <- fread(file.path(getwd(), "NASS_2020_all.csv"))

# Define labels for factor variables
teach_labels <- c("0" = "Non-Teaching", "1" = "Teaching")
location_labels <- c("0" = "Rural", "1" = "Urban")
bed_labels <- c("1" = "0-99", "2" = "100-299", "3" = "300+")
region_labels <- c("1" = "Northeast", "2" = "Midwest", "3" = "South", "4" = "West")
race_labels <- c("1" = "White", "2" = "Black", "3" = "Hispanic", "4" = "Asian/Pacific", "5" = "Native", "6" = "Other")
pay_labels <- c("1" = "Medicare", "2" = "Medicaid", "3" = "Private", "4" = "Self", "5" = "No Charge", "6" = "Other")
pl_nchs_labels <- c("1" = "Large Central", "2" = "Large Fringe", "3" = "Medium", "4" = "Small", "5" = "Micro", "6" = "Non-core")

# FIGURE 1a: Hospital Overview by Location, Teaching Status, Region segmented by bed size
ggplot(NASS_2020_all, aes(x = HOSP_REGION, fill = HOSP_BEDSIZE_CAT)) +
  geom_bar() +
  theme_classic() +
  xlab("US Region") +
  ggtitle("Hospitals within NASS 2020 Dataset", subtitle = "Segmented by Bed Size Category") +
  guides(fill = guide_legend(title = "Bed Size Category")) +
  scale_fill_discrete(labels = bed_labels) +
  facet_grid(HOSP_LOCATION ~ HOSP_TEACH, labeller = labeller(HOSP_TEACH = teach_labels, HOSP_LOCATION = location_labels, HOSP_REGION = region_labels))

# FIGURE 1b: Hospital Ambulatory surgery Encounters Distribution by Locations, Teaching Status, Region
ggplot(NASS_2020_all, aes(x = HOSP_REGION, y = TOTAL_AS_ENCOUNTERS)) +
  geom_boxplot() +
  theme_classic() +
  xlab("US Region") +
  ggtitle("Hospitals within NASS 2020 Dataset", subtitle = "Distribution of Ambulatory Surgery Volumes") +
  facet_grid(HOSP_LOCATION ~ HOSP_TEACH, labeller = labeller(HOSP_TEACH = teach_labels, HOSP_LOCATION = location_labels))

# Prepare top 10 procedure list for figure 2
CCS_total <- table(NASS_2020_all$CPTCCS1)
TopCPT <- tail(names(sort(CCS_total)), 10)
NASS_2020_TopCPT <- subset(NASS_2020_all, CPTCCS1 %in% TopCPT)
NASS_2020_TopCPT$CPTCCS1 <- factor(NASS_2020_TopCPT$CPTCCS1, levels = rev(TopCPT))

# FIGURE 2a: Top 10 Most Common Ambulatory Surgeries by income quartile
ggplot(subset(NASS_2020_TopCPT, ZIPINC_QRTL > 0 & ZIPINC_QRTL < 5), aes(x = CPTCCS1, fill = ZIPINC_QRTL)) +
  geom_bar() +
  theme_classic() +
  xlab("Top 10 CCS Procedure Codes") +
  ggtitle("Most Common Ambulatory Surgery Encounters in NASS 2020 Dataset", subtitle = "Segmented by Median Income Quartile by Patient Zip code") +
  guides(fill = guide_legend(title = "Income Quartile"))

# FIGURE 2b: Top 10 Most Common Ambulatory Surgeries by Race
ggplot(subset(NASS_2020_TopCPT, RACE > 0 & RACE < 7), aes(x = CPTCCS1, fill = RACE)) +
  geom_bar() +
  theme_classic() +
  xlab("Top 10 CCS Procedure Codes") +
  ggtitle("Most Common Ambulatory Surgery Encounters in NASS 2020 Dataset", subtitle = "Segmented by Patient's Reported Race") +
  guides(fill = guide_legend(title = "Race")) +
  scale_fill_discrete(labels = race_labels)

# FIGURE 3a: Patient Age distributions by Urban-Rural class and US Region, segmented by Race
ggplot(subset(NASS_2020_all, FEMALE >= 0 & RACE > 0 & PL_NCHS > 0), aes(x = AGE, y = ..count..)) +
  geom_density(aes(fill = RACE), position = "stack") +
  theme_classic() +
  xlab("Age") +
  xlim(0, 100) +
  ggtitle("Patients within NASS 2020 Dataset", subtitle = "Age distributions by Urban-Rural Class & US Region, Segmented by Reported Race") +
  guides(fill = guide_legend(title = "Reported Race")) +
  scale_fill_discrete(labels = race_labels) +
  facet_grid(HOSP_REGION ~ PL_NCHS, labeller = labeller(HOSP_REGION = region_labels, PL_NCHS = pl_nchs_labels)) +
  theme(legend.position = "bottom")

# FIGURE 3b: Patient Age distributions by Urban-Rural class and US Region, segmented by Payer Status
ggplot(subset(NASS_2020_all, FEMALE >= 0 & PAY1 > 0 & PL_NCHS > 0), aes(x = AGE, y = ..count..)) +
  geom_density(aes(fill = PAY1), position = "stack") +
  theme_classic() +
  xlab("Age") +
  xlim(0, 100) +
  ggtitle("Patients within NASS 2020 Dataset", subtitle = "Age distributions by Urban-Rural Class & US Region, Segmented by Payer Status") +
  guides(fill = guide_legend(title = "Payer Status")) +
  scale_fill_discrete(labels = pay_labels) +
  facet_grid(HOSP_REGION ~ PL_NCHS, labeller = labeller(HOSP_REGION = region_labels, PL_NCHS = pl_nchs_labels)) +
  theme(legend.position = "bottom")

# FIGURE 7a: Patients by Age Group Segmented by Payer and Race
NASS_2020_all$AGEGRP <- cut(NASS_2020_all$AGE, breaks = c(0, 18, 65, 120), include.lowest = TRUE, right = FALSE)
ggplot(subset(NASS_2020_all, RACE > 0 & RACE < 7 & PAY1 > 0 & PAY1 < 7 & !is.na(AGEGRP)), aes(x = RACE, fill = PAY1)) +
  geom_bar(position = "fill") +
  theme_classic() +
  xlab("RACE") +
  ggtitle("Patients within NASS 2020 Dataset", subtitle = "By Age Group Segmented by Payer and Race") +
  guides(fill = guide_legend(title = "Payer")) +
  scale_fill_discrete(labels = pay_labels) +
  facet_grid(~ AGEGRP)



