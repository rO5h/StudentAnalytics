library(shiny)
library(plotly)
library(DT)

students <- read.csv("data/students_by_term.csv")

students$average <- round(rowMeans(students[, c("english", "maths", "science")]), 1)
students$result <- ifelse(
  students$english >= 50 & students$maths >= 50 & students$science >= 50,
  "Pass", "Fail"
)

t1 <- subset(students, term == "Term 1")
t2 <- subset(students, term == "Term 2")

change <- merge(
  t1[, c("student_id", "name", "average", "attendance")],
  t2[, c("student_id", "average", "attendance")],
  by = "student_id",
  suffixes = c("_t1", "_t2")
)

change$marks_change <- round(change$average_t2 - change$average_t1, 1)
change$attendance_change <- change$attendance_t2 - change$attendance_t1

var_choices <- c("Attendance" = "attendance", "English" = "english",
                 "Maths" = "maths", "Science" = "science", "Average" = "average")

ui <- fluidPage(
  titlePanel("Student Analytics"),
  selectInput("term", "Choose a term:", choices = c("Term 1", "Term 2")),
  h4("Examination results by subject"),
  fluidRow(
    column(5,
           plotlyOutput("exam_chart", width = "600px", height = "400px")
    ),
    column(3,
           wellPanel(
             textOutput("student_count"),
             textOutput("avg_attendance"),
             textOutput("best_marks"),
             textOutput("best_attendance"),
             textOutput("pass_fail")
           ),
           wellPanel(
             h4("Most improved (Term 1 to Term 2)"),
             textOutput("most_improved_marks"),
             textOutput("most_improved_attendance")
           )
    )
  ),

  DTOutput("student_table"),
  
  h4("Relationship between two variables"),
  selectInput("x_var", "X axis (across):", choices = var_choices, selected = "attendance"),
  selectInput("y_var", "Y axis (up):", choices = var_choices, selected = "average"),
  plotlyOutput("scatter", width = "600px", height = "400px")
)

server <- function(input, output) {
  selected <- reactive({
    subset(students, term == input$term)
  })
  
  output$student_count <- renderText({
    paste("Total Students:", nrow(selected()))
  })
  
  output$avg_attendance <- renderText({
    paste("Average attendance:", round(mean(selected()$attendance), 1), "%")
  })
  
  output$best_marks <- renderText({
    paste("Best in marks:", selected()$name[which.max(selected()$average)])
  })
  
  output$best_attendance <- renderText({
    paste("Best in attendance:", selected()$name[which.max(selected()$attendance)])
  })
  
  output$pass_fail <- renderText({
    paste("Pass:", sum(selected()$result == "Pass"), "| Fail:", sum(selected()$result == "Fail"))
  })
  
  output$most_improved_marks <- renderText({
    i <- which.max(change$marks_change)
    paste0("Most improved in marks: ", change$name[i], " (+", change$marks_change[i], " points)")
  })
  
  output$most_improved_attendance <- renderText({
    i <- which.max(change$attendance_change)
    paste0("Most improved in attendance: ", change$name[i], " (+", change$attendance_change[i], "%)")
  })
  output$student_table <- renderDT({
    selected()[, c("student_id", "name", "department",
                   "attendance", "english", "maths", "science",
                   "average", "result")]
  }, rownames = FALSE, options = list(pageLength = 10))
  output$exam_chart <- renderPlotly({
    d <- selected()
    subjects <- c("english", "maths", "science")
    labels <- c("English", "Maths", "Science")
    
    pass <- unname(sapply(subjects, function(s) sum(d[[s]] >= 50)))
    fail <- nrow(d) - pass
    pass_pct <- round(pass / nrow(d) * 100)
    fail_pct <- round(fail / nrow(d) * 100)
    
    plot_ly() |>
      add_bars(x = labels, y = pass, name = "Pass",
               marker = list(color = "seagreen"),
               hovertext = paste0(labels, "<br>Total Pass: ", pass, " | Percentage (", pass_pct, "%)"),
               hoverinfo = "text") |>
      add_bars(x = labels, y = fail, name = "Fail",
               marker = list(color = "firebrick"),
               hovertext = paste0(labels, "<br>Total Fail: ", fail, " | Percentage (", fail_pct, "%)"),
               hoverinfo = "text") |>
      layout(barmode = "group", title = input$term,
             xaxis = list(title = "Subject"),
             yaxis = list(title = "Number of students"))
  })
  output$scatter <- renderPlotly({
    d <- selected()
    x <- d[[input$x_var]]
    y <- d[[input$y_var]]
    x_label <- names(var_choices)[var_choices == input$x_var]
    y_label <- names(var_choices)[var_choices == input$y_var]
    o <- order(x)
    line_y <- fitted(lm(y ~ x))
    
    plot_ly() |>
      add_markers(x = x, y = y,
                  text = paste0(d$name, "<br>", x_label, ": ", x, "<br>", y_label, ": ", y),
                  hoverinfo = "text") |>
      add_lines(x = x[o], y = line_y[o], hoverinfo = "none") |>
      layout(title = input$term,
             xaxis = list(title = x_label),
             yaxis = list(title = y_label),
             showlegend = FALSE)
  })
}

shinyApp(ui, server)