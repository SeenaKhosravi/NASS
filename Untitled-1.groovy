R version 4.4.0 (2024-04-24 ucrt) -- "Puppy Cup"
Copyright (C) 2024 The R Foundation for Statistical Computing
Platform: x86_64-w64-mingw32/x64

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under certain conditions.
Type 'license()' or 'licence()' for distribution details.

  Natural language support but running in an English locale

R is a collaborative project with many contributors.
Type 'contributors()' for more information and
'citation()' on how to cite R or R packages in publications.

Type 'demo()' for some demos, 'help()' for on-line help, or
'help.start()' for an HTML browser interface to help.
Type 'q()' to quit R.

[Workspace loaded from ~/.RData]

> gc()
             used    (Mb) gc trigger    (Mb)   max used    (Mb)
Ncells     624702    33.4    1266011    67.7    1031109    55.1
Vcells 2776079346 21179.9 3616817454 27594.2 3009800825 22963.0
> ### agesociodiv.r
> 
> ### MIT License
> ### 
> ### Copyright (c) 2025 SgtKlinger
> ### 
> ### Permission is hereby granted, free of charge, to any person obtaining a copy
> ### of this software and associated documentation files (the "Software"), to deal
> ### in the Software without restriction, including without limitation the rights
> ### to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> ### copies of the Software, and to permit persons to whom the Software is
> ### furnished to do so, subject to the following conditions:
> ### 
> ### The above copyright notice and this permission notice shall be included in all
> ### copies or substantial portions of the Software.
> ### 
> ### THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> ### IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> ### FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> ### AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> ### LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> ### OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> ### SOFTWARE.
> 
> ### HCUP NASS 2020 Data Analysis - Age and Sociodemographic Diversity
> ### Author: Seena Khosravi
> ### Date: 2025-02-10
> 
> ### STATUS: Partially Tested
> 
> ### Description: This script analyzes the age and sociodemographic diversity
> ### of the HCUP NASS 2020 data.
> 
> YOUR_CENSUS_API_KEY <- "YOUR_CENSUS_API_KEY"  # Replace with your actual Census API key
> 
> ##########################
> # Setup
> ##########################
> 
> # Load required packages
> required_packages <- c("data.table", "dplyr", "survey", "tidyverse", "tidycensus", 
+                        "ggplot2", "gridExtra","caret", "randomForest", "pROC", "broom", "lme4")
> 
> # Function to check and install missing packages
> install_if_missing <- function(packages) {
+     new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
+     if(length(new_packages)) install.packages(new_packages)
+ }
> 
> # Function to load all required libraries
> load_libraries <- function(packages) {
+     lapply(packages, library, character.only = TRUE)
+ }
> 
> # Check and install missing packages, then load packages
> install_if_missing(required_packages)
> load_libraries(required_packages)
data.table 1.15.4 using 4 threads (see ?getDTthreads).  Latest news: r-datatable.com

Attaching package: ‘dplyr’

The following objects are masked from ‘package:data.table’:

    between, first, last

The following objects are masked from ‘package:stats’:

    filter, lag

The following objects are masked from ‘package:base’:

    intersect, setdiff, setequal, union

Loading required package: grid
Loading required package: Matrix
Loading required package: survival

Attaching package: ‘survey’

The following object is masked from ‘package:graphics’:

    dotchart

── Attaching core tidyverse packages ─────────────────────────────────────────────────────────────────────────────── tidyverse 2.0.0 ──
✔ forcats   1.0.0     ✔ readr     2.1.5
✔ ggplot2   3.5.1     ✔ stringr   1.5.1
✔ lubridate 1.9.3     ✔ tibble    3.2.1
✔ purrr     1.0.2     ✔ tidyr     1.3.1
── Conflicts ───────────────────────────────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::between()     masks data.table::between()
✖ tidyr::expand()      masks Matrix::expand()
✖ dplyr::filter()      masks stats::filter()
✖ dplyr::first()       masks data.table::first()
✖ lubridate::hour()    masks data.table::hour()
✖ lubridate::isoweek() masks data.table::isoweek()
✖ dplyr::lag()         masks stats::lag()
✖ dplyr::last()        masks data.table::last()
✖ lubridate::mday()    masks data.table::mday()
✖ lubridate::minute()  masks data.table::minute()
✖ lubridate::month()   masks data.table::month()
✖ tidyr::pack()        masks Matrix::pack()
✖ lubridate::quarter() masks data.table::quarter()
✖ lubridate::second()  masks data.table::second()
✖ purrr::transpose()   masks data.table::transpose()
✖ tidyr::unpack()      masks Matrix::unpack()
✖ lubridate::wday()    masks data.table::wday()
✖ lubridate::week()    masks data.table::week()
✖ lubridate::yday()    masks data.table::yday()
✖ lubridate::year()    masks data.table::year()
ℹ Use the conflicted package to force all conflicts to become errors

Attaching package: ‘gridExtra’

The following object is masked from ‘package:dplyr’:

    combine

Loading required package: lattice

Attaching package: ‘caret’

The following object is masked from ‘package:purrr’:

    lift

The following object is masked from ‘package:survival’:

    cluster

randomForest 4.7-1.2
Type rfNews() to see new features/changes/bug fixes.

Attaching package: ‘randomForest’

The following object is masked from ‘package:gridExtra’:

    combine

The following object is masked from ‘package:ggplot2’:

    margin

The following object is masked from ‘package:dplyr’:

    combine

Type 'citation("pROC")' for a citation.

Attaching package: ‘pROC’

The following objects are masked from ‘package:stats’:

    cov, smooth, var

[[1]]
[1] "data.table" "stats"      "graphics"   "grDevices"  "utils"      "datasets"   "methods"    "base"      

