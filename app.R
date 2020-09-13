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

    title = "Switzerland Quarantine List",

    windowTitle = "Switzerland Quarantine List",

    tabPanel(
      title = "Graph",

      icon = icon(name = "map-marked-alt"),

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

      icon = icon(name = "chart-bar")
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
