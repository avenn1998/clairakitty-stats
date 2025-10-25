library(shiny)
library(plotly)
library(dplyr)
library(readr)
library(tidyr)
library(lubridate)

# Read the data
data <- read_csv("clairakitty_ao3_work_stats.csv") |>
    dplyr::mutate(day = lubridate::date(time)) |>
    dplyr::group_by(work_title, day) |>
    dplyr::summarize(kudos = max(kudos),
        hits = max(hits),
        bookmarks = max(bookmarks),
        comments = max(comments),
        words = max(words),  # Keep words column
        .groups = "drop") |>
    dplyr::group_by(work_title) |>
    dplyr::mutate(new_kudos = kudos - lag(kudos),
        new_hits = hits - lag(hits),
        new_bookmarks = bookmarks - lag(bookmarks),
        new_comments = comments - lag(comments))

# Remove test row
data <- data %>% filter(work_title != "test")

# Get unique work titles
work_titles <- sort(unique(data$work_title))

# Create a color palette with enough distinct colors for all works
n_works <- length(work_titles)
colors <- colorRampPalette(c("#e41a1c", "#377eb8", "#4daf4a", "#984ea3", 
                              "#ff7f00", "#ffff33", "#a65628", "#f781bf",
                              "#1b9e77", "#d95f02", "#7570b3", "#e7298a",
                              "#66a61e", "#e6ab02", "#a6761d", "#666666"))(n_works)
color_map <- setNames(colors, work_titles)

# UI
ui <- fluidPage(
  titlePanel("AO3 Work Statistics Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput(
        "works",
        "Select Works:",
        choices = work_titles,
        selected = work_titles
      ),
      actionButton("select_all", "Select All"),
      actionButton("deselect_all", "Deselect All"),
      width = 3
    ),
    
    mainPanel(
      plotlyOutput("summary_bar", height = "700px"),
      hr(),
      plotlyOutput("kudos_plot", height = "300px"),
      plotlyOutput("hits_plot", height = "300px"),
      plotlyOutput("bookmarks_plot", height = "300px"),
      plotlyOutput("comments_plot", height = "300px"),
      width = 9
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Select/Deselect all buttons
  observeEvent(input$select_all, {
    updateCheckboxGroupInput(session, "works", selected = work_titles)
  })
  
  observeEvent(input$deselect_all, {
    updateCheckboxGroupInput(session, "works", selected = character(0))
  })
  
  # Reactive filtered data
  filtered_data <- reactive({
    req(input$works)
    data %>% filter(work_title %in% input$works)
  })
  
  # Get most recent values for each work
  recent_data <- reactive({
    filtered_data() %>%
      group_by(work_title) %>%
      arrange(desc(day)) %>%
      slice(1) %>%
      ungroup()
  })
  
  # Summary bar chart with facets
  output$summary_bar <- renderPlotly({
    df <- recent_data()
    
    # Create separate plots for each metric
    p1 <- plot_ly(df, x = ~work_title, y = ~kudos, type = 'bar',
                  name = 'Kudos', marker = list(color = '#e41a1c')) %>%
      layout(xaxis = list(title = "", tickangle = -45),
             yaxis = list(title = "Kudos"),
             showlegend = FALSE)
    
    p2 <- plot_ly(df, x = ~work_title, y = ~comments, type = 'bar',
                  name = 'Comments', marker = list(color = '#984ea3')) %>%
      layout(xaxis = list(title = "", tickangle = -45),
             yaxis = list(title = "Comments"),
             showlegend = FALSE)
    
    p3 <- plot_ly(df, x = ~work_title, y = ~bookmarks, type = 'bar',
                  name = 'Bookmarks', marker = list(color = '#4daf4a')) %>%
      layout(xaxis = list(title = "", tickangle = -45),
             yaxis = list(title = "Bookmarks"),
             showlegend = FALSE)
    
    p4 <- plot_ly(df, x = ~work_title, y = ~hits, type = 'bar',
                  name = 'Hits', marker = list(color = '#377eb8')) %>%
      layout(xaxis = list(title = "", tickangle = -45),
             yaxis = list(title = "Hits"),
             showlegend = FALSE)
    
    p5 <- plot_ly(df, x = ~work_title, y = ~words, type = 'bar',
                  name = 'Words', marker = list(color = '#ff7f00')) %>%
      layout(xaxis = list(title = "Work Title", tickangle = -45),
             yaxis = list(title = "Words"),
             showlegend = FALSE)
    
    # Combine into subplots with independent y-axes
    subplot(p1, p2, p3, p4, p5, nrows = 5, shareX = TRUE, titleY = TRUE) %>%
      layout(title = "Most Recent Statistics by Work (Independent Scales)",
             hovermode = "closest")
  })

  # Kudos plot
  output$kudos_plot <- renderPlotly({
    df <- filtered_data()
    
    plot_ly(df, x = ~day, y = ~new_kudos, color = ~work_title,
            colors = color_map[unique(df$work_title)],
            type = 'scatter', mode = 'lines+markers') %>%
      layout(
        title = "New Kudos Over Time",
        xaxis = list(title = "Date"),
        yaxis = list(title = "New Kudos"),
        hovermode = "closest"
      )
  })
  
  # Hits plot
  output$hits_plot <- renderPlotly({
    df <- filtered_data()
    
    plot_ly(df, x = ~day, y = ~new_hits, color = ~work_title,
            colors = color_map[unique(df$work_title)],
            type = 'scatter', mode = 'lines+markers') %>%
      layout(
        title = "New Hits Over Time",
        xaxis = list(title = "Date"),
        yaxis = list(title = "New Hits"),
        hovermode = "closest"
      )
  })
  
  # Bookmarks plot
  output$bookmarks_plot <- renderPlotly({
    df <- filtered_data()
    
    plot_ly(df, x = ~day, y = ~new_bookmarks, color = ~work_title,
            colors = color_map[unique(df$work_title)],
            type = 'scatter', mode = 'lines+markers') %>%
      layout(
        title = "New Bookmarks Over Time",
        xaxis = list(title = "Date"),
        yaxis = list(title = "New Bookmarks"),
        hovermode = "closest"
      )
  })
  
  # Comments plot
  output$comments_plot <- renderPlotly({
    df <- filtered_data()
    
    plot_ly(df, x = ~day, y = ~new_comments, color = ~work_title,
            colors = color_map[unique(df$work_title)],
            type = 'scatter', mode = 'lines+markers') %>%
      layout(
        title = "New Comments Over Time",
        xaxis = list(title = "Date"),
        yaxis = list(title = "New Comments"),
        hovermode = "closest"
      )
  })
}

# Run the app
shinyApp(ui = ui, server = server)