[[2]]
[1] "dplyr"      "data.table" "stats"      "graphics"   "grDevices"  "utils"      "datasets"   "methods"    "base"      

[[3]]
 [1] "survey"     "survival"   "Matrix"     "grid"       "dplyr"      "data.table" "stats"      "graphics"   "grDevices"  "utils"     
[11] "datasets"   "methods"    "base"      

[[4]]
 [1] "lubridate"  "forcats"    "stringr"    "purrr"      "readr"      "tidyr"      "tibble"     "ggplot2"    "tidyverse"  "survey"    
[11] "survival"   "Matrix"     "grid"       "dplyr"      "data.table" "stats"      "graphics"   "grDevices"  "utils"      "datasets"  
[21] "methods"    "base"      

[[5]]
 [1] "tidycensus" "lubridate"  "forcats"    "stringr"    "purrr"      "readr"      "tidyr"      "tibble"     "ggplot2"    "tidyverse" 
[11] "survey"     "survival"   "Matrix"     "grid"       "dplyr"      "data.table" "stats"      "graphics"   "grDevices"  "utils"     
[21] "datasets"   "methods"    "base"      

[[6]]
 [1] "tidycensus" "lubridate"  "forcats"    "stringr"    "purrr"      "readr"      "tidyr"      "tibble"     "ggplot2"    "tidyverse" 
[11] "survey"     "survival"   "Matrix"     "grid"       "dplyr"      "data.table" "stats"      "graphics"   "grDevices"  "utils"     
[21] "datasets"   "methods"    "base"      

[[7]]
 [1] "gridExtra"  "tidycensus" "lubridate"  "forcats"    "stringr"    "purrr"      "readr"      "tidyr"      "tibble"     "ggplot2"   
[11] "tidyverse"  "survey"     "survival"   "Matrix"     "grid"       "dplyr"      "data.table" "stats"      "graphics"   "grDevices" 
[21] "utils"      "datasets"   "methods"    "base"      

[[8]]
 [1] "caret"      "lattice"    "gridExtra"  "tidycensus" "lubridate"  "forcats"    "stringr"    "purrr"      "readr"      "tidyr"     
[11] "tibble"     "ggplot2"    "tidyverse"  "survey"     "survival"   "Matrix"     "grid"       "dplyr"      "data.table" "stats"     
[21] "graphics"   "grDevices"  "utils"      "datasets"   "methods"    "base"      

[[9]]
 [1] "randomForest" "caret"        "lattice"      "gridExtra"    "tidycensus"   "lubridate"    "forcats"      "stringr"     
 [9] "purrr"        "readr"        "tidyr"        "tibble"       "ggplot2"      "tidyverse"    "survey"       "survival"    
[17] "Matrix"       "grid"         "dplyr"        "data.table"   "stats"        "graphics"     "grDevices"    "utils"       
[25] "datasets"     "methods"      "base"        

[[10]]
 [1] "pROC"         "randomForest" "caret"        "lattice"      "gridExtra"    "tidycensus"   "lubridate"    "forcats"     
 [9] "stringr"      "purrr"        "readr"        "tidyr"        "tibble"       "ggplot2"      "tidyverse"    "survey"      
[17] "survival"     "Matrix"       "grid"         "dplyr"        "data.table"   "stats"        "graphics"     "grDevices"   
[25] "utils"        "datasets"     "methods"      "base"        

[[11]]
 [1] "broom"        "pROC"         "randomForest" "caret"        "lattice"      "gridExtra"    "tidycensus"   "lubridate"   
 [9] "forcats"      "stringr"      "purrr"        "readr"        "tidyr"        "tibble"       "ggplot2"      "tidyverse"   
[17] "survey"       "survival"     "Matrix"       "grid"         "dplyr"        "data.table"   "stats"        "graphics"    
[25] "grDevices"    "utils"        "datasets"     "methods"      "base"        

[[12]]
 [1] "lme4"         "broom"        "pROC"         "randomForest" "caret"        "lattice"      "gridExtra"    "tidycensus"  
 [9] "lubridate"    "forcats"      "stringr"      "purrr"        "readr"        "tidyr"        "tibble"       "ggplot2"     
[17] "tidyverse"    "survey"       "survival"     "Matrix"       "grid"         "dplyr"        "data.table"   "stats"       
[25] "graphics"     "grDevices"    "utils"        "datasets"     "methods"      "base"        

