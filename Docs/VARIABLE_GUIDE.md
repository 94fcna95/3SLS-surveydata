# Variable Guide

Complete documentation of all variables used in the analysis.

## Table of Contents

1. [Introduction](#introduction)
2. [Three-Equation Model (GitHub Demo)](#three-equation-model-github-demo)
3. [Seven-Equation Model (Zhou & Lubrano 2026)](#seven-equation-model-zhou--lubrano-2026)
4. [How Constructed Variables Are Built](#how-constructed-variables-are-built)
5. [Survey Design](#survey-design)
6. [Missing Data](#missing-data)

---

## Introduction

All variables are drawn from the **China General Social Survey (CGSS) 2006**, a repeated cross-section survey covering 28 provinces and 10,151 weighted observations of individuals aged 18 and above. The survey is representative of both rural and urban populations; survey weights are essential to correct for the systematic under-sampling of the rural population (without weights, the rural share drops from 62% to 49%).

This guide is divided into two parts:
- **Section 2** documents the simplified **3-equation model** used in `Example_Meritocracy.R`, intended for users learning the 3SLS workflow with this repository.
- **Section 3** documents the full **7-equation model** of Zhou & Lubrano (2026), intended for researchers replicating the published results.

Sections 4–6 apply to both models.

---

## Three-Equation Model (GitHub Demo)

Variables used in the demonstration model:

```r
eq1 = Migs ~ water + flood + age + female + linc + idlinc | subset(Urb == 0)
eq2 = Migl ~ water + flood + age + Single + linc + idlinc + Dif | subset(Urb == 0)
eq3 = RP ~ water + party + lowerfin + linc + idlinc + Rur + Migs + Migl
```

### Endogenous Variables

| Variable | Description | Type | Sample |
|----------|-------------|------|--------|
| `Migs` | Seasonal migrant — rural resident working temporarily outside home area | Binary (0/1) | Rural only (`Urb == 0`) |
| `Migl` | Long-term migrant — rural resident with countryside origin, permanently relocated | Binary (0/1) | Rural only (`Urb == 0`) |
| `RP` | Preference for government-led redistribution. POLS transform of a 1–4 Likert scale ("One should tax the rich to help the poor") | Continuous (POLS) | Full sample |

### Instrumental Variables

| Variable | Description | Type |
|----------|-------------|------|
| `flood` | Provincial flood severity index. Motivates long-term migration, impedes seasonal migration. Included in `eq3` to avoid omitted variable bias | Continuous (0–1 index) |
| `water` | Average provincial water resources over the last four decades (cubic metres per km²). Included in all three equations to purge `flood` of long-term opinion effects | Continuous |

### Demographic Variables

| Variable | Description | Type |
|----------|-------------|------|
| `age` | Age of the respondent in years | Continuous (18–85) |
| `female` | Gender: 1 = female, 0 = male | Binary (0/1) |
| `Single` | Marital status: 1 = single, 0 = otherwise | Binary (0/1) |
| `party` | CCP membership: 1 = member, 0 = non-member | Binary (0/1) |

### Economic Variables

| Variable | Description | Type |
|----------|-------------|------|
| `linc` | Natural log of personal income + 1 | Continuous |
| `idlinc` | Zero income indicator: 1 = zero personal income (11% of sample), 0 = otherwise | Binary (0/1) |
| `lowerfin` | Negative financial expectations: 1 = expects family financial situation to worsen, 0 = otherwise | Binary (0/1) |
| `Dif` | Provincial median wage discrimination index for peasant workers — difference between justified and actual income, purged of individual characteristics. See [Section 4.1](#41-discrimination-index-dif) | Continuous |

### Hukou Status

| Variable | Description | Type |
|----------|-------------|------|
| `Rur` | Holds rural hukou: 1 = rural, 0 = urban | Binary (0/1) |
| `Urb` | Holds urban hukou: 1 = urban, 0 = rural. Used as sample restriction (`Urb == 0`) in migration equations | Binary (0/1) |

> `Rur` and `Urb` are complements: `Rur = 1 - Urb`. `Urb` defines the sample restriction; `Rur` enters as a regressor in `eq3`.

---

## Seven-Equation Model (Zhou & Lubrano 2026)

Variables used in the full published model:

```r
eq1 = Migs ~ water + rev + flood + age + age2 + female + believer + idlinc  | subset(Urb == 0)
eq2 = Migl ~ water + rev + flood + age + Single + yeduc + Dif + idlinc      | subset(Urb == 0)
eq3 = FcAM ~ water + rev + age + age2 + party + believer + Dif + Urb
eq4 = FcM1 ~ water + rev + yeduc + beterfin + FcAM + Dif + Urb
eq5 = FcM2 ~ water + rev + yeduc + FcAM + FcM1 + Dif + Urb
eq6 = RP   ~ water + rev + lowerfin + linc + idlinc + FcAM + FcM1 + FcM2 + Rur + Migs + Migl
eq7 = linc ~ water + rev + age + age2 + female + Single + yeduc + idlinc + Urb
```

### Endogenous Variables

| Variable | Description | Type | Sample |
|----------|-------------|------|--------|
| `Migs` | Seasonal migrant | Binary (0/1) | Rural only (`Urb == 0`) |
| `Migl` | Long-term migrant | Binary (0/1) | Rural only (`Urb == 0`) |
| `FcAM` | Anti-meritocratic beliefs — perceived importance of Guanxi, demographic ascription, and family background for success. First factor from a second-stage factor analysis on three anti-merit dimensions. See [Section 4.2](#42-merit-factor-scores-fcm1-fcm2-fcam) | Continuous (factor score) | Full sample |
| `FcM1` | Classical meritocracy — perceived importance of ambition and hard work. First factor from factor analysis on merit items | Continuous (factor score) | Full sample |
| `FcM2` | Natural ability — perceived importance of intelligence, education, and good looks. Second factor from factor analysis on merit items | Continuous (factor score) | Full sample |
| `RP` | Redistribution preference. POLS transform of a 1–4 Likert scale | Continuous (POLS) | Full sample |
| `linc` | Log income — endogenous in the full model, estimated in `eq7` | Continuous | Full sample |

### Instrumental Variables

| Variable | Description | Type |
|----------|-------------|------|
| `flood` | Provincial flood severity index (Liao et al. 2013). Valid instrument: affects migration decisions but is included in opinion equations to correct for omitted variable bias | Continuous (0–1 index) |
| `water` | Average provincial water resources over last four decades. Included in all equations | Continuous |
| `rev` | Average provincial rainfall level over last four decades (mm per m²). Included in all equations alongside `water` | Continuous |

### Demographic Variables

| Variable | Description | Type |
|----------|-------------|------|
| `age` | Age of the respondent in years | Continuous (18–85) |
| `age2` | Age squared, scaled: age² / 100. Captures non-linear lifecycle effects | Continuous |
| `female` | Gender: 1 = female, 0 = male | Binary (0/1) |
| `Single` | Marital status: 1 = single, 0 = otherwise | Binary (0/1) |
| `party` | CCP membership: 1 = member, 0 = non-member | Binary (0/1) |
| `believer` | Religious believer: 1 = any faith, 0 = non-believer | Binary (0/1) |
| `yeduc` | Years of formal education completed (0 = never attended school; primary = 6; university = 16) | Continuous (0–20) |

### Economic Variables

| Variable | Description | Type |
|----------|-------------|------|
| `linc` | Natural log of personal income + 1. Also endogenous in `eq7` | Continuous |
| `idlinc` | Zero income indicator: 1 = zero personal income, 0 = otherwise | Binary (0/1) |
| `lowerfin` | Negative financial expectations: 1 = expects financial situation to worsen | Binary (0/1) |
| `beterfin` | Positive financial expectations: 1 = expects financial situation to improve. Significant in meritocracy equations (`eq4`, `eq5`) | Binary (0/1) |
| `Dif` | Provincial median wage discrimination index for peasant workers. See [Section 4.1](#41-discrimination-index-dif) | Continuous |

### Hukou Status

| Variable | Description | Type |
|----------|-------------|------|
| `Rur` | Holds rural hukou: 1 = rural, 0 = urban | Binary (0/1) |
| `Urb` | Holds urban hukou: 1 = urban, 0 = rural | Binary (0/1) |

---

## How Constructed Variables Are Built

### 4.1 Discrimination Index (`Dif`)

`Dif` measures perceived wage discrimination against peasant workers at the provincial level. The CGSS asks respondents to estimate both the **actual** and **justified** monthly income for peasant workers. Raw answers depend on the respondent's own income, education, and social context, so these are purged via two separate log-linear regressions (controlling for `linc`, `yeduc`, `Rur`, `Migs`, `Migl`, and province dummies). The discrimination index is then computed as the difference between the exponentiated predicted values. The provincial median is then taken, restricted to respondents holding a rural hukou.

### 4.2 Merit Factor Scores (`FcM1`, `FcM2`, `FcAM`)

The CGSS contains 14 questions on perceived factors for career success, rated 1 (not important) to 5 (crucial). These are divided into two theoretical groups:

**Meritocratic items (5 items):** education, intelligence, ambition, hard work, talent and good looks.
A factor analysis on these 5 items (weighted, maximum likelihood) yields two factors:
- `FcM1` — **Classical meritocracy**: high loadings on ambition (0.946) and hard work (0.636)
- `FcM2` — **Natural ability**: high loadings on intelligence, education, and good looks

**Anti-meritocratic items (9 items):** family wealth, parents' education, birthplace, gender, age, social networks (Guanxi), knowing people in power, political loyalty, fate and destiny.
A first factor analysis yields three dimensions (Guanxi, demographic ascription, family background). A second factor analysis on these three dimensions, imposing a single factor, produces:
- `FcAM` — **Anti-meritocratic beliefs**: a single index summarising all non-meritocratic advantages

All indices are translated so their minimum value is 1, making them conformable to the original 1–5 scale of the survey items.

```r
# Factor analysis on merit items
fa_merit <- fa(merit_items, nfactors = 2, fm = "ml", weights = weight)
FcM1 <- factor.scores(merit_items, fa_merit)$scores[, 1]
FcM2 <- factor.scores(merit_items, fa_merit)$scores[, 2]

# Translate to start at 1
FcM1 <- Transl(FcM1)
FcM2 <- Transl(FcM2)
FcAM <- Transl(FcAM)
```

### 4.3 POLS Transformation

Ordinal variables on Likert scales (`RP`, and migration intentions prior to binarisation) are transformed using the **Probit OLS (POLS)** method of van Praag & Ferrer-i-Carbonell (2004). The transformation:

1. Computes the weighted sample frequency for each response category
2. Recovers category thresholds as quantiles of the standard normal distribution
3. Assigns to each observation the conditional expectation of the normal distribution within its category interval

This produces a continuous approximation to the underlying latent utility, allowing ordinal variables to be used directly in a linear system without ordered probit.

```r
RP <- POLS(RP_ordinal, w = weight, inorm = 1)
```

---

## Survey Design

| Variable | Description | Type |
|----------|-------------|------|
| `weight` | Sampling weight, normalized (mean ≈ 1). Corrects for differential sampling probabilities and systematic under-sampling of the rural population | Continuous |
| `id` | Unique respondent identifier | Integer |

**Equation-specific sample restrictions:** The migration equations (`eq1`, `eq2`) are estimated on rural residents only (`Urb == 0`), as urban residents are by definition outside the internal migration market. This is implemented via the `| subset()` syntax in `threeSLS_system()`, which handles separate design matrices per equation while preserving the residual correlation structure across the full system.

---

## Missing Data

- **Income:** The CGSS records fewer than 8% missing values for personal income. In the original paper these are imputed via a log regression on gender, age, education, and province dummies. In the repository example, complete-case analysis is used.
- **Zero income:** 11% of valid observations report zero annual income. These are treated as valid and flagged by `idlinc = 1`, not removed.
- **Other variables:** Complete-case analysis is applied — rows with any `NA` across the variables used in the system are removed prior to estimation.
- **Implicit missingness:** `Migs` and `Migl` are undefined for urban residents by design; this is handled through the `subset(Urb == 0)` restriction rather than NA coding.

---

## References

- van Praag, B. and Ferrer-i-Carbonell, A. (2004). *Happiness Quantified: A Satisfaction Calculus Approach.* Oxford University Press.
- Liao, Y. et al. (2013). Spatial pattern analysis of natural disasters in China from 2000 to 2011. *Journal of Catastrophology*, 28(4):55–60.
- Zhou, X. and Lubrano, M. (2026). Meritocracy and preference for redistribution in China: the impact of internal migrations. *AMSE Working Paper.*
- CGSS Codebook: http://www.chinagss.org

---

**Last Updated:** May 2026  
**For:** 3SLS Meritocracy Research Project — `docs/VARIABLE_GUIDE.md`
