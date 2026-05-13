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

## Variable Guide

### Key Variables Used in Analysis

#### **Outcome Variables**
| Variable | Description |
|----------|-------------|
| `Migs` | Seasonal migrant |
| `Migl` | Long-term migrant |
| `RP` | Redistribution preference |

#### **Instrumental Variables**
| Variable | Description |
|----------|-------------|
| `flood` | Importance of floods in the province |
| `water` | Water resources in the province |

#### **Demographic Variables**
| Variable | Description |
|----------|-------------|
| `age` | Age of the respondent |
| `female` | Gender of the respondent |
| `Single` | Marital status of the respondent |
| `party` | The respondent is a member of the CCP |

#### **Economic Variables**
| Variable | Description |
|----------|-------------|
| `linc` | Log of personal income+1 |
| `idlinc` | Indicator for a zero income |
| `lowerfin` | Having negative financial expectations |
| `Dif` | Median wage discrimination for peasant worker at the provincial level |

#### **Hukou Status**
| Variable | Description |
|----------|-------------|
| `Rur` | Having a rural hukou |
| `Urb` | Having an urban hukou |

#### **Survey Design**

| Variable | Name | Type | Range | Description |
|----------|------|------|-------|-------------|
| `weight` | Sampling weight | Continuous | 0.1-3 | Survey weight (normalized, mean = 1) |
| `id` | Respondent ID | Integer | 1-n | Unique identifier |


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
# Apply utility functions found in Meritocracy.lib.R to process data, and prepare data accordingly

# 3. Run analysis scripts with original data
source("Examples/Example_Meritocracy.R")
```

### Option 2: With Synthetic Data (For Learning/Testing)

The repository unfortunately cannot include a synthetic data generator that creates data mirroring the CGSS structure, due to licencing agreements. Comparable real data (or synthetic) is nonetheless viable with our workflow, with prior variable preparation.

```r
source("Deps.R")

# Run analysis with synthetic data/your own
Data <- CGSS_similar

# Note: Results will differ from the original analysis,
# but the workflow and code structure is identical
```

**Advantages of free-use data alternatives and/or synthetic data:**
- ✓ Freely distributable
- ✓ No licensing restrictions
- ✓ Useful for teaching and methodology demonstration
- ✓ Preserves variable correlations and distributions

**Limitations:**
- ✗ Not representative of actual population (in this case, Chinese)
- ✗ Results cannot be used for policy recommendations
- ✗ Magnitudes of effects are illustrative only

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

## Data Preparation Steps using the example script

## The `Example_Meritocracy.R` performs:

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

#### Common sources of missingness in CGSS:
- Refusal to answer (especially income, political affiliation)
- Item nonresponse (forgetting, inability to estimate)
- Implicit restrictions (e.g., Migs/Migl only for rural residents)


## Recommended Citations

When using this code with CGSS data:

```bibtex
@dataset{CGSS2006,
  author = {{Research Center for Sociology, Renmin University of China}},
  title = {China General Social Survey 2006},
  year = {2006},
  url = {http://www.chinagss.org}
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