Warning messages:
1: package ‘survey’ was built under R version 4.4.2 
2: package ‘ggplot2’ was built under R version 4.4.2 
3: package ‘tidycensus’ was built under R version 4.4.2 
4: package ‘caret’ was built under R version 4.4.2 
5: package ‘randomForest’ was built under R version 4.4.2 
6: package ‘pROC’ was built under R version 4.4.2 
7: package ‘broom’ was built under R version 4.4.2 
> rm(required_packages, install_if_missing, load_libraries)
> 
> 
> # List of states included in NASS_2020_all
> states_in_nass <- c("Alaska", "California", "Colorado", "Connecticut", "District of Columbia", "Florida", "Georgia", "Hawaii", "Iowa",
+                     "Illinois", "Indiana", "Kansas", "Kentucky", "Maryland", "Maine", "Michigan", "Minnesota", "Missouri", "North Carolina",
+                     "North Dakota", "Nebraska", "New Jersey", "Nevada", "New York", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "South Carolina",
+                     "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Wisconsin")
> 
> # Import data for total population by state by age from the 2020 Census
> # U.S. Census Bureau, U.S. Department of Commerce. 
> # 2020 Decennial Census, DHC-A
> 
> # Define a function to construct population variables and labels based on the desired base variable
> # Base variable P12 for total, P12I for white alone, not Hispanic or Latino
> # See https://api.census.gov/data/2020/dec/dhc/groups.html for available groups
> 
> # Define a function to construct population variables and labels based on the desired base variable
> get_population_variables <- function(base_variable) {
+     variables <- paste0(base_variable, "_", sprintf("%03dN", 1:49))
+     
+     labels <- c(
+         "Total",
+         "Male: Total",
+         "Male: Under 5 years",
+         "Male: 5 to 9 years",
+         "Male: 10 to 14 years",
+         "Male: 15 to 17 years",
+         "Male: 18 and 19 years",
+         "Male: 20 years",
+         "Male: 21 years",
+         "Male: 22 to 24 years",
+         "Male: 25 to 29 years",
+         "Male: 30 to 34 years",
+         "Male: 35 to 39 years",
+         "Male: 40 to 44 years",
+         "Male: 45 to 49 years",
+         "Male: 50 to 54 years",
+         "Male: 55 to 59 years",
+         "Male: 60 and 61 years",
+         "Male: 62 to 64 years",
+         "Male: 65 and 66 years",
+         "Male: 67 to 69 years",
+         "Male: 70 to 74 years",
+         "Male: 75 to 79 years",
+         "Male: 80 to 84 years",
+         "Male: 85 years and over",
+         "Female: Total",
+         "Female: Under 5 years",
+         "Female: 5 to 9 years",
+         "Female: 10 to 14 years",
+         "Female: 15 to 17 years",
+         "Female: 18 and 19 years",
+         "Female: 20 years",
+         "Female: 21 years",
+         "Female: 22 to 24 years",
+         "Female: 25 to 29 years",
+         "Female: 30 to 34 years",
+         "Female: 35 to 39 years",
+         "Female: 40 to 44 years",
+         "Female: 45 to 49 years",
+         "Female: 50 to 54 years",
+         "Female: 55 to 59 years",
+         "Female: 60 and 61 years",
+         "Female: 62 to 64 years",
+         "Female: 65 and 66 years",
+         "Female: 67 to 69 years",
+         "Female: 70 to 74 years",
+         "Female: 75 to 79 years",
+         "Female: 80 to 84 years",
+         "Female: 85 years and over"
+     )
+     
+     names(labels) <- variables
+     labels <- as.character(labels)
+     
+     return(list(variables = variables, labels = labels))
+ }
> 
> # Function to get population data by state, age, and gender from the 2020 Census DHC file
> get_population_data <- function(variables, labels) {
+     population_data <- get_decennial(
+         geography = "state",
+         variables = variables,
+         year = 2020,
+         sumfile = "dhc"
+     )
+     
+     # Replace variable codes with labels
+     population_data <- population_data %>% 
+         mutate(variable = recode(variable, !!!setNames(labels, variables)))
+     
+     # Reshape the data for better analysis
+     population_data <- population_data %>% 
+         pivot_wider(names_from = variable, values_from = value)
+     
+     return(population_data)
+ }
> 
> # Make total all vars for query 
> population_info <- get_population_variables("P12")
> 
> # Get the total population data by state, age, and gender
> total_population_by_age_gender <- get_population_data(population_info$variables, population_info$labels)
Getting data from the 2020 decennial Census
Using the Demographic and Housing Characteristics File
Using the Demographic and Housing Characteristics File
Note: 2020 decennial Census data use differential privacy, a technique that
introduces errors into data to preserve respondent confidentiality.
ℹ Small counts should be interpreted with caution.
ℹ See https://www.census.gov/library/fact-sheets/2021/protecting-the-confidentiality-of-the-2020-census-redistricting-data.html for additional guidance.
This message is displayed once per session.
> 
> # Make total white alone vars for query
> population_info_w <- get_population_variables("P12I")
> 
> # Get the total population data by state, age, and gender
> total_population_by_age_gender_white <- get_population_data(population_info_w$variables, population_info_w$labels)
Getting data from the 2020 decennial Census
Using the Demographic and Housing Characteristics File
Using the Demographic and Housing Characteristics File
> 
> ########################################
> # Stage 1a 
> # Unadjusted proportion of White individuals in the NASS 2020 data
> # Reference value for White Only, (Not Hispanic or Latino) proportion for the whole US from the 2020 US Census
> ########################################
> 
> # Create a dummy variable WHITE which is 1 when RACE = 1, and 0 otherwise
> NASS_2020_all[, WHITE := ifelse(RACE == 1, 1, 0)]
> 
> # Calculate the unadjusted proportion of WHITE
> unadjusted_proportion_white <- mean(NASS_2020_all$WHITE)
> print(paste("Unadjusted proportion of WHITE:", unadjusted_proportion_white))
[1] "Unadjusted proportion of WHITE: 0.721083861012147"
> 
> # Reference value for White Only proportion for the whole US from the 2020 US Census
> us_census_white_proportion <- sum(total_population_by_age_gender_white$Total) / sum(total_population_by_age_gender$Total)
> print(paste("US Census White Only proportion:", us_census_white_proportion))
[1] "US Census White Only proportion: 0.572757871816601"
> 
> # Perform a simple statistical test for the unadjusted proportion
> unadjusted_test <- prop.test(sum(NASS_2020_all$WHITE), nrow(NASS_2020_all), p = us_census_white_proportion)
> print(unadjusted_test)

	1-sample proportions test with continuity correction

data:  sum(NASS_2020_all$WHITE) out of nrow(NASS_2020_all), null probability us_census_white_proportion
X-squared = 703813, df = 1, p-value < 2.2e-16
alternative hypothesis: true p is not equal to 0.5727579
95 percent confidence interval:
 0.7207695 0.7213980
sample estimates:
        p 
0.7210839 

