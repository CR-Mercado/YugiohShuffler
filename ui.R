
library(shiny)

# Define UI for application that creates a yugioh deck shuffler
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Draw Yugioh Hands"),
  h2("Rules for txt file"),
  h6("Write out your deck (40 - 60 cards) in a .txt file, using the following structure:"),
  h6("Nx CardName   - where N is the number of that card in the deck. For example, three
     stratos would be:    3x Stratos     then press enter, and continue down the decklist."),
  h6("For example: 3x Statos <hit enter> 
3x Malicious <hit enter> 
3x Destiny Draw <hit enter>"),
h6("You will be warned if your deck is in illegal number of cards."),
  # Sidebar with a file input
  sidebarLayout(
    sidebarPanel(
      fileInput("the.file","Choose a decklist in a txt file",
                multiple = FALSE,
                accept = ".txt",
                buttonLabel = "Browse"),
      
      h4("enter how many cards to draw each time (minimum 5) (number of columns)"),
    numericInput(inputId = "num.cards",
                 label = "Cards Per Draw",
                   value = 5, # No default value
                   min = 5,            # min value
                   max = 20,           # max value 
                   step = 1),         
  
    h4("Enter how many times you want to draw that many cards (number of rows)"),
    numericInput(inputId = "num.hands",
                 label = "Number of Opens",
                 value = 10,
                 min = 1,
                 max = 10000,
                 step = 10),
    
     actionButton(inputId = "submit",label = "Run Program"),
    downloadButton("get.data",label = "Download This Table")
    
    
    
    ), 
    mainPanel(
      h2("a table of your draws"),
      tableOutput("the.hands")
    )
  )
))