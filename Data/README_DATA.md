# Data Documentation & Licensing

**Note : If you wish to test the tools in this package, without looking into our case-study, you can refer to the Read.Me and the pre-installed comprehensive labor-market example**

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

Clone the repository and run from its root directory.

### With Original CGSS Data

Place your CGSS 2006 file in `Data/`, then:

```r
source("Examples/Example_Meritocracy.R")
```

### With Synthetic Data (For Learning/Testing)

The repository cannot include a synthetic data generator mirroring the CGSS structure due to licensing agreements. Comparable real or synthetic data is nonetheless viable with our workflow, with prior variable preparation.

```r
source("Examples/Example_Meritocracy.R")  # uses CGSS_synthetic by default
```

| | Synthetic / Free-use data |
|---|---|
| ✓ | Freely distributable, no licensing restrictions |
| ✓ | Useful for teaching and methodology demonstration |
| ✗ | Not representative of the actual Chinese population |
| ✗ | Results cannot be used for policy recommendations |
| ✗ | Magnitudes of effects are illustrative only |

> All dependencies, libraries, and utility functions — including `Meritocracy-lib.r`, `CGT-3SLS-lib.r` and `CGT-LaTex-lib.r` — are loaded automatically via `Deps.R`.

### What `Example_Meritocracy.R` Does

1. **Variable transformation** — log transformation for income, squared terms for age and income, scaling of continuous variables
2. **Merit index construction** — factor analysis on individual items (real data) or synthetic generation (example), standardized to 1–5 scale
3. **Missing value handling** — complete-case analysis, implicit restrictions (e.g. rural-only samples), survey weight application
4. **Data validation** — range checks, correlation verification, summary statistics

### What `Deps.R` Does

`Deps.R` is called automatically by `Example_Meritocracy.R` and handles all setup:

1. **Package installation** — checks for and installs any missing R packages (`MASS`, `Matrix`, `weights`, `xtable`, `DescTools`, `psych`)
2. **Core libraries** — sources the three internal libraries in order:
   - `R/CGT-3SLS-lib.r` — 3SLS estimation functions
   - `R/CGT-LaTex-lib.r` — LaTeX output functions
   - `R/Meritocracy-lib.r` — utility functions (`POLS`, `Transl`, `EGP`)
3. **Verification** — confirms all key functions are available before analysis begins

You do not need to call `source("Deps.R")` manually.

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
