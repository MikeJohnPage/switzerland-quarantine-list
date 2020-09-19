# ---- Load libraries ----
library(shiny)
library(dplyr)
library(DT)
library(sever)
library(waiter)
library(echarts4r)
library(stringr)
library(tidyr)

# ---- Load data ----
data <- read.csv("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv",
  na.strings = "", fileEncoding = "UTF-8-BOM"
)

# ---- Prep data ----
cases <-
  data %>%
  as_tibble() %>%
  select(
    Country = countriesAndTerritories,
    Date = dateRep,
    Cases = cases,
    Deaths = deaths,
    `Cumulative 14 day case rate per 100,000` = Cumulative_number_for_14_days_of_COVID.19_cases_per_100000
  ) %>%
  mutate(Date = as.Date(Date, format = "%d/%m/%Y")) %>%
  # Fill missing dates for each country with NA
  complete(nesting(Country), Date = seq(min(Date), max(Date), by = "day")) %>%
  filter(Date >= "2020-02-01") %>%
  arrange(Country, Date) %>%
  mutate(
    Date = format(Date, format = "%b %d"),
    Country = str_replace_all(Country, "_", " ")
  )

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
        ),

        sidebarLayout(
          sidebarPanel(
            selectInput(
              inputId = "countries",
              label = div(
                h2("Instructions"),
                p(
                  "Any countries that pass above the red threshold line",
                  tags$b(tags$i("may")),
                  "soon enter Switzerland's quarantine list. Select and remove countries
                  using the drop-down list below:"
                )
              ),
              choices = cases$Country,
              selected = c("Switzerland", "Italy"),
              multiple = TRUE
            )
          ),
          mainPanel(
            # - Line plot -
            echarts4rOutput("covid_plot")
          )
        ),
      )
    ),

    tabPanel(
      title = "Data",
      icon = icon(name = "table"),
      div(
        id = "data-table",
        DTOutput("data")
      )
    )
  )

# ---- Shiny server ----
server <-
  function(input, output, session) {

    # - Covid plot -
    output$covid_plot <- renderEcharts4r({
      cases %>%
        filter(Country %in% input$countries) %>%
        group_by(Country) %>%
        e_chart(x = Date) %>%
        e_line(serie = `Cumulative 14 day case rate per 100,000`, smooth = TRUE) %>%
        e_title("COVID-19 Infections", "Cases per 100,000") %>%
        e_mark_line(
          data = list(
            yAxis = 60,
            itemStyle = list(color = "red")
          ),
          symbol = "none",
          symbolSize = 10,
          title = "Threshold"
        ) %>%
        e_theme("westeros") %>%
        e_legend(left = "right") %>%
        e_tooltip(trigger = "axis") %>%
        e_datazoom(
          type = "slider",
          options = list(displayZoomButtons = FALSE)
        ) %>%
        e_toolbox(show = FALSE)
    })

    # - Data -
    output$data <- renderDT(
      datatable(cases,
        rownames = FALSE,
        escape = FALSE,
        extensions = c("ColReorder"),
        options = list(
          colReorder = TRUE
        )
      )
    )

    # - Error messages -
    sever()

    # - Waiter -
    waiter_hide()
  }

# ---- Run app ----
shinyApp(ui = ui, server = server)
