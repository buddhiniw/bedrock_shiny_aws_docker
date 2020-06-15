#############################
# Helper functions to create Tables For MS Word .docx
#############################
#  Author by B. Waidyawansa (10/10/2018)


library(flextable)
library(officer)
library(tidyverse)
library(prettyR)
library(knitr)
library(broom)


options(knitr.table.format = "html") 


## @knitr descriptive_stat
###################################################################
# Descriptive statistics from unscaled data
###################################################################
# Get the original data frame minus the test data set
data<-dataIn[1:(nrow(dataIn)-1),]
data1 <- as.data.frame(describe(data ,num.desc=c("valid.n","mean","sd","min","max"))$Numeric)

data.t <- as.matrix(t(data1))
data.t <- formatC(data.t, digits = 2, format = "d", flag = "0")
colnames(data.t) <- c("N", "Mean", "Std. Dev.", "Min","Max")
bold <- function(x) {paste('{\\textbf{',x,'}}', sep ='')}

addtorow <- list()
addtorow$pos <- list(0, 0)
addtorow$command <- c("",
                      "Variable & N & Mean & Std. Dev. & Min & Max \\\\\n")

## @knitr descriptive_stat_pdf_table
print(xtable(data.t,align= "|l|c|r|r|r|r|"),
      comment=FALSE,
      add.to.row = addtorow, 
      include.colnames = FALSE,
      sanitize.colnames.function=bold,
      sanitize.rownames.function=bold,
      booktabs=F,
      floating = TRUE, latex.environments = "center", type="latex")

## @knitr descriptive_stat_html_table
kable(data.t)%>%
  kable_styling(bootstrap_options = c("striped", "hover"))

###################################################################
# Coefficients
###################################################################

# @knitr coefficients_table
## @knitr enet_coeff
data.c <- as.matrix(beta.hat$coefficients)
data.c <- formatC(data.c, digits = 3, format = "f", flag = "0")
colnames(data.c) <- c("Estimate")
bold <- function(x) {paste('{\\textbf{',x,'}}', sep ='')}

## @knitr enet_coeff_pdf_table
data.c <- formatC(data.c, digits = 3, format = "f", flag = "0")
colnames(data.c) <- c("Estimate")
bold <- function(x) {paste('{\\textbf{',x,'}}', sep ='')}

addtorow <- list()
addtorow$pos <- list(0, 0)
addtorow$command <- c("",
                      "Variable & Estimate \\\\\n")
print(xtable(data.c,
      align = "|l|r|"),
      add.to.row = addtorow, 
      include.colnames = FALSE,
      comment=FALSE,
      sanitize.colnames.function=bold,
      sanitize.rownames.function=bold,
      booktabs=F,
      floating = TRUE, latex.environments = "center")

## @knitr enet_coeff_html_table
kable(data.c)%>%
  kable_styling(bootstrap_options = c("striped", "hover"))


## @knitr ols_coeff
data.c <- as.matrix(beta.hat)
data.c <- formatC(data.c, digits = 3, format = "f", flag = "0")
#colnames(data.c) <- c("Estimate")
bold <- function(x) {paste('{\\textbf{',x,'}}', sep ='')}

## @knitr ols_coeff_html_table
kable(data.c)%>%
  kable_styling(bootstrap_options = c("striped", "hover"))

## @knitr ols_coeff_pdf_table
data.t <- as.matrix(data.c)

data.t <- formatC(data.t, digits = 2, format = "d", flag = "0")
colnames(data.t) <- c("Variable", "Estimate", "Std. Error.", "Statistic","P Value")
bold <- function(x) {paste('{\\textbf{',x,'}}', sep ='')}
print(xtable(data.t,
             align = "|l|r|r|r|r|r|"),
      comment=FALSE,
      sanitize.colnames.function=bold,
      sanitize.rownames.function=bold,
      booktabs=F,
      floating = TRUE, latex.environments = "center")


###################################################################
# Predicte Price
###################################################################

## @knitr predict_price
data.p <- as.matrix(cbind(y.hat,prediction.error, prediction.rsquared))
data.p <- formatC(data.p, digits = 3, format = "f", flag = "0")
colnames(data.p) <- c("Predicted Value", "Prediction Error", "R2")
rownames(data.p) <- c("")
bold <- function(x) {paste('{\\textbf{',x,'}}', sep ='')}
#data.p <-as.data.frame(data.p)
## @knitr predict_price_pdf

print(xtable(data.p,
             align = "|l|r|r|r|"),
      inculde.rownames = FALSE,
      comment=FALSE,
      sanitize.colnames.function=bold,
      sanitize.rownames.function=bold,
      booktabs=F,
      floating = TRUE, latex.environments = "center")

## @knitr predict_price_html
kable(data.p)%>%
  kable_styling(bootstrap_options = c("striped", "hover"))


## @knitr data_summary
#landscape(kable(dataIn, format = "html",longtable = TRUE))



