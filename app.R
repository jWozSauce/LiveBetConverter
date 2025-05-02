library(shiny)
library(implied)
library(odds.converter)

# Shiny app: Value Odds Calculator with Fair Odds & Probabilities
ui <- fluidPage(
  titlePanel("Value Odds Calculator"),
  sidebarLayout(
    sidebarPanel(
      # Custom labels for inputs and results
      textInput(
        inputId = "labelOver",
        label   = "Label for Over/Away Odds and Results:",
        value   = "Over/Away Odds (US):"
      ),
      textInput(
        inputId = "labelUnder",
        label   = "Label for Under/Home Odds and Results:",
        value   = "Under/Home Odds (US):"
      ),
      # Static input for value needed
      numericInput(
        inputId = "valueInDecPercent",
        label   = "Value Needed (Decimal):",
        value   = 0.05,
        step    = 0.01
      ),
      # Dynamic numeric inputs for odds
      uiOutput("overOddsUI"),
      uiOutput("underOddsUI")
    ),
    mainPanel(
      h3("Results"),
      
      # Value Odds section
      h4("Value Odds"),
      verbatimTextOutput("valueOverOrAwayOdds"),
      verbatimTextOutput("valueUnderOrHomeOdds"),
      
      # Fair Odds section
      h4("Fair Odds"),
      verbatimTextOutput("fairOverOrAwayOdds"),
      verbatimTextOutput("fairUnderOrHomeOdds"),
      
      # Fair Probabilities section
      h4("Fair Probabilities"),
      verbatimTextOutput("probOverOrAway"),
      verbatimTextOutput("probUnderOrHome")
    )
  )
)

server <- function(input, output, session) {
  # Render dynamic numeric inputs with labels from text inputs
  output$overOddsUI <- renderUI({
    numericInput(
      inputId = "overOrAwayOdds",
      label   = input$labelOver,
      value   = -110,
      step    = 1
    )
  })
  output$underOddsUI <- renderUI({
    numericInput(
      inputId = "underOrHomeOdds",
      label   = input$labelUnder,
      value   = -110,
      step    = 1
    )
  })
  
  # Reactive computation including fair odds and probabilities
  computed <- reactive({
    oddsUS <- c(input$overOrAwayOdds, input$underOrHomeOdds)
    oddsDec <- odds.us2dec(oddsUS)
    # handle cases where implied probabilities sum < 1
    noVig <- tryCatch(
      implied_probabilities(oddsDec, method = "wpo", normalize = TRUE),
      error = function(e) NULL
    )
    if (is.null(noVig)) {
      return(list(
        valueOver = NA, valueUnder = NA,
        fairOver = NA, fairUnder = NA,
        probOver = NA, probUnder = NA
      ))
    }
    probs    <- noVig$probabilities           # Fair probabilities (decimal)
    fairOdds <- round(odds.prob2us(probs), 0)  # Fair odds (US)
    valueOdds <- round(odds.prob2us(probs - input$valueInDecPercent), 0)
    list(
      valueOver = valueOdds[1],
      valueUnder = valueOdds[2],
      fairOver = fairOdds[1],
      fairUnder = fairOdds[2],
      probOver = probs[1],
      probUnder = probs[2]
    )
  })
  
  # Render Value Odds with matching labels
  output$valueOverOrAwayOdds <- renderText({
    val <- computed()$valueOver
    paste0(input$labelOver, " ", ifelse(is.na(val), "N/A", val))
  })
  output$valueUnderOrHomeOdds <- renderText({
    val <- computed()$valueUnder
    paste0(input$labelUnder, " ", ifelse(is.na(val), "N/A", val))
  })
  
  # Render Fair Odds
  output$fairOverOrAwayOdds <- renderText({
    val <- computed()$fairOver
    paste0(input$labelOver, " Fair Odds: ", ifelse(is.na(val), "N/A", val))
  })
  output$fairUnderOrHomeOdds <- renderText({
    val <- computed()$fairUnder
    paste0(input$labelUnder, " Fair Odds: ", ifelse(is.na(val), "N/A", val))
  })
  
  # Render Fair Probabilities
  output$probOverOrAway <- renderText({
    p <- computed()$probOver
    paste0(input$labelOver, " Fair Probability: ", ifelse(is.na(p), "N/A", round(p, 4)))
  })
  output$probUnderOrHome <- renderText({
    p <- computed()$probUnder
    paste0(input$labelUnder, " Fair Probability: ", ifelse(is.na(p), "N/A", round(p, 4)))
  })
}

# Run the application
shinyApp(ui, server)
