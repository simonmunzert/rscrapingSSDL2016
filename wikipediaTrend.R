### -----------------------------
### exploring Wikipedia page view statistics
### simon munzert
### -----------------------------


## goals ------------------------

# fetch Wikipedia page view statistics
# explore them 


## tasks ------------------------

# access statistics (JSON format)
# import JSON into R
# tidy data
# exploration


## packages ---------------------

library(rvest)
library(jsonlite)
library(stringr)
library(wikipediatrend)


## directory --------------------

wd <- ("./data/wikipediaTrend")
dir.create(wd)
setwd(wd)


## code -------------------------

## step 1: manually access data
# fetch data
url  <- "http://stats.grok.se/json/en/latest90/Pegida"
json <- html_text(html(url)) 

# inspect data
cat(str_c(unlist(str_split(json, ",")),",\n")[1:13],"\n...")
data  <- fromJSON(json)
summary(data)
        
# tidy data
date  <- as.Date(names(data$daily_views))
views <- unlist(data$daily_views)

plot( date, views,  
      type = "h", 
      col  = "#F54B1A90",
      lwd=3, 
      main="Pegida Page Views on Wikipedia (en)")
lines(lowess(views ~ date, f=.1), col = "#1B346C90", lwd=5)




## step 2: automate the process

# processing function
wpTrend <- function(page, lang="en", 
                     year="2015", month="01"){
  # retrieving data
  tmp <- wpGetData(page, lang, year, month)
  # transforming data
  tmp <- wpTransformData(tmp)
  # return
  return(tmp)
}

# call function
wpGetData <- function(page, lang, year, month){
  require(httr)
  base_url <- "http://stats.grok.se/json/"  
  url <- paste0(
    base_url, 
    lang, "/",
    year, month, "/",
    page
  )
  content(GET(url), "text")
}

tmp <- wpGetData("Bamberg", lang="en", 
                   year=2015, month="01")
tmp
fromJSON(tmp)


# tidy function
wpTransformData <- function(data){
  require(jsonlite)
  data <- fromJSON(data)
  data <- 
    data.frame(date  = as.Date(names(data$daily_views)),
               views = as.numeric(data$daily_views),
               lang  = data$project,
               page  = data$title, 
               rank  = data$rank
    )
  return(data)
}

wpTransformData(tmp)



# apply 
cats <- wpTrend(page="cat")
dogs <- wpTrend(page="dog")
plot(cats[,1:2], col = "#F54B1A90", pch=19)
points(dogs[,1:2], col = "#1B346C90", pch=19)
legend("topleft", col=c("#F54B1A90","#1B346C90"), legend=c("cat","dog"), pch=19)
lines(lowess(cats), col="#F54B1A90", lwd=5)
lines(lowess(dogs), col="#1B346C90", lwd=5)


## step 3: use the wikipediatrend package to do the work
browseURL("https://github.com/petermeissner/wikipediatrend")
ls("package:wikipediatrend")
?wp_trend

pegida <- wp_trend(page = "Pegida", from = Sys.Date() - 150, to = Sys.Date(), lang = "en", friendly = T, requestFrom = "anonymous", userAgent = F)
class(pegida)
plot(pegida, pch = 19, type = "l")

