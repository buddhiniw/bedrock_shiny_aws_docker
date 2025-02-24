source("data_checks.R")

shinyServer(function(input, output, session) {
  
  tablist <- NULL
  
  #**************************************************
  #  UI code
  #**************************************************
  
  # for code development.
  output$ui <- renderUI({
    
    if (user_input$authenticated == FALSE) {

      ##### Login Interface
      fluidPage(
        #theme = shinytheme("cosmo"),

        ## Applicatin name
        titlePanel("Bedrock Stat Analytics"),
       
         fluidRow(
          column(width = 5, offset = 2,
                 br(), br(), br(), br(),
                 uiOutput("uiLogin"),
                 uiOutput("pass")
          )
        )
      )
    } else {
      #### Apps Interface
      fluidPage(
       #theme = shinytheme("cosmo"),
       #shinythemes::themeSelector(),  # <--- Add this somewhere in the UI
        
        ## Applicatin name
        titlePanel("Bedrock Stat Analytics"),
        
        ## Side bar
        sidebarLayout(
          sidebarPanel(
            fileInput("file1", "1. Upload the CSV Data File",
                      multiple = FALSE,
                      accept = c("text/csv",
                                 "text/comma-separated-values,text/plain",
                                 ".csv")),
            
            selectInput("regression",
                        "2. Select Regression Option & Run Analysis",
                        c("Elasticnet (n<p)"="enet","OLS (n>p)"="ols")),
            actionButton("analyze","Analyze"),
            br(),br(),br(),
            
            "3. Download the Report\n",
            downloadButton("bedrock_analytics_report","Download PDF")
            
          ),
          
          ## Main panel for displaying outputs 
          mainPanel(
            # Output: Tabset for instructions, raw data and analysis results
            tabsetPanel(id = "tabs",
                        tabPanel("Home", pre(includeText("introduction.txt"))),
                        tabPanel("Instructions", pre(includeText("instructions.txt"))),
                        tabPanel("Case Study", pre(includeText("case_study.txt")))
                        )
          )
        )
      )
    }
  })
  
  #**************************************************
  #  ANALYSIS Server code
  #**************************************************
  
  ##########################
  # 1. Load data file and check for formatting
  ##########################
  
  observeEvent(input$file1, {

    # If data format is not correct show the error msg
    if(!(valid_input_data(dat_file = input$file1$datapath))){
      showModal(
        modalDialog(
          title = "Error!",
          "Uploaded data file contains errors. Please follow the guidelines given in the Instructions tab and upload a csv dat file with the correct format."
        )
    )
      
    } else {
 
      # data quality is good so show the data file in a new tab
      clearTabs("Input Data")
      clearTabs("Results")

      tablist <<-c("Instructions")
      insertTab(inputId = "tabs",
                tabPanel("Input Data", renderTable(datasetInput())),
                target = "Instructions",
                position = "after"
        
      )
      tablist <<- c(tablist, "Input Data")  
    }
  })
  
  
  
  # Reactive expression to get the datafile 
  datasetInput <- reactive({
    req(input$file1)

    if(is.null(input$file1)) return(NULL)
    
    tryCatch({
      dataIn <- read.csv(input$file1$datapath,header = T)
      names(dataIn) <- sub("([a-z])([A-Z])", "\\1 \\2", names(dataIn))
      dataIn <- dataIn
    },
    error = function(e) {
      # return a safeError if a parsing error occurs
      stop(safeError(e))
    })
  })

  
  ###########
  # 2. Run analysis
  ###########
  
  # reactive value containing regression type
  reg_input <- reactiveValues(
    value = "enet" #default
  )
  

  # pick the selected regressoin value from list
  observeEvent(input$regression, {
    reg_input$value <- input$regression
  })
  
  
  # Analyze data when button is clicked.
  observeEvent(input$analyze, {
    
    generateHTML()

    # insert a tab for results
    insertTab(inputId = "tabs",
              tabPanel("Results", includeHTML(paste0(reg_input$value,"_html.html"))),
              target = "Input Data",
              position = "after"
    )
    tablist <<- c(tablist, "Results")        
  })

  
  clearTabs <- function(tabname){
    # If tab exists, remove it
    if(tabname %in% tablist) {
      #remove the data tab
      removeTab(inputId = "tabs", target = tabname)
    }
  }
  
  # Generate html output
  generateHTML <- reactive({
    
    withProgress(message = 'Analysis in progress',
                 detail = 'This may take a while...', value = 0, {
                    for (i in 1:1) {
                      incProgress(1/2)
                      Sys.sleep(0.05)
                    
                 
    
    dataIn <- read.csv(input$file1$datapath,header = T)
    params <- list(dat_data =  datasetInput(), dat_file = input$file1$name)
    tempHTML <- paste0(reg_input$value,"_html.Rmd")
    rmarkdown::render(tempHTML,
                      params = params,
                      envir = new.env(parent = globalenv()))
                    }      
                 })
    
  })

  
  
  # Generate pdf report
  generateReport <- reactive({
    # Set up parameters to pass to Rmd document
    dataIn <- read.csv(input$file1$datapath,header = T)
    print(input$file1$datapath)
    #params <- list(dat_data = dataIn, dat_file = input$file1$name)
    params <- list(dat_data =  datasetInput(), dat_file = input$file1$name)
    
    tempReport <- paste0(reg_input$value,"_pdf.Rmd")
    print(tempReport)
    rmarkdown::render(tempReport,"pdf_document",
                      params = params,
                      envir = new.env(parent = globalenv()))

  })

  
  output$bedrock_analytics_report <- downloadHandler(

    filename = "bedrock_analytics_report.pdf",
    content = function(file) {
      # use file.copy to provide the file "in" the save-button
      generateReport()
      file.copy(paste0(reg_input$value,"_pdf.pdf"), file)
    }
  )

  
  
  #**************************************************
  #  PASSWORD Server code
  #**************************************************
  # reactive value containing user's authentication status
  user_input <- reactiveValues(authenticated = FALSE, valid_credentials = FALSE, 
                               user_locked_out = FALSE, status = "")
  
  
  # dataframe that holds usernames, passwords and other user data
  user_db <- data.frame(
    user = c("Ason", "Ason2"),
    password = c("Ason123", "Ason234"), 
    permissions = c("admin", "standard"),
    name = c("Ason", "Standard User"),
    stringsAsFactors = FALSE
  )
  
  # authenticate user by:
  #   1. checking whether their user name and password are in the credentials 
  #       data frame and on the same row (credentials are valid)
  #   2. if user is not authenticated, determine whether the user name or the password 
  #       is bad (username precedent over pw). set status value for
  #       error message code below
  
  observeEvent(input$login_button, {
    # call login module supplying data frame, user and password cols
    # and reactive trigger

    row_username <- which(user_db$user == input$user_name)
    row_password <- which(user_db$password == input$password) # digest() makes md5 hash of password
    
    # if user name row and password name row are same, credentials are valid
    #   and retrieve locked out status
    if (length(row_username) == 1 && 
        length(row_password) >= 1 &&  # more than one user may have same pw
        (row_username %in% row_password)) {
      user_input$valid_credentials <- TRUE
      user_input$authenticated <- TRUE
    }
  
    # if user is not authenticated, set login status variable for error messages below
    if (user_input$authenticated == FALSE) {
      if (length(row_username) > 1) {
        user_input$status <- "credentials_data_error"  
      } else if (input$user_name == "" || length(row_username) == 0) {
        user_input$status <- "bad_user"
      } else if (input$password == "" || length(row_password) == 0) {
        user_input$status <- "bad_password"
      }
    }
  })
    
  
  
  #**************************************************
  #  Login screen
  #**************************************************
  output$uiLogin <- renderUI({
    wellPanel(
      textInput("user_name", "User Name:"),
      
      passwordInput("password", "Password:"),
      
      actionButton("login_button", "Log in")
    )
  })
  
  #**************************************************
  #  ERROR for bad credentials
  #**************************************************
  output$pass <- renderUI({
    if (user_input$status == "bad_user") {
      h5(strong("User name not found!", style = "color:red"), align = "center")
    } else if (user_input$status == "bad_password") {
      h5(strong("Incorrect password!", style = "color:red"), align = "center")
    } else {
      ""
    }
  })
  
})
