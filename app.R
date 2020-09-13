# ---- Load libraries ----
library(shiny)
library(dplyr)
library(DT)
library(sever)
library(waiter)
library(echarts4r)

# ---- Load data ----


# ---- Prep data ----


# ---- Shiny ui -----
ui <-

  navbarPage(

    title = div(
      h3("Switzerland Quarantine",
        style = "position:absolute;left:75px;margin-top:-2px;"
      ),
      img(
        src = "logo.png",
        style = "margin-top:-20px;padding-right:280px;padding-bottom:10px;padding-top:10px;",
        height = 60
      )
    ),

    windowTitle = "Switzerland Quarantine List",

    tabPanel(
      title = "Graph",

      icon = icon(name = "chart-bar"),

      # - Error and waiting functions to improve UX -
      use_sever(),
      use_waiter(),
      waiter_show_on_load(html = tagList(
        spin_5(),
        div(p("Calculating COVID-19 infection rates"), style = "padding-top:25px;")
      )),

      div(
        class = "outer",

        tags$head(
          # Include our custom CSS
          includeCSS("styles.css")
        )
      )
    ),

    tabPanel(
      title = "Data",

      icon = icon(name = "table")
    )
  )

# ---- Shiny server ----
server <-
  function(input, output, session) {

    # - Error messages -
    sever()

    # - Waiter -
    waiter_hide()
  }

# ---- Run app ----
shinyApp(ui = ui, server = server)