> 
> 
> ########################################
> # Stage 1b
> # Weighted proportion of White individuals in the NASS 2020 data set
> # Reference value for White Only, (Not Hispanic or Latino) proportion for 
> # only NASS included states from the 2020 US Census
> ########################################
> 
> # Filter the census data for the states included in NASS
> filtered_total_population <- total_population_by_age_gender %>% 
+     filter(NAME %in% states_in_nass)
> 
> filtered_white_population <- total_population_by_age_gender_white %>% 
+     filter(NAME %in% states_in_nass)
> 
> # Calculate the total population and the total white population for these states
> total_population_nass_states <- sum(filtered_total_population$Total, na.rm = TRUE)
> total_white_population_nass_states <- sum(filtered_white_population$Total, na.rm = TRUE)
> 
> # Calculate the true proportion of white individuals for these states
> true_proportion_white_nass_states <- total_white_population_nass_states / total_population_nass_states
> print(paste("True proportion of WHITE in NASS states:", true_proportion_white_nass_states))
[1] "True proportion of WHITE in NASS states: 0.568354436990255"
> 
> # Calculate the weighted proportion of WHITE in NASS_2020_ALL using DISCWT
> weighted_proportion_white <- svymean(~WHITE, design = svydesign(ids = ~KEY_NASS, weights = ~DISCWT, data = NASS_2020_all))
> print(paste("Weighted proportion of WHITE in NASS 2020:", coef(weighted_proportion_white)))
[1] "Weighted proportion of WHITE in NASS 2020: 0.715839589166331"
> 
> # Perform a simple statistical test for the weighted proportion
> weighted_test <- svyttest(WHITE ~ 1, design = svydesign(ids = ~KEY_NASS, weights = ~DISCWT, data = NASS_2020_all), mu = true_proportion_white_nass_states)
> print(weighted_test)

	Design-based one-sample t-test

data:  WHITE ~ 1
t = 4317, df = 7828308, p-value < 2.2e-16
alternative hypothesis: true mean is not equal to 0
95 percent confidence interval:
 0.7155146 0.7161646
sample estimates:
     mean 
0.7158396 

> 
> ########################################
> # Stage 2 Analysis
> # Break down the NASS 2020 data by age group, and compare the proportions of white individuals
> # at each age, by gender. Show counts in NASS, and run a statistical test at each age bracket to 
> # determine if the NASS proportion of white individuals is significantly different from the Census proportion
> ########################################
> 
> # Define age groups and their corresponding breaks
> age_breaks <- c(-Inf, 4, 9, 14, 17, 19, 20, 21, 24, 29, 34, 39, 44, 49, 54, 59, 61, 64, 66, 69, 74, 79, 84, Inf)
> age_labels <- c("Under 5 years", "5 to 9 years", "10 to 14 years", "15 to 17 years", "18 and 19 years",
+                 "20 years", "21 years", "22 to 24 years", "25 to 29 years", "30 to 34 years",
+                 "35 to 39 years", "40 to 44 years", "45 to 49 years", "50 to 54 years", "55 to 59 years",
+                 "60 and 61 years", "62 to 64 years", "65 and 66 years", "67 to 69 years", "70 to 74 years",
+                 "75 to 79 years", "80 to 84 years", "85 years and over")
> 
> # Create age group variable in NASS dataset
> NASS_2020_all <- NASS_2020_all %>% 
+     mutate(AGE_GROUP = cut(AGE, breaks = age_breaks, labels = age_labels, right = TRUE))
> 
> # Calculate proportions for NASS_2020_all with confidence intervals
> nass_proportions <- NASS_2020_all %>% 
+     mutate(GENDER = ifelse(FEMALE == 0, "Male", "Female")) %>% 
+     group_by(AGE_GROUP, GENDER) %>% 
+     summarize(
+         total = n(),
+         white = sum(WHITE),
+         proportion_white = white / total,
+         ci_lower = proportion_white - 1.96 * sqrt((proportion_white * (1 - proportion_white)) / total),
+         ci_upper = proportion_white + 1.96 * sqrt((proportion_white * (1 - proportion_white)) / total),
+         .groups = 'drop'
+     ) %>% 
+     filter(!is.na(proportion_white))
> 
> # Calculate proportions for Census data
> census_proportions <- total_population_by_age_gender_white %>% 
+     select(NAME, starts_with("Male"), starts_with("Female")) %>% 
+     pivot_longer(cols = -NAME, names_to = "age_gender", values_to = "white_population") %>% 
+     separate(age_gender, into = c("gender", "age_group"), sep = ": ") %>% 
+     left_join(
+         total_population_by_age_gender %>% 
+             select(NAME, starts_with("Male"), starts_with("Female")) %>% 
+             pivot_longer(cols = -NAME, names_to = "age_gender", values_to = "total_population") %>% 
+             separate(age_gender, into = c("gender", "age_group"), sep = ": "),
+         by = c("NAME", "gender", "age_group")
+     ) %>% 
+     group_by(gender, age_group) %>% 
+     summarize(
+         total_population = sum(total_population, na.rm = TRUE),
+         white_population = sum(white_population, na.rm = TRUE),
+         proportion_white = white_population / total_population,
+         .groups = 'drop'
+     ) %>% 
+     filter(!is.na(age_group))
> 
> # Convert age groups to factors for proper plotting
> nass_proportions$AGE_GROUP <- factor(nass_proportions$AGE_GROUP, levels = age_labels)
> census_proportions$age_group <- factor(census_proportions$age_group, levels = age_labels)
> census_proportions <- census_proportions %>% filter(!is.na(age_group))
> 
> # Plot the trends for males
> plot_males <- ggplot() +
+     geom_line(data = nass_proportions %>% filter(GENDER == "Male"), aes(x = AGE_GROUP, y = proportion_white, color = "NASS", group = 1), linewidth = 1) +
+     geom_ribbon(data = nass_proportions %>% filter(GENDER == "Male"), aes(x = AGE_GROUP, ymin = ci_lower, ymax = ci_upper, fill = "CI", group = 1), alpha = 0.2) +
+     geom_line(data = census_proportions %>% filter(gender == "Male"), aes(x = age_group, y = proportion_white, color = "Census", group = 1), linewidth = 1) +
+     labs(title = "Proportion of White Individuals by Age Group (Males)",
+          x = "Age Group",
+          y = "Proportion White") +
+     theme_minimal() +
+     theme(axis.text.x = element_text(angle = 45, hjust = 1),
+           legend.title = element_blank(),
+           legend.position = "none") +
+     scale_y_continuous(limits = c(0, 1))
> 
> # Plot the trends for females
> plot_females <- ggplot() +
+     geom_line(data = nass_proportions %>% filter(GENDER == "Female"), aes(x = AGE_GROUP, y = proportion_white, color = "NASS", group = 1), linewidth = 1) +
+     geom_ribbon(data = nass_proportions %>% filter(GENDER == "Female"), aes(x = AGE_GROUP, ymin = ci_lower, ymax = ci_upper, fill = "CI", group = 1), alpha = 0.2) +
+     geom_line(data = census_proportions %>% filter(gender == "Female"), aes(x = age_group, y = proportion_white, color = "Census", group = 1), linewidth = 1) +
+     labs(title = "Proportion of White Individuals by Age Group (Females)",
+          x = "Age Group",
+          y = "Proportion White") +
+     theme_minimal() +
+     theme(axis.text.x = element_text(angle = 45, hjust = 1),
+           legend.title = element_blank(),
+           legend.position = "right") +
+     scale_y_continuous(limits = c(0, 1))
> 
> # Display the plots side by side
> grid.arrange(plot_males, plot_females, ncol = 2)
> 
> # Create a table of counts in NASS by age bracket
> nass_counts <- NASS_2020_all %>%
+     group_by(AGE_GROUP) %>%
+     summarize(count = n(), .groups = 'drop')
> 
> # Run a statistical test at each age bracket to determine if the NASS proportion of white individuals is truly different from the Census proportion
> test_results <- nass_proportions %>%
+     left_join(census_proportions, by = c("AGE_GROUP" = "age_group", "GENDER" = "gender")) %>%
+     mutate(
+         white_nass = white,
+         total_nass = total,
+         white_census = white_population,
+         total_census = total_population
+     ) %>%
+     group_by(AGE_GROUP, GENDER) %>%
+     do(tidy(prop.test(.$white_nass, .$total_nass, p = .$proportion_white))) %>%
+     ungroup() %>%
+     select(AGE_GROUP, GENDER, p.value)
There were 46 warnings (use warnings() to see them)
> 
> # Combine the counts and test results into a single table
> results_table <- nass_counts %>%
+     left_join(test_results, by = "AGE_GROUP") %>%
+     pivot_wider(names_from = GENDER, values_from = c(count, p.value))
> 
> # Print the results table
> print(results_table)
# A tibble: 23 × 5
   AGE_GROUP       count_Female count_Male p.value_Female p.value_Male
   <fct>                  <int>      <int>          <dbl>        <dbl>
 1 Under 5 years         249386     249386              0    0        
 2 5 to 9 years          151789     151789              0    0        
 3 10 to 14 years        140684     140684              0    0        
 4 15 to 17 years        135387     135387              0    0        
 5 18 and 19 years        91765      91765              0    0        
 6 20 years               41189      41189              0    2.15e-295
 7 21 years               41204      41204              0    6.76e-300
 8 22 to 24 years        149953     149953              0    0        
 9 25 to 29 years        287011     287011              0    0        
