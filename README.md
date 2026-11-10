# StudentAnalytics
Student analytic dashboard build for job application @UOA

# Student Analytics

An interactive R Shiny dashboard for exploring student results, built as a demonstration for a Research Programmer role in a university statistics department.

**Live app:** https://01a1bd59-613e-d392-f046-b943576d0fb2.share.connect.posit.cloud/

## What it does

Choose a term (Term 1 or Term 2) and the whole page updates.

- **Summary:** number of students, average attendance, best in marks, best in attendance, and the pass/fail count.
- **Most improved:** the biggest gain in average marks and in attendance from Term 1 to Term 2.
- **Examination results chart:** pass and fail counts for each subject (English, Maths, Science). Hovering over a bar shows the percentage of students.
- **Student table:** 10 students per page, searchable and sortable.
- **Relationship chart:** pick any two of attendance, the three subjects, or the average, and see each student as a dot with a trend line. Hovering shows the student's name and both values.

## Pass/fail rule

A student passes a term only if they score 50 or more in **every** subject, as pass/fail is decided per subject and not on the average. The average is used for ranking only.

## Data

`data/students_by_term.csv` is a synthetic dataset: 100 fictional students across two terms (200 rows). It contains no real student data.

| Column | Meaning |
|---|---|
| `student_id`, `name` | Identifier and fictional name |
| `department` | Statistics, Computer Science or Mathematics |
| `term` | Term 1 or Term 2 |
| `attendance` | Attendance, % |
| `english`, `maths`, `science` | Scores out of 100 |

The average and pass/fail result are calculated in the app, not stored in the file, so they can't drift out of sync with the scores.

## Built with

R, [shiny](https://shiny.posit.co/), [plotly](https://plotly.com/r/) and [DT](https://rstudio.github.io/DT/). Published on Posit Connect Cloud.

## Run it locally

```r
install.packages(c("shiny", "plotly", "DT"))
shiny::runApp()
```

Run this from the project folder, so the app can find the `data` folder.

## Project structure

```
app.R                      the Shiny app (interface and server logic)
data/students_by_term.csv  the dataset
README.md                  this file
```

## Known limitations and next steps

- When students tie (for example, several with 100% attendance), only the first is shown as "best".
- The dataset is small and synthetic, so trend lines are indicative only.
- Possible next steps: upload your own CSV, filters by department, an at-risk student list, automated tests and a Dockerfile.
