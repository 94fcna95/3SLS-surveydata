# Variable Guide

Complete documentation of all variables used in the analysis.

## Table of Contents

1. [Outcome Variables](#outcome-variables)
2. [Exogenous Variables](#exogenous-variables)
3. [Constructed Variables](#constructed-variables)
4. [Survey Design](#survey-design)
5. [Data Coding Schemes](#data-coding-schemes)
6. [Missing Data](#missing-data)

---

## Outcome Variables

### **Migs** — Small-Scale Internal Migration

**Description:** Respondent's intentions regarding small-scale, short-distance internal migration (e.g., provincial or regional moves).

**Type:** Ordinal (1-5 scale)  
**Sample:** Rural residents only (`Urb == 0`)  
**Source:** CGSS item on migration intentions

**Coding:**
- 1 = Never thought about migration
- 2 = Thought about it
- 3 = Prepared / discussing with family
- 4 = Made concrete plans
- 5 = Already migrated

**Interpretation:** Higher values indicate stronger migration behavior/intentions.

**In the model:** Dependent variable in equation 1; appears as regressor in equations for RP, FcM2, FcAM.

---

### **Migl** — Large-Scale Internal Migration

**Description:** Respondent's intentions regarding large-scale, long-distance internal migration (e.g., inter-provincial moves to economically developed areas).

**Type:** Ordinal (1-5 scale)  
**Sample:** Rural residents only (`Urb == 0`)  
**Source:** CGSS item on migration to urban areas

**Coding:** Same as Migs (1-5 scale)

**Interpretation:** Captures desire for permanent relocation to urban centers or economically advantaged regions.

**In the model:** Dependent variable in equation 2; affects RP and all merit indices in structural equations.

---

### **RP** — Redistribution Preference

**Description:** Respondent's preference for government-led income redistribution policies.

**Type:** Ordinal (1-5 scale)  
**Sample:** Full sample (all respondents)  
**Source:** CGSS item on redistribution preference

**Coding:**
- 1 = Strongly oppose redistribution
- 2 = Oppose
- 3 = Neutral
- 4 = Favor
- 5 = Strongly favor redistribution

**Interpretation:** Proxy for socialist/egalitarian values; relates to meritocratic beliefs (paradoxically—more believer in merit = less support for redistribution).

**In the model:** Dependent variable in equation 3; reflects synthesis of migration experiences and merit perceptions.

---

### **FcM1** — Merit Factor 1: Individual Effort

**Description:** Factor score capturing perceptions of merit based on individual effort and talent. Combines beliefs about:
- Importance of intelligence
- Importance of ambition
- Importance of hard work/effort

**Type:** Continuous (1-5 scale after standardization)  
**Derivation:** First factor from factor analysis on effort-related items (weight ≈ 0.5)  
**Sample:** Full sample  

**Interpretation:** 
- Higher values = Stronger belief that individual talent and effort determine success
- Reflects "meritocratic" worldview

**In the model:** 
- Dependent in equation 4
- Regressor in RP, FcM2, FcAM equations
- Feedback effects: migration affects merit beliefs and vice versa

---

### **FcM2** — Merit Factor 2: Education & Talent

**Description:** Factor score capturing importance of education and natural talent. Combines:
- Importance of education level
- Importance of talent/gifts
- Related to opportunity factors

**Type:** Continuous (1-5 scale after standardization)  
**Derivation:** Second factor from factor analysis (weight ≈ 0.5)  
**Correlation with education:** Moderately positive (people with more education believe education matters)  

**Interpretation:**
- Reflects structural factors (education levels) interacting with belief in meritocracy
- More sensitive to respondent's own education level than FcM1

**In the model:**
- Dependent in equation 5
- Regressor in RP, FcAM equations
- Feeds back to affect redistribution preferences

---

### **FcAM** — Actual Merit Factors (Non-Meritocratic)

**Description:** Factor score capturing perceived importance of **non-meritocratic** factors in determining success:
- Family background/wealth
- Social networks and connections
- Luck and fate
- Political performance
- "Knowing the right people"

**Type:** Continuous (1-5 scale after standardization)  
**Derivation:** First factor from factor analysis on opportunity/luck items (weight ≈ 0.33-0.40 each)  

**Interpretation:**
- Higher values = Stronger belief that non-meritocratic factors determine success
- Represents skepticism about meritocracy system
- Likely correlates with redistributive preferences

**In the model:**
- Dependent in equation 6
- Regressor in FcM1, FcM2 equations
- Central to understanding barriers to meritocracy

---

## Exogenous Variables

### **Environmental/Shock Variables**

#### **water** — Water Access Quality

**Description:** Perceived quality and accessibility of clean water supply.

**Type:** Ordinal (1-5 scale)  
**Source:** CGSS environmental satisfaction items

**Coding:**
- 1 = Very poor / Very dissatisfied
- 3 = Neutral / Average
- 5 = Excellent / Very satisfied

**Interpretation:**
- Proxy for local infrastructure quality
- Environmental stress indicator
- May affect migration decisions

---

#### **flood** — Flood/Disaster Exposure

**Description:** Respondent's exposure to flooding or water-related disasters in their area.

**Type:** Ordinal (1-5 scale)  
**Source:** CGSS item on local environmental hazards

**Coding:**
- 1 = No exposure / Never occurs
- 3 = Occasional/moderate exposure
- 5 = Frequent/severe exposure

**Interpretation:**
- **Key instrumental variable** for migration equations
- Pushes rural residents toward migration (especially Migl for better living conditions)
- Environmental shock affecting wellbeing

---

#### **rev** — Local Revenue/Economic Conditions

**Description:** Perceived local government fiscal capacity and economic development level.

**Type:** Ordinal (1-5 scale)  
**Source:** CGSS local economic items

**Coding:** 1-5 scale (1 = underdeveloped, 5 = highly developed)

**Interpretation:**
- Affects migration pull/push factors
- Influences merit belief formation (developing areas may have different meritocratic ideologies)
- Proxy for regional inequality

---

#### **Dif** — Income Inequality Perception

**Description:** Respondent's perception of income differences within their community or country.

**Type:** Ordinal (1-5 scale)  
**Source:** CGSS item: "Are income differences in [community/China] too large?"

**Coding:**
- 1 = Differences are too small / Too equal
- 3 = About right / Neutral
- 5 = Differences are way too large

**Interpretation:**
- Directly affects redistribution preferences
- May influence merit belief formation (high inequality → different meritocratic narratives)
- Depends on reference group (local vs national)

---

### **Demographic Variables**

#### **age** — Age

**Type:** Continuous (years)  
**Range:** 18-85  
**Source:** CGSS household roster

**Interpretation:**
- Affects migration propensity (younger = more likely)
- Lifecycle effects on political preferences
- Non-linear effects (include age²)

---

#### **age2** — Age Squared (Scaled)

**Type:** Continuous  
**Formula:** age² / 100  
**Scaling:** Divided by 100 to keep coefficients interpretable

**Interpretation:** Captures non-linear (inverted-U or U-shaped) relationships with outcomes.

**Example:** Migration typically decreases with age, but at a decreasing rate.

---

#### **female** — Gender

**Type:** Binary  
**Coding:** 
- 0 = Male
- 1 = Female

**Interpretation:**
- Different migration patterns by gender
- Potential discrimination effects on merit beliefs
- Political preference differences

---

#### **Urb** — Urban Residence

**Type:** Binary  
**Coding:**
- 0 = Rural
- 1 = Urban

**Interpretation:**
- Defines sample for Migs/Migl (migration only for rural)
- Urban residents are outside migration market
- Different institutional contexts for merit

---

#### **Rur** — Rural Residence

**Type:** Binary  
**Coding:**
- 0 = Urban (Rur = 1 - Urb)
- 1 = Rural

**Same information as Urb** but inverted; used as regressor rather than sample restriction.

---

### **Economic Variables**

#### **yeduc** — Years of Education

**Type:** Continuous (years)  
**Range:** 0-20  
**Source:** CGSS education attainment

**Coding:**
- 0 = No formal education
- 6 = Primary school completion
- 9 = Junior middle school
- 12 = High school
- 16 = University degree
- 20 = Advanced degree

**Interpretation:**
- Fundamental human capital measure
- Strongly predicts income
- Affects merit beliefs (educated believe more in meritocracy)
- Affects migration propensity (more education → more migration options)

---

#### **linc** — Log Household Income

**Type:** Continuous (natural log)  
**Formula:** log(Income + 1)  
**Source:** CGSS household income item

**Interpretation:**
- Percentage interpretation for coefficients: 0.01 = 1% increase in income
- Avoids outlier issues with raw income
- Better captures marginal effects at low vs high incomes

---

#### **linc2** — Log Income Squared

**Type:** Continuous  
**Formula:** linc²  

**Interpretation:**
- Captures non-linear income effects
- Often: higher income → more opposition to redistribution
- But relationship may be non-linear

---

#### **Income** — Raw Household Income

**Type:** Continuous  
**Range:** 0+  
**Formula:** exp(linc)  
**Units:** Local currency (Chinese Yuan)

**Interpretation:**
- Used in descriptive analysis
- For inference, use log form (linc) to avoid heteroskedasticity
- May have large outliers

---

### **Political & Belief Variables**

#### **party** — Communist Party Membership

**Type:** Binary  
**Coding:**
- 0 = Non-member (or candidate)
- 1 = Member (or candidate member)

**Interpretation:**
- Ideological alignment with socialist principles
- May affect redistribution preferences
- May affect migration (political restrictions, connections)

---

#### **believer** — Religious Belief

**Type:** Binary  
**Coding:**
- 0 = Non-believer / Atheist / Spiritual only
- 1 = Religious believer (any faith)

**Interpretation:**
- Religion affects political values
- May relate to trust in institutions
- Potentially affects migration decisions (social networks)

---

## Constructed Variables

### **How Merit Indices Are Created** (In the Full Analysis)

#### **Step 1: Raw Survey Items**

CGSS asks respondents to rate importance of various factors for success:

```
Q: "To what extent do these factors help someone succeed?"
Response: 1=not important ... 5=very important

Items include:
- Family wealth/background
- Education
- Intelligence / talent
- Hard work / ambition
- Social networks
- Political connections
- Good looks
- Luck / destiny
```

---

#### **Step 2: Factor Analysis**

Factor analysis reduces these 8-10 items to 2-3 underlying dimensions:

```r
fa_merit <- fa(merit_items, 
               nfactors = 2, 
               fm = "ml",              # Maximum likelihood extraction
               weights = survey_weight) # Weighted analysis

# Factor 1 (FcM1): "Individual Effort"
#   - High loadings: intelligence, ambition, hard work
#   - Eigenvalue ≈ 2.5

# Factor 2 (FcM2): "Education & Talent"  
#   - High loadings: education, talent, gifts
#   - Eigenvalue ≈ 1.8
```

---

#### **Step 3: Factor Scores**

Individual factor scores computed for each respondent:

```r
FcM1 <- factor.scores(merit_items, fa_merit)$scores[, 1]
FcM2 <- factor.scores(merit_items, fa_merit)$scores[, 2]
```

---

#### **Step 4: Standardization**

Rescale to 1-5 scale for interpretability:

```r
FcM1_scaled <- Transl(FcM1)  # Translate to start at 1
FcM1_scaled <- scale_to_1_5(FcM1_scaled)  # Scale to max 5
```

---

### **POLS Transformation** (Polychoric Ordinal)

For ordinal variables with few categories (e.g., 1-5 Likert), the POLS transformation:

1. Computes weighted percentiles for each category
2. Applies inverse normal CDF to percentiles
3. Creates continuous approximation to underlying latent variable

```r
RP_continuous <- POLS(RP_ordinal, weight = weight, inorm = 1)
```

---

## Survey Design

### **Survey Weights**

**Definition:** Weight variable (`weight`) reflects survey sampling design.

**Source:** CGSS provides these to adjust for:
- Differential sampling probabilities
- Non-response patterns
- Stratification by region/province

**Properties:**
- Normalized: mean(weight) ≈ 1
- Range: typically 0.5-2.0
- Always positive

**Usage in 3SLS:**
```r
fit <- threeSLS_system(..., weights = weight)
```

**Interpretation:** Each observation weighted by their representativeness of population.

---

### **Equation-Specific Samples**

#### **Rural-Only Equations** (Migs, Migl)

```r
Migs ~ water + flood + ... | subset(Urb == 0)
Migl ~ flood + age + ... | subset(Urb == 0)
```

**Rationale:** 
- Urban residents cannot be internal migrants (conceptually undefined)
- Only rural population makes migration decisions
- Improves model specification

**Implementation:**
- 3SLS function handles subsets automatically
- Creates separate X, Z matrices for each equation
- Preserves residual correlation structure

---

## Data Coding Schemes

### **Ordinal Variables (Likert Scale)**

Most social variables coded as 1-5 Likert scales:

```
1 = Strongly disagree / Very dissatisfied / Never
2 = Disagree / Dissatisfied / Rarely
3 = Neither agree nor disagree / Neutral / Sometimes
4 = Agree / Satisfied / Often
5 = Strongly agree / Very satisfied / Always
```

**In analysis:**
- Can use raw scale (treating as approximately continuous)
- Can apply POLS transformation for better normality
- Can use factor scores from factor analysis

---

### **Binary Variables**

Dummy/indicator coding (0/1):

```
0 = No / Absence
1 = Yes / Presence
```

Examples: `female`, `Urb`, `party`, `believer`

---

### **Continuous Variables**

- **age, yeduc:** Directly observed
- **linc:** Log transformation of raw income
- **FcM1, FcM2, FcAM:** Factor scores from FA

---

## Missing Data

### **Sources of Missingness**

1. **Item non-response:** Respondent refused or forgot to answer specific item
2. **Implicit restrictions:** e.g., Migs is NA for all urban residents (by design)
3. **Skip patterns:** e.g., income asked only if worked in past year
4. **Data errors:** Invalid codes treated as NA

---

### **Handling in Analysis**

3SLS estimation uses **complete-case analysis**:

```r
# Remove rows with any NA
Data_clean <- Data[complete.cases(Data), ]

# Then estimate
fit <- threeSLS_system(..., data = Data_clean)
```

**Note:** This reduces sample size but maintains consistency across equations.

---

### **Impact on Results**

- **Listwise deletion:** Conservative but sample reduces
- **Reported n:** Always report how many observations actually used
- **Check:** `nrow(Data)` vs `nrow(Data_clean)`

---

## Variable Correlation Matrix

Example correlations (from synthetic data):

```
         age  yeduc  linc  water  flood  RP  FcM1  FcM2  FcAM
age     1.00
yeduc   0.15  1.00
linc    0.12  0.45  1.00
water   0.08 -0.05  0.12  1.00
flood  -0.10 -0.08 -0.15  0.35  1.00
RP     -0.02 -0.08 -0.18  0.22  0.25  1.00
FcM1    0.10  0.20  0.18 -0.12  0.05 -0.35  1.00
FcM2    0.08  0.35  0.25 -0.10  0.08 -0.32  0.55  1.00
FcAM   -0.05  0.10  0.08  0.15  0.20  0.42 -0.20 -0.18  1.00
```

**Key patterns:**
- Education strongly correlates with income
- Flood exposure pushes toward redistribution
- Merit beliefs negative correlate with redistribution (endogenous by design)

---

## References

- CGSS Codebook: http://www.chinagss.org/
- Factor Analysis: Fabrigar et al. (1999), Psychological Bulletin
- Survey Methods: Kish (1965), Survey Sampling
- Log-transformation: Skrondal & Rabe-Hesketh (2004)

---

**Last Updated:** May 2026  
**For:** 3SLS Meritocracy Research Project
