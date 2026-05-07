# Data Documentation & Licensing

## Data Source

This project uses the **China General Social Survey (CGSS) 2006** microdata.

### Original Data

**Survey:** China General Social Survey (CGSS) 2006  
**Provider:** Research Center for Sociology, Renmin University of China  
**Website:** [http://www.chinagss.org](http://www.chinagss.org)  
**Sample Size:** ~3,000+ household observations  
**Method:** Stratified multi-stage sampling

## Obtaining the Data

### For Researchers

1. Visit the CGSS website: http://www.chinagss.org
2. Register as a researcher
3. Request access to the 2006 wave data
4. Accept the data use agreement and licensing terms
5. Download the dataset (typically provided in Stata or SPSS format)

### Data Licensing

The original CGSS data is **copyrighted** and not freely redistributable. Users must:

- Register with the CGSS data provider
- Agree to terms of use
- Acknowledge the CGSS in any publications using the data
- Not redistribute the raw data to third parties

**Citation requirement:**
> China General Social Survey (CGSS), Renmin University of China, [year]. 
> Accessed at http://www.chinagss.org

## Using the Repository

### Option 1: With Original Data (Recommended for Research)

If you have obtained the CGSS 2006 data:

```r
# 1. Place CGSS data file in Data/ directory
# 2. Load and prepare:

source("Deps.R")

# Load CGSS data
CGSS_data <- read.csv("Data/CGSS_2006.csv")
# or read.spss(), read.dta(), etc. depending on format

# 3. Run analysis scripts with original data
source("Examples/Example_Meritocracy.R")
```

### Option 2: With Synthetic Data (For Learning/Testing)

The repository includes a synthetic data generator that creates data mirroring the CGSS structure:

```r
source("Deps.R")
source("Examples/synthetic_data_generator.R")

# Run analysis with synthetic data
Data <- CGSS_synthetic

# Note: Results will differ from the original analysis,
# but the workflow and code structure is identical
```

**Advantages of synthetic data:**
- ✓ Freely distributable
- ✓ No licensing restrictions
- ✓ Useful for teaching and methodology demonstration
- ✓ Preserves variable correlations and distributions

**Limitations:**
- ✗ Not representative of actual Chinese population
- ✗ Results cannot be used for policy recommendations
- ✗ Magnitudes of effects are illustrative only

## Variable Guide

### Key Variables Used in Analysis

#### **Outcome Variables**

| Variable | Name | Type | Range | Description |
|----------|------|------|-------|-------------|
| `Migs` | Small-scale migration | Ordinal | 1-5 | Migration intention/behavior, short distance |
| `Migl` | Large-scale migration | Ordinal | 1-5 | Migration intention/behavior, long distance |
| `RP` | Redistribution preference | Ordinal | 1-5 | Preference for government redistribution |
| `FcM1` | Merit factor 1 | Continuous | 1-5 | Individual effort (talent, ambition, work ethic) |
| `FcM2` | Merit factor 2 | Continuous | 1-5 | Education & talent dimension |
| `FcAM` | Actual merit factors | Continuous | 1-5 | Non-meritocratic factors (networks, luck, family) |

#### **Environmental/Economic Variables**

| Variable | Name | Type | Range | Description |
|----------|------|------|-------|-------------|
| `water` | Water access | Ordinal | 1-5 | Quality of water access/supply |
| `flood` | Flood exposure | Ordinal | 1-5 | Exposure to flooding risk |
| `rev` | Revenue/economy | Ordinal | 1-5 | Local economic conditions |
| `Dif` | Income inequality | Ordinal | 1-5 | Perception of income differences |

#### **Demographic Variables**

| Variable | Name | Type | Range | Description |
|----------|------|------|-------|-------------|
| `age` | Age | Continuous | 18-85 | Respondent age in years |
| `age2` | Age squared | Continuous | - | Age² / 100 (for non-linear effects) |
| `female` | Gender | Binary | 0,1 | 1 = female, 0 = male |
| `Urb` | Urban | Binary | 0,1 | 1 = urban, 0 = rural |
| `Rur` | Rural | Binary | 0,1 | 1 = rural, 0 = urban |
| `yeduc` | Education years | Continuous | 0-20 | Years of formal education completed |

#### **Economic Variables**

| Variable | Name | Type | Range | Description |
|----------|------|------|-------|-------------|
| `Income` | Household income | Continuous | - | Annual household income (in log scale: `linc`) |
| `linc` | Log income | Continuous | - | Natural log of household income |
| `linc2` | Log income squared | Continuous | - | (linc)² |

#### **Belief & Political Variables**

| Variable | Name | Type | Range | Description |
|----------|------|------|-------|-------------|
| `party` | Party member | Binary | 0,1 | 1 = member, 0 = non-member |
| `believer` | Religious believer | Binary | 0,1 | 1 = believer, 0 = non-believer |

#### **Survey Design**

| Variable | Name | Type | Range | Description |
|----------|------|------|-------|-------------|
| `weight` | Sampling weight | Continuous | 0.1-3 | Survey weight (normalized, mean = 1) |
| `id` | Respondent ID | Integer | 1-n | Unique identifier |

### Sample Restriction

The analysis applies **equation-specific restrictions**:

- **Migs and Migl** (migration equations): Restricted to **rural respondents only** (`Urb == 0`)
  - Rationale: Urban residents cannot migrate (already living in cities)
  - Implemented via: `| subset(Urb == 0)` in formula

- **All other equations**: Include full sample with all respondents

### Missing Data

- **Original data:** Handled through complete-case analysis in 3SLS estimation
- **Synthetic data:** Generated without missing values for simplicity
- **Best practice:** Document all missing data mechanisms in real applications

#### Common sources of missingness:
- Refusal to answer (especially income, political affiliation)
- Item nonresponse (forgetting, inability to estimate)
- Implicit restrictions (e.g., Migs/Migl only for rural residents)

## Data Preparation Steps

### In the Example Script

The `Example_Meritocracy.R` performs:

1. **Variable transformation:**
   - Log transformation for income variables
   - Scaling of continuous variables
   - Construction of squared terms for age and income

2. **Merit index construction:**
   - Factor analysis on individual items (in real analysis)
   - Synthetic generation (in example)
   - Standardization to 1-5 scale

3. **Missing value handling:**
   - Complete-case analysis (rows with any NA removed)
   - Implicit restrictions (e.g., rural-only samples)
   - Survey weight application

4. **Data validation:**
   - Range checks (e.g., age 18-85)
   - Correlation verification
   - Summary statistics

## Replication with Original Data

### Step 1: Prepare CGSS Raw Data

```r
# Load raw CGSS 2006 data
CGSS_raw <- read.dta("CGSS2006_original.dta")

# Create dichotomous variables
CGSS_raw$female <- as.numeric(CGSS_raw$q_gender == 2)
CGSS_raw$Urb <- as.numeric(CGSS_raw$q_region_type == 1)
CGSS_raw$Rur <- 1 - CGSS_raw$Urb

# Log transformation
CGSS_raw$linc <- log(CGSS_raw$q_income + 1)
CGSS_raw$linc2 <- CGSS_raw$linc^2
```

### Step 2: Construct Merit Indices

```r
# Load merit items from raw data
merit_items <- CGSS_raw[, c("q_merit_talent", "q_merit_ambition", 
                             "q_merit_work", "q_merit_education")]

# Apply factor analysis
library(psych)
fa_result <- fa(merit_items, nfactors = 2, fm = "ml", weights = CGSS_raw$weight)

# Extract factor scores
FcM1 <- factor.scores(merit_items, fa_result)$scores[, 1]
FcM2 <- factor.scores(merit_items, fa_result)$scores[, 2]
```

### Step 3: Run Full Analysis

```r
source("Deps.R")

# Your prepared data
Data <- CGSS_raw

# Run analysis
source("Examples/Example_Meritocracy.R")
```

## Recommended Citations

When using this code with CGSS data:

```bibtex
@dataset{CGSS2006,
  author = {{Research Center for Sociology, Renmin University of China}},
  title = {China General Social Survey 2006},
  year = {2006},
  url = {http://www.chinagss.org}
}

@article{AuthorYear,
  author = {Your Name and Your Professor},
  title = {Your Paper Title},
  year = {Year},
  journal = {Your Journal}
}
```

## Questions & Support

For issues related to:

- **Data access:** Contact CGSS directly (http://www.chinagss.org)
- **Code/analysis:** Open an issue on the GitHub repository
- **Licensing:** Consult the CGSS data use agreement

---

**Last Updated:** May 2026  
**For:** 3SLS Meritocracy Research Project