10 30 to 34 years        357173     357173              0    0        
# ℹ 13 more rows
# ℹ Use `print(n = ...)` to see more rows
> 
> ########################################
> # Stage 3
> # Create multi-level models to predict if a nASS encounter is white
> # nested modesl will be to compare effects of different factors
> # such as socioeconomics, geography, and clinical factors. Models will be built by AGE_GROUP
> ########################################
> 
> # Select relevant features and the target variable
> features <- NASS_2020_all %>%
+     select(AGE_GROUP, FEMALE, ZIPINC_QRTL, PAY1, DISPUNIFORM, WHITE, CPTCCS1, HOSP_REGION, HOSP_LOCATION, HOSP_TEACH, HOSP_NASS, TOTAL_AS_ENCOUNTERS, PL_NCHS)
> 
> # Convert categorical variables to factors
> features <- features %>%
+     mutate(
+         AGE_GROUP = as.factor(AGE_GROUP),
+         FEMALE = as.factor(FEMALE),
+         ZIPINC_QRTL = as.factor(ZIPINC_QRTL),
+         PAY1 = as.factor(PAY1),
+         DISPUNIFORM = as.factor(DISPUNIFORM),
+         CPTCCS1 = as.factor(CPTCCS1),
+         HOSP_REGION = as.factor(HOSP_REGION),
+         HOSP_LOCATION = as.factor(HOSP_LOCATION),
+         HOSP_TEACH = as.factor(HOSP_TEACH),
+         HOSP_NASS = as.factor(HOSP_NASS),
+         PL_NCHS = as.factor(PL_NCHS),
+         WHITE = as.factor(WHITE)
+     )
> 
> # Split the data by AGE_GROUP
> age_groups <- unique(features$AGE_GROUP)
> results <- list()
> 
> for (age_group in age_groups) {
+     cat("Processing age group:", age_group, "\n")
+     
+     # Filter data for the current age group
+     age_group_data <- features %>% filter(AGE_GROUP == age_group)
+     
+     # Split the data into training and testing sets
+     set.seed(123)  # For reproducibility
+     train_index <- createDataPartition(age_group_data$WHITE, p = 0.8, list = FALSE)
+     train_data <- age_group_data[train_index, ]
+     test_data <- age_group_data[-train_index, ]
+     
+     # Define models
+     models <- list(
+         model1 = "WHITE ~ FEMALE + (1 | HOSP_NASS)",
+         model2 = "WHITE ~ FEMALE + ZIPINC_QRTL + (1 | HOSP_NASS)",
+         model3 = "WHITE ~ FEMALE + ZIPINC_QRTL + PAY1 + (1 | HOSP_NASS)",
+         model4 = "WHITE ~ FEMALE + ZIPINC_QRTL + PAY1 + DISPUNIFORM + (1 | HOSP_NASS)",
+         model5 = "WHITE ~ FEMALE + ZIPINC_QRTL + PAY1 + DISPUNIFORM + CPTCCS1 + (1 | HOSP_NASS)",
+         model6 = "WHITE ~ FEMALE + ZIPINC_QRTL + PAY1 + DISPUNIFORM + CPTCCS1 + HOSP_LOCATION + (1 | HOSP_NASS)",
+         model7 = "WHITE ~ FEMALE + ZIPINC_QRTL + PAY1 + DISPUNIFORM + CPTCCS1 + HOSP_LOCATION + HOSP_TEACH + (1 | HOSP_NASS)",
+         model8 = "WHITE ~ FEMALE + ZIPINC_QRTL + PAY1 + DISPUNIFORM + CPTCCS1 + HOSP_LOCATION + HOSP_TEACH + TOTAL_AS_ENCOUNTERS + (1 | HOSP_NASS)",
+         model9 = "WHITE ~ FEMALE + ZIPINC_QRTL + PAY1 + DISPUNIFORM + CPTCCS1 + HOSP_LOCATION + HOSP_TEACH + TOTAL_AS_ENCOUNTERS + PL_NCHS + (1 | HOSP_NASS) + (1 | HOSP_REGION)"
+     )
+     
+     # Train models and generate ROC curves
+     roc_curves <- list()
+     for (i in seq_along(models)) {
+         model_formula <- as.formula(models[[i]])
+         model <- glmer(model_formula, data = train_data, family = binomial)
+         predictions <- predict(model, test_data, type = "response")
+         roc_curve <- roc(test_data$WHITE, predictions)
+         roc_curves[[i]] <- roc_curve
+         print(paste("Age Group:", age_group, "Model", i, "AUC:", auc(roc_curve)))
+     }
+     
+     # Store results for the current age group
+     results[[as.character(age_group)]] <- list(
+         roc_curves = roc_curves,
+         best_model_index = which.max(sapply(roc_curves, auc)),
+         best_model = glmer(as.formula(models[[which.max(sapply(roc_curves, auc))]]), data = train_data, family = binomial)
+     )
+ }
Processing age group: 35 to 39 years 
Error in levelfun(r, n, allow.new.levels = allow.new.levels) : 
  new levels detected in newdata: 10074, 20624, 21117, 30989
