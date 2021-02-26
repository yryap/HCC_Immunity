# Set working directory

# Import TCGA data, need viral status and HLA alleles
total_hepB_nonhepB <- read.table("tcga_popinf_ancestry.txt", header = TRUE, sep = "\t")
mod_total_hepB_nonhepB <- as.data.frame(sapply(total_hepB_nonhepB, function(x) sub(":", "-", x)))


# Create new table for easy comparison side by side
# HLA A dataframe for each allele

hla_dp_total_hepB_nonhepB <- mod_total_hepB_nonhepB[c(1:6, 14:17)]

# Modify to remove hyphens
hla_dp_total_hepB_nonhepB$hla_dpa1_1 <- sub("-", "", hla_dp_total_hepB_nonhepB$hla_dpa1_1)
hla_dp_total_hepB_nonhepB$hla_dpa1_2 <- sub("-", "", hla_dp_total_hepB_nonhepB$hla_dpa1_2)
hla_dp_total_hepB_nonhepB$hla_dpb1_1 <- sub("-", "", hla_dp_total_hepB_nonhepB$hla_dpb1_1)
hla_dp_total_hepB_nonhepB$hla_dpb1_2 <- sub("-", "", hla_dp_total_hepB_nonhepB$hla_dpb1_2)

# Need to first create new columns to store combined DPA and DPB
hla_dp_total_hepB_nonhepB$combined_dpa1_dpb1 <- paste0("DPA1",hla_dp_total_hepB_nonhepB$hla_dpa1_1,"-DPB1",hla_dp_total_hepB_nonhepB$hla_dpb1_1 )
hla_dp_total_hepB_nonhepB$combined_dpa1_dpb2 <- paste0("DPA1",hla_dp_total_hepB_nonhepB$hla_dpa1_1,"-DPB1",hla_dp_total_hepB_nonhepB$hla_dpb1_2 )

hla_dp_total_hepB_nonhepB$combined_dpa2_dpb1 <- paste0("DPA1",hla_dp_total_hepB_nonhepB$hla_dpa1_2,"-DPB1",hla_dp_total_hepB_nonhepB$hla_dpb1_1 )

hla_dp_total_hepB_nonhepB$combined_dpa2_dpb2 <- paste0("DPA1",hla_dp_total_hepB_nonhepB$hla_dpa1_2,"-DPB1",hla_dp_total_hepB_nonhepB$hla_dpb1_2 )

# Add dp_score 
hla_dp_total_hepB_nonhepB$dp_score <- 0

# Find unique pairs
combined_hla_dp <- c(as.character(hla_dp_total_hepB_nonhepB$combined_dpa1_dpb1),
                     as.character(hla_dp_total_hepB_nonhepB$combined_dpa1_dpb2),
                     as.character(hla_dp_total_hepB_nonhepB$combined_dpa2_dpb1),
                     as.character(hla_dp_total_hepB_nonhepB$combined_dpa2_dpb2))

sorted_table_hla_dp <- sort(table(combined_hla_dp), decreasing = TRUE)

# Unique DP allele pairs names
names_sorted_table_hla_dp <- names(sorted_table_hla_dp)

{r HLA-DP Allele List with dataframe}
# HLA-DP dataframe for each allele
hla_dp_allele_table <- list()

for(i in 1:length(names_sorted_table_hla_dp)){
  hla_dp_allele_table[[i]] <- hla_dp_total_hepB_nonhepB
}

# Assign names to each list
names(hla_dp_allele_table) <- names_sorted_table_hla_dp

# In each list, fill the table
for(i in 1:length(hla_dp_allele_table)){
  for (j in 1:346){
    if(isTRUE(hla_dp_allele_table[[i]][[11]][[j]] == names(hla_dp_allele_table)[[i]]) | isTRUE(hla_dp_allele_table[[i]][[12]][[j]] == names(hla_dp_allele_table)[[i]]) | isTRUE(hla_dp_allele_table[[i]][[13]][[j]] == names(hla_dp_allele_table)[[i]]) | isTRUE(hla_dp_allele_table[[i]][[14]][[j]] == names(hla_dp_allele_table)[[i]])){
      hla_dp_allele_table[[i]][[15]][[j]] <- 1
    } else {
      hla_dp_allele_table[[i]][[15]][[j]] <- 0
    }
  }
}

{r HLA-DP Fishers }

# 1) Nonviral & Allele present
nonhepB_dp <- lapply(hla_dp_allele_table, function(x) nrow(subset(x, x$hepB == "No" & x$dp_score == "1")))

# 2) Nonviral & Allele absent
nonhepB_xdp <- lapply(hla_dp_allele_table, function(x) nrow(subset(x, x$hepB == "No" & x$dp_score == "0")))

# 3) Viral & Allele present
hepB_dp <- lapply(hla_dp_allele_table, function(x) nrow(subset(x, x$hepB == "Yes" & x$dp_score == "1")))

# 4) Viral & Allele absent
hepB_xdp <- lapply(hla_dp_allele_table, function(x) nrow(subset(x, x$hepB == "Yes" & x$dp_score == "0")))


# HLA-DP: Contingency table and Fisher tests -----
# Create a for loop to do the following:
# 1. Fill in template table using the information from lists
# 2. Perform Fisher test
# 3. Perform chisq test, set correction to FALSE to check if Cochran's rules were met

# Calculate the expected values
alt_expected_dp <- list()
alt_expected_dp_table <- list()

# Create lists to store statistic test results from the for loop below
dp_list_fisher <- list()
dp_table_list <- list()

for (i in 1:length(hepB_dp)){
  
  # Create empty tables in the list
  dp_table_list[[i]] <- matrix(c(0,0,0,0), ncol = 2, byrow = TRUE)
  colnames(dp_table_list[[i]]) <- c("allele present", "allele absent")
  rownames(dp_table_list[[i]]) <- c("hepB", "non-hepB")
  
  # Fill out the empty tables
  dp_table_list[[i]][1,1] <- hepB_dp[[i]]
  dp_table_list[[i]][1,2] <- hepB_xdp[[i]]
  dp_table_list[[i]][2,1] <- nonhepB_dp[[i]]
  dp_table_list[[i]][2,2] <- nonhepB_xdp[[i]]
  
  # Calculate the expected values
  alt_expected_dp[[i]] <- chisq.test(dp_table_list[[i]])
  alt_expected_dp_table[[i]] <- alt_expected_dp[[i]]$expected
  
  # Fisher test
  dp_list_fisher[[i]] <- fisher.test(dp_table_list[[i]])
  
}

# Rename the values in lists to reflect the actual allele names
names(dp_table_list) <- names_sorted_table_hla_dp
names(dp_list_fisher) <- names_sorted_table_hla_dp

# HLA-DP: Multiple correction testing
# Benjamini-Hochberg 

# Get the Fisher p values for all alleles
dp_fisher_p <- sapply(dp_list_fisher, function(x) x[["p.value"]])
dp_fisher_p <- as.data.frame(dp_fisher_p)

# Benjamini-Hochberg correction
dp_fisher_p$BH_correction <- p.adjust(dp_fisher_p$dp_fisher_p, method = "BH", n = length(dp_fisher_p$dp_fisher_p))

# Get the odds ratio for alleles
dp_fisher_p$odds_ratio <- sapply(dp_list_fisher, function(x) x[["estimate"]])

filtered_fisher_p <- dp_fisher_p[dp_fisher_p$BH_correction < 0.05, ]

