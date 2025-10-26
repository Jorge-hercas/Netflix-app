


body <- dashboardBody(
  chooseSliderSkin("Flat"),
  add_busy_spinner(position = "bottom-left", color = "#a34043", spin = "folding-cube"),
  tabItems(
    tabItem(
      tabName = "general",
      fluidRow(
        valueBox(value = h4(strong(countupOutput("general_count") )), subtitle = "Total calls" , gradient = T, color = "primary",
                 icon = icon("money-bill"), footer = paste0("In all the time" ) ),
        valueBox(value = h4(strong(countupOutput("avg_time_to_waite") )), subtitle = "Avg minutes to finish a call", gradient = T, color = "secondary",
                 icon = icon("sack-dollar"), footer = "In all the time" ),
        valueBox(value =h4(strong(countupOutput("percent_suc") )), subtitle = "Sucessfull rate", gradient = T, color = "secondary",
                 icon = icon("road"), footer =  "In all the time" ),
        valueBox(value = h4(strong( countupOutput("avg_waite_time")  )),
                 subtitle = "Avg secs to waite until get answered", gradient = T, color = "primary",icon = icon("percent"), footer = paste0("In all the time" ))
      ),
      prettySwitch(
        inputId = "proyeccion_ver",
        label = "Only answered calls?",
        status = "success",
        fill = TRUE
      ),
      column(width = 12,
             box(
               title = "General view - Total calls along time",
               width = 12,
               height = 400,
               maximizable = T,
               echarts4rOutput("general", height = "100%")
               )
            ),
      fluidRow(
        column(
          width = 6,
          box(
            width = 12,
            title = "Call center effectiveness percentage on first call",
            reactableOutput("effectiveness")
          )
        ),
        column(
          width = 6,
          box(
            width = 12,
            title = "Total calls per call center",
            echarts4rOutput("pie")
          )
        )
      )
      
    ),
    tabItem(
      tabName = "details",
      column(width = 12,
             align = "center",
             box(
               width = 12,
               title = "Call centers utilization analysis",
               reactableOutput("utilizacion", height = "400px")
                )
             ),
      fluidRow(column(width = 8,
                      align = "center",
                      box(
                        width = 12,
                        echarts4rOutput("utilizacion_graf")
                      )
      ),
      column(
        width = 4,
        align = "center",
        box(
          width = 12,
          title = "% average utilization",
          echarts4rOutput("utilization_global")
        )
      ))
      
      
    )
    
    
  )
)