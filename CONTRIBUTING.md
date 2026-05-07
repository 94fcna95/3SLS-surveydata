# Contributing Guide

We welcome contributions to improve this 3SLS implementation and analysis!

## How to Contribute

### 1. **Report Issues**

Found a bug or have a question?

- **Check first:** Browse [Issues](https://github.com/yourusername/3sls-meritocracy/issues) to see if it's already reported
- **Create new:** If not found, [open a new issue](https://github.com/yourusername/3sls-meritocracy/issues/new) with:
  - Clear title describing the problem
  - Detailed description of steps to reproduce
  - Expected vs. actual behavior
  - Your R version and OS
  - Relevant error messages (in code block)

### 2. **Suggest Improvements**

Have an idea to improve the code?

- **Features:** Suggest new functions, analyses, or documentation
- **Performance:** Point out inefficient code
- **Clarity:** Recommend better explanations or examples

Use Issues with `[Feature Request]` or `[Documentation]` tags.

### 3. **Submit Code Changes**

To contribute code improvements:

#### **Step 1: Fork & Clone**
```bash
# Fork on GitHub, then clone your fork
git clone https://github.com/yourusername/3sls-meritocracy.git
cd 3sls-meritocracy
git remote add upstream https://github.com/originalauthor/3sls-meritocracy.git
```

#### **Step 2: Create Feature Branch**
```bash
git checkout -b feature/your-feature-name
# or: git checkout -b fix/bug-description
```

#### **Step 3: Make Changes**
- Keep changes focused and atomic
- Follow R style guide (see below)
- Update relevant documentation
- Add comments explaining non-obvious code

#### **Step 4: Test Your Changes**
```r
# Load updated code
source("Deps.R")

# Test with example
source("Examples/Example_Meritocracy.R")

# Check for errors
# Verify results match expectations
```

#### **Step 5: Commit & Push**
```bash
git add .
git commit -m "Clear message describing your changes"
git push origin feature/your-feature-name
```

#### **Step 6: Open Pull Request**
- Go to GitHub repository
- Click "New Pull Request"
- Select your branch
- Write clear PR description:
  - What problem does this solve?
  - What changes did you make?
  - Are there any breaking changes?
  - Link any related issues (#123)

---

## Code Style Guidelines

### **R Code Style**

Follow Google's R style guide (simplified):

```r
# Good: snake_case for functions and variables
my_function <- function(data, weights = NULL) {
  # Do something
  return(result)
}

# Bad: camelCase or dots
myFunction <- function(data, weights = NULL) { ... }
my.function <- function(data, weights = NULL) { ... }
```

### **Naming Conventions**

- **Functions:** `verb_noun()` (e.g., `compute_elasticity()`)
- **Variables:** descriptive names (e.g., `residual_matrix` not `rm`)
- **Constants:** `UPPER_CASE` (e.g., `MAX_ITERATIONS = 1000`)
- **Temporary:** okay to use `x`, `i`, `j` in loops

### **Formatting**

```r
# Good: 2-space indentation
if (condition) {
  result <- function_call(arg1, arg2,
                          arg3)
}

# Bad: inconsistent indentation
if (condition) {
result <- function_call(arg1, arg2, arg3)
}

# Line length: max ~80 characters for readability
# Comments: Use # for explanations
# Spacing: Space around operators (x + y, not x+y)
```

### **Documentation**

Include comments for:
- Complex logic
- Non-obvious decisions
- Mathematical formulas
- Parameter explanations

```r
# Example of good documentation
estimate_3sls <- function(equations, inst, data, weights = NULL) {
  #' Three-Stage Least Squares Estimation
  #'
  #' @param equations Named list of model formulas with instrumental variables
  #' @param inst Formula specifying instruments (exogenous variables)
  #' @param data Data frame containing all variables
  #' @param weights Optional survey weights
  #'
  #' @return List with class "threeSLS_fit" containing:
  #'   - structural: structural parameters and variance
  #'   - residuals: equation-specific residuals
  #'   - fitted: fitted values for each equation
  
  # Implementation...
}
```

---

## Documentation Standards

### **README Updates**

If you add new functionality, update README.md:
- Add function to "Key Features" section
- Include usage example
- Document parameters and outputs
- Link to relevant code/documentation

### **Example Scripts**

For substantial features, add example usage:
- Create file in `Examples/` directory
- Include detailed comments
- Show practical application
- Test thoroughly before submitting

### **Variable Documentation**

Using new variables? Update:
- `docs/VARIABLE_GUIDE.md` with definitions
- `Data/README_DATA.md` with data source information
- Include coding schemes and ranges

---

## Testing Standards

### **Before Submitting PR:**

1. **Run existing examples** - ensure they still work:
   ```r
   source("Examples/Example_Meritocracy.R")
   ```

2. **Test edge cases** - try unusual inputs:
   ```r
   # Small sample
   # Different sample restrictions
   # Different variable types
   ```

3. **Check for errors** - no warnings or messages during normal use

4. **Verify output** - results should be reasonable:
   - Coefficients sensible magnitudes?
   - Standard errors positive?
   - Correlations between -1 and 1?

---

## Types of Contributions Welcome

### 🐛 **Bug Fixes**
- Fix errors in calculations
- Improve error handling
- Handle edge cases better

### 📚 **Documentation**
- Clarify explanations
- Add more examples
- Improve variable descriptions
- Fix typos

### ✨ **Features**
- New diagnostic tests
- New output formats
- Performance improvements
- Extended functionality

### 🧪 **Testing**
- Unit tests for functions
- Integration tests for full workflow
- Edge case testing

### 🌍 **Localization**
- Translations of documentation
- Region-specific examples
- Alternative data sources

---

## Code Review Process

### **What We'll Review:**

- **Correctness:** Does it work correctly?
- **Style:** Does it follow guidelines?
- **Tests:** Is it properly tested?
- **Documentation:** Is it clearly documented?
- **Impact:** Does it break existing functionality?

### **Feedback:**

- Will be constructive and specific
- May request changes before merging
- Questions are welcome (helps improve clarity)

### **Approval & Merging:**

- Need approval from main maintainers
- May take 1-2 weeks for review
- Will be merged to `main` branch

---

## Questions?

- 📧 Email: [your.email@institution.edu]
- 💬 Open a GitHub Discussion
- 📖 See [README.md](README.md) for more context

---

## Contributor Acknowledgment

All contributors will be:
- ✨ Acknowledged in README.md
- 🙏 Thanked in commit messages
- 📜 Listed in CONTRIBUTORS.md (coming soon)

---

Thank you for helping improve this project! 🎉

---

**Last Updated:** May 2026  
**Maintained by:** [Your Name] & [Professor Name]
