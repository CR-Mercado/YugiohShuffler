
# Define server logic required 
shinyServer(function(input, output, session) {
  
  #read the file using library(officer)
  observeEvent(
    eventExpr = input[["submit"]],
    handlerExpr = {
      print("Running")
    }
  )
  #this starts once the "submit" button as been hit
  df <- eventReactive(input$submit,{ 
    
    #input the uploaded file
    inFile <- input$the.file
    #read the decklist
    the.deck <- readLines(inFile$datapath)
    
    .cards <- input$num.cards
    .hands <- input$num.hands
    # read it from its location [NOTE: uploaded files create a data frame of columns: name,size, type, datapath]  in datapath 
    
    shuffler(the.deck, .cards, .hands)
    
  })
  output$the.hands <- renderTable({
    df()
  })
  
  # Downloadable csv of selected dataset ----
  output$get.data <- downloadHandler(
    filename = function() {
      paste("DeckDraws", ".csv", sep = "")
    },
    content = function(file) {
      write.csv(df(), file, row.names = FALSE)
    }
  )
  
  # this closes the connection when the browser closes DO NOT USE THIS LINE ON REAL SERVERS!! Only for local deployed apps
  session$onSessionEnded(function() {
    stopApp()
    q("no")
  })
  
  
  
})



####################################### Functions on backend



#load decklist 
#read the txt file 
# get your hands 

shuffler <- function(x,n,num.hands){
  # this function samples N draws (without replacement) on x decklist to simulate an opening hand. 
  # allowing any number of hands, n 
  # it also allows for multiple draws of that number (with replacement) 
  
  #see decklist for details - formats the decklist into a list of each card, repeated
  x <- na.omit(decklist(x)) 

  if (length(x) < 40) 
    return("Your deck is too small, 40 card minimum")
  if (length(x) > 60) 
    return("Your deck is too large, 60 card maximum")
  if (num.hands < 1) 
    return("Please specify how many hands you'd like to draw")
  if (n < 5) 
    return("Please open with at least 5 cards")
  
  #originate no hands 
  i <- 0 
  hand.list <- NULL
  while(i < num.hands){
    hand.list <- rbind(hand.list,
                       sample(x,
                              n,
                              replace = FALSE
                       )
    )
    i <- i + 1 # count up     
  }
  
  colnames(hand.list) <- 1:n 
  
  
  return (hand.list)
  
}




#### functions used in core app #####


decklist <- function(x){
  # this app takes a decklist of the form "Nx CardName" with line breaks between each card
  #
  
  the.list <- NULL  #start out empty 
  
  for (i in 1:length(x)){  # loop through each line of the decklist
    the.list <- c(the.list,   # the list equals itself + 
                  multiplier(x[i])) # each new set of cards 
  }
  return (the.list)
}


multiplier <- function(x){
  # reads a line and looks for a number then an x  "3x" "2x" "1x"
  # it then returns all text after the x N number of times 
  # the x is where it is split 
  if (grepl("[a-z]",x)==FALSE)
  {return (NA)}  # x must have at least 1 letter. 
  
  # remove any random spaces 
  x <- na.omit(x) 
  
  if (grepl("^[1-9]x",x) == FALSE){  #if there isn't a number and an x 
    x <- paste("1x",x)    # assume 1
  }
  
  # swap "x" with "&&" so strsplit works on a unique symbol (other it splits at all "x" )
  
  x <- sub (pattern = "x","&&",x)
  num.of.card <- as.numeric(   # get the number, as a number 
    strsplit(x,    #by splitting 
             "&&")[[1]][1])  # at the "x"   i.e.  "3x bob" --> "3"  "bob" , here we get 3
  
  the.card <- strsplit(x,     # the second component is the name,                  here we get "bob"
                       "&&")[[1]][2]
  
  if(grepl("^ ",the.card) == TRUE){ # if it starts with a space " " 
    the.card <- sub(" ","",the.card) # remove that first space 
  }
  
  repeated.x <- rep(the.card, num.of.card)  # repeat the card, N number of times, 1 minimum 
  
  return (repeated.x) 
}