In addition: Warning messages:
1: In checkConv(attr(opt, "derivs"), opt$par, ctrl = control$checkConv,  :
  unable to evaluate scaled gradient
2: In checkConv(attr(opt, "derivs"), opt$par, ctrl = control$checkConv,  :
  Model failed to converge: degenerate  Hessian with 1 negative eigenvalues
> View(age_group_data)
> gc()
             used    (Mb) gc trigger    (Mb)   max used    (Mb)
Ncells    3547014   189.5   39812545  2126.3   49765681  2657.8
Vcells 2868544660 21885.3 4340260944 33113.6 4338288855 33098.6
> # Convert categorical variables to factors
> features <- features %>%
+     mutate(
+         AGE_GROUP = as.factor(AGE_GROUP),
+         FEMALE = as.factor(FEMALE),
+         ZIPINC_QRTL = as.factor(ZIPINC_QRTL),
+         PAY1 = as.factor(PAY1),
+         DISPUNIFORM = as.factor(DISPUNIFORM),
+         CPTCCS1 = as.factor(CPTCCS1),
+         HOSP_REGION = as.factor(HOSP_REGION),
+         HOSP_LOCATION = as.factor(HOSP_LOCATION),
+         HOSP_TEACH = as.factor(HOSP_TEACH),
+         HOSP_NASS = as.factor(HOSP_NASS),
+         PL_NCHS = as.factor(PL_NCHS),
+         WHITE = as.factor(WHITE)
+     )
> 
> # Split the data by AGE_GROUP
> age_groups <- unique(features$AGE_GROUP)
> results <- list()
> 
> for (age_group in age_groups) {
+     cat("Processing age group:", age_group, "\n")
+     
+     # Filter data for the current age group
+     age_group_data <- features %>% filter(AGE_GROUP == age_group)
+     
+     # Split the data into training and testing sets
+     set.seed(123)  # For reproducibility
+     train_index <- createDataPartition(age_group_data$WHITE, p = 0.8, list = FALSE)
+     train_data <- age_group_data[train_index, ]
+     test_data <- age_group_data[-train_index, ]
+     
+     # Ensure levels of categorical variables in test data match those in training data
+     for (col in names(train_data)) {
+         if (is.factor(train_data[[col]])) {
+             levels(test_data[[col]]) <- levels(train_data[[col]])
+         }
+     }
+     
+     # Define models
+     models <- list(
+         model1 = "WHITE ~ FEMALE + (1 | HOSP_NASS)",
+         model2 = "WHITE ~ FEMALE + ZIPINC_QRTL + (1 | HOSP_NASS)",
+         model3 = "WHITE ~ FEMALE + ZIPINC_QRTL + PAY1 + (1 | HOSP_NASS)",
+         model4 = "WHITE ~ FEMALE + ZIPINC_QRTL + PAY1 + DISPUNIFORM + (1 | HOSP_NASS)",
+         model5 = "WHITE ~ FEMALE + ZIPINC_QRTL + PAY1 + DISPUNIFORM + CPTCCS1 + (1 | HOSP_NASS)",
+         model6 = "WHITE ~ FEMALE + ZIPINC_QRTL + PAY1 + DISPUNIFORM + CPTCCS1 + HOSP_LOCATION + (1 | HOSP_NASS)",
+         model7 = "WHITE ~ FEMALE + ZIPINC_QRTL + PAY1 + DISPUNIFORM + CPTCCS1 + HOSP_LOCATION + HOSP_TEACH + (1 | HOSP_NASS)",
+         model8 = "WHITE ~ FEMALE + ZIPINC_QRTL + PAY1 + DISPUNIFORM + CPTCCS1 + HOSP_LOCATION + HOSP_TEACH + TOTAL_AS_ENCOUNTERS + (1 | HOSP_NASS)",
+         model9 = "WHITE ~ FEMALE + ZIPINC_QRTL + PAY1 + DISPUNIFORM + CPTCCS1 + HOSP_LOCATION + HOSP_TEACH + TOTAL_AS_ENCOUNTERS + PL_NCHS + (1 | HOSP_NASS) + (1 | HOSP_REGION)"
+     )
+     
+     # Train models and generate ROC curves
+     roc_curves <- list()
+     for (i in seq_along(models)) {
+         model_formula <- as.formula(models[[i]])
+         model <- glmer(model_formula, data = train_data, family = binomial)
+         predictions <- predict(model, test_data, type = "response", allow.new.levels = TRUE)
+         roc_curve <- roc(test_data$WHITE, predictions)
+         roc_curves[[i]] <- roc_curve
+         print(paste("Age Group:", age_group, "Model", i, "AUC:", auc(roc_curve)))
+     }
+     
+     # Store results for the current age group
+     results[[as.character(age_group)]] <- list(
+         roc_curves = roc_curves,
+         best_model_index = which.max(sapply(roc_curves, auc)),
+         best_model = glmer(as.formula(models[[which.max(sapply(roc_curves, auc))]]), data = train_data, family = binomial)
+     )
+ }
Processing age group: 35 to 39 years 
Setting levels: control = 0, case = 1
Setting direction: controls < cases
[1] "Age Group: 35 to 39 years Model 1 AUC: 0.778103142494419"
Setting levels: control = 0, case = 1
Setting direction: controls < cases
[1] "Age Group: 35 to 39 years Model 2 AUC: 0.794047653572344"
Warning messages:
1: In checkConv(attr(opt, "derivs"), opt$par, ctrl = control$checkConv,  :
  unable to evaluate scaled gradient
2: In checkConv(attr(opt, "derivs"), opt$par, ctrl = control$checkConv,  :
  Model failed to converge: degenerate  Hessian with 1 negative eigenvalues
3: In checkConv(attr(opt, "derivs"), opt$par, ctrl = control$checkConv,  :
  Model failed to converge with max|grad| = 0.002579 (tol = 0.002, component 1)
> 
> # Convert categorical variables to factors
> features <- features %>%
+     mutate(
+         AGE_GROUP = as.factor(AGE_GROUP),
+         FEMALE = as.factor(FEMALE),
+         ZIPINC_QRTL = as.factor(ZIPINC_QRTL),
+         PAY1 = as.factor(PAY1),
+         DISPUNIFORM = as.factor(DISPUNIFORM),
+         CPTCCS1 = as.factor(CPTCCS1),
+         HOSP_REGION = as.factor(HOSP_REGION),
+         HOSP_LOCATION = as.factor(HOSP_LOCATION),
+         HOSP_TEACH = as.factor(HOSP_TEACH),
+         HOSP_NASS = as.factor(HOSP_NASS),
+         PL_NCHS = as.factor(PL_NCHS),
+         WHITE = as.factor(WHITE)
+     )
> 
> # Define models
> models <- list(
+     model1 = "WHITE ~ FEMALE + (1 | HOSP_NASS)",
+     model2 = "WHITE ~ FEMALE + ZIPINC_QRTL + (1 | HOSP_NASS)",
+     model3 = "WHITE ~ FEMALE + ZIPINC_QRTL + PAY1 + (1 | HOSP_NASS)",
+     model4 = "WHITE ~ FEMALE + ZIPINC_QRTL + PAY1 + DISPUNIFORM + (1 | HOSP_NASS)",
+     model5 = "WHITE ~ FEMALE + ZIPINC_QRTL + PAY1 + DISPUNIFORM + CPTCCS1 + (1 | HOSP_NASS)",
+     model6 = "WHITE ~ FEMALE + ZIPINC_QRTL + PAY1 + DISPUNIFORM + CPTCCS1 + HOSP_LOCATION + (1 | HOSP_NASS)",
+     model7 = "WHITE ~ FEMALE + ZIPINC_QRTL + PAY1 + DISPUNIFORM + CPTCCS1 + HOSP_LOCATION + HOSP_TEACH + (1 | HOSP_NASS)",
+     model8 = "WHITE ~ FEMALE + ZIPINC_QRTL + PAY1 + DISPUNIFORM + CPTCCS1 + HOSP_LOCATION + HOSP_TEACH + TOTAL_AS_ENCOUNTERS + (1 | HOSP_NASS)",
+     model9 = "WHITE ~ FEMALE + ZIPINC_QRTL + PAY1 + DISPUNIFORM + CPTCCS1 + HOSP_LOCATION + HOSP_TEACH + TOTAL_AS_ENCOUNTERS + PL_NCHS + (1 | HOSP_NASS) + (1 | HOSP_REGION)"
+ )
> 
> # Split the data by AGE_GROUP
> age_groups <- unique(features$AGE_GROUP)
> results <- list()
> 
> # Function to save intermediate results
> save_results <- function(results, filename) {
+     saveRDS(results, file = filename)
+ }
> 
> # Iterate over models
> for (model_index in seq_along(models)) {
+     cat("Processing model:", model_index, "\n")
+     
+     # Iterate over age groups
+     for (age_group in age_groups) {
+         cat("Processing age group:", age_group, "\n")
+         
+         # Filter data for the current age group
+         age_group_data <- features %>% filter(AGE_GROUP == age_group)
+         
+         # Split the data into training and testing sets
+         set.seed(123)  # For reproducibility
+         train_index <- createDataPartition(age_group_data$WHITE, p = 0.8, list = FALSE)
+         train_data <- age_group_data[train_index, ]
+         test_data <- age_group_data[-train_index, ]
+         
+         # Ensure levels of categorical variables in test data match those in training data
+         for (col in names(train_data)) {
+             if (is.factor(train_data[[col]])) {
+                 levels(test_data[[col]]) <- levels(train_data[[col]])
+             }
+         }
+         
+         # Define the current model formula
+         model_formula <- as.formula(models[[model_index]])
+         
+         # Train the model
+         model <- glmer(model_formula, data = train_data, family = binomial)
+         
+         # Make predictions on the test data
+         predictions <- predict(model, test_data, type = "response", allow.new.levels = TRUE)
+         
+         # Generate ROC curve
+         roc_curve <- roc(test_data$WHITE, predictions)
+         
+         # Store results for the current age group and model
+         if (!is.list(results[[as.character(age_group)]])) {
+             results[[as.character(age_group)]] <- list()
+         }
+         results[[as.character(age_group)]][[paste0("model", model_index)]] <- list(
+             roc_curve = roc_curve,
+             model = model
+         )
+         
+         # Save intermediate results
+         save_results(results, "intermediate_results.rds")
+         
+         # Print AUC
+         print(paste("Age Group:", age_group, "Model", model_index, "AUC:", auc(roc_curve)))
+     }
+ }
Processing model: 1 
Processing age group: 35 to 39 years 
Setting levels: control = 0, case = 1
Setting direction: controls < cases
[1] "Age Group: 35 to 39 years Model 1 AUC: 0.778103142494419"
Processing age group: 65 and 66 years 
Setting levels: control = 0, case = 1
Setting direction: controls < cases
[1] "Age Group: 65 and 66 years Model 1 AUC: 0.798113419388381"
Processing age group: 40 to 44 years 
Setting levels: control = 0, case = 1
Setting direction: controls < cases
[1] "Age Group: 40 to 44 years Model 1 AUC: 0.782259404475769"
Processing age group: 50 to 54 years 
Setting levels: control = 0, case = 1
Setting direction: controls < cases
[1] "Age Group: 50 to 54 years Model 1 AUC: 0.783470597798419"
Processing age group: 22 to 24 years 
Setting levels: control = 0, case = 1
Setting direction: controls < cases
[1] "Age Group: 22 to 24 years Model 1 AUC: 0.759480834160953"
Processing age group: 75 to 79 years 
Setting levels: control = 0, case = 1
Setting direction: controls < cases
[1] "Age Group: 75 to 79 years Model 1 AUC: 0.810335800385898"
Processing age group: 70 to 74 years 
Setting levels: control = 0, case = 1
Setting direction: controls < cases
[1] "Age Group: 70 to 74 years Model 1 AUC: 0.804028783693083"
Processing age group: 45 to 49 years 
Setting levels: control = 0, case = 1
Setting direction: controls < cases
[1] "Age Group: 45 to 49 years Model 1 AUC: 0.781642772457027"
Processing age group: 55 to 59 years 
Setting levels: control = 0, case = 1
Setting direction: controls < cases
[1] "Age Group: 55 to 59 years Model 1 AUC: 0.786541616276672"
Processing age group: 15 to 17 years 
Setting levels: control = 0, case = 1
Setting direction: controls < cases
[1] "Age Group: 15 to 17 years Model 1 AUC: 0.77151124874161"
Processing age group: 5 to 9 years 
Setting levels: control = 0, case = 1
Setting direction: controls < cases
[1] "Age Group: 5 to 9 years Model 1 AUC: 0.777867347240955"
Processing age group: 25 to 29 years 
Setting levels: control = 0, case = 1
Setting direction: controls < cases
[1] "Age Group: 25 to 29 years Model 1 AUC: 0.771648693625494"
Processing age group: 30 to 34 years 
Setting levels: control = 0, case = 1
Setting direction: controls < cases
[1] "Age Group: 30 to 34 years Model 1 AUC: 0.776211856364787"
Processing age group: 80 to 84 years 
Setting levels: control = 0, case = 1
Setting direction: controls < cases
[1] "Age Group: 80 to 84 years Model 1 AUC: 0.817698440805588"
Processing age group: 62 to 64 years 
Setting levels: control = 0, case = 1
Setting direction: controls < cases
[1] "Age Group: 62 to 64 years Model 1 AUC: 0.791084480398123"
Processing age group: 20 years 
Setting levels: control = 0, case = 1
Setting direction: controls < cases
[1] "Age Group: 20 years Model 1 AUC: 0.735551462175614"
Processing age group: 67 to 69 years 
Setting levels: control = 0, case = 1
Setting direction: controls < cases
[1] "Age Group: 67 to 69 years Model 1 AUC: 0.797464792933271"
Processing age group: 21 years 
Setting levels: control = 0, case = 1
Setting direction: controls < cases
[1] "Age Group: 21 years Model 1 AUC: 0.745780436762893"
Processing age group: 10 to 14 years 