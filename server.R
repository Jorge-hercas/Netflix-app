

function(input, output, session){
  
  res_auth <- secure_server(
    check_credentials = check_credentials(credentials)
  )
  
  output$user <- renderUser({
    dashboardUser(
      name = res_auth$nombre,
      image = res_auth$prof_pic,
      title = res_auth$puesto,
      subtitle = "Netflix USA"
    )
  })
  
  
  data_reactive <- reactive({
    
    SKILL_DATA |> 
      filter(
        Skill %in% input$skill_input &
        Skill_type %in% input$skills_t_input &
        Language %in% input$lang_input &
        `Call Center` %in% input$callc_input &
        between(
          `UTC Week (Sun-Sat)`,
          min(input$fecha_rotacion),
          max(input$fecha_rotacion)
        )
      )
    
  })
  
  
  output$general <- renderEcharts4r({
    
    x <-
      data_reactive() |> 
      group_by(Skill_type, `UTC Week (Sun-Sat)`) |> 
      summarise(
        contacts = sum(
          if (input$proyeccion_ver) `[# Contacts Answered]` else `[# Contacts at BPO Skill]`,
          na.rm = TRUE
        )
      )
    
    max <-
      x |> 
      group_by(`UTC Week (Sun-Sat)`) |> 
      summarise(
        contacts = sum(contacts)
      )
    
    x |> 
      e_charts(`UTC Week (Sun-Sat)`, dispose = F) |> 
      e_bar(contacts, stack = "x") |> 
      e_theme("infographic") |>
      e_tooltip(trigger = "axis", confine = T,
                backgroundColor = "#fff"
      ) |>
      e_toolbox_feature(
        feature = "dataZoom"
      ) |> 
      e_y_axis(max = max(max$contacts)) |> 
      e_legend(
        textStyle = list(color = if_else(input$dark_mode == T, "#ffffff", "#000000"))
      )
    
  })
  
  
  output$effectiveness <- renderReactable({
    
    tabla_base <- data_reactive() |> 
      filter(`Call Center` != "Unknown Callcenter") |> 
      group_by(`Call Center`) |> 
      summarise(
        answered_calls = sum(`[# Contacts Answered]`),
        average_time_to_waite = mean(`[ASA Secs]`),
        success_rate = 1 - mean(`[RCR %]`)
      )
    
    media_global <- sum(tabla_base$success_rate * tabla_base$answered_calls) / sum(tabla_base$answered_calls)
    k <- mean(tabla_base$answered_calls)  
    
    
    tabla_resultado <- tabla_base |> 
      mutate(
        eficacia_ajustada = (success_rate * answered_calls + media_global * k) / (answered_calls + k)
      ) |> 
      arrange(desc(eficacia_ajustada))
    
    tabla_resultado |> 
      reactable(
        theme = nytimes(centered = TRUE, header_font_size = 11,background_color = "transparent"),
        defaultPageSize = 10,
        pagination = F,
        defaultColDef = colDef(headerStyle = list(background = "#081e3d", color = "#fff")),
        columns = list(
          answered_calls = colDef(
            format = colFormat(separators = T)
          ),
          success_rate = colDef(format = colFormat(percent = T, digits = 1)),
          average_time_to_waite = colDef(format = colFormat(digits = 1), name = "Avg waite time"),
          eficacia_ajustada = colDef(format = colFormat(percent = T, digits = 1)
          )
        )
      ) 
    
    
  })
  
  
  
  output$pie <- renderEcharts4r({
    
    data_reactive() |> 
      filter(
        `Call Center` != "Unknown Callcenter"
      ) |> 
      group_by(`Call Center`) |> 
      summarise(
        total_calls = sum(`[# Contacts at BPO Skill]`, na.rm = T)
      ) |> 
      arrange(desc(total_calls)) |> 
      e_charts(`Call Center`, dispose = F) |>
      e_pie(total_calls, radius = c("40%", "60%")) |>
      e_labels(show = TRUE,
               formatter = "{b} \n {c} \n {d}%",
               position = "outside",
               textStyle = list(
                 fontSize = 8)) |>
      e_theme("westeros") |>
      e_legend(bottom = 0, orient = "horizontal",textStyle = list(
        color = "gray",fontSize = 10)) |>
      e_tooltip(trigger = "item",
                confine = TRUE,
                textStyle = list(fontSize = 12)) |>
      e_color(background = "transparent") |>
      e_legend(bottom = 20,textStyle = list(
        color = "gray",
        fontSize = 10)) |>
      e_color(color = RColorBrewer::brewer.pal(12, "Spectral")) |>
      e_draft(text = "", size = "40px") |>
      e_toolbox_feature(feature = "dataView")
    
  })
  
  
  
  output$utilizacion <- renderReactable({
    
    CALL_CENTER_DATA |> 
      group_by(`Call Center`, `Capacity Plan`) |> 
      summarise(
        total_dias = n(),
        dias_sin_actividad = sum(is.na(`Occupancy %`) | is.na(`Utilization %`)),
        pct_dias_sin_actividad = dias_sin_actividad / total_dias,
        Occupancy_percent = mean(`Occupancy %`, na.rm = T),
        Utilization_percent = mean(`Utilization %`, na.rm = T)
      ) |> 
      arrange(desc(pct_dias_sin_actividad)) |> 
      mutate_if(
        is.numeric, replace_na, replace = 0
      ) %>% 
      reactable(
        theme = nytimes(centered = TRUE, header_font_size = 11,background_color = "transparent"),
        defaultPageSize = 10,
        pagination = F,
        defaultColDef = colDef(headerStyle = list(background = "#081e3d", color = "#fff")),
        columns = list(
          total_dias = colDef(name = "Total days"),
          dias_sin_actividad = colDef(name = "Days without activity",
                                      cell = data_bars(
                                        data = .,
                                        fill_color = 'firebrick',
                                        background = '#FFFFFF',
                                        bar_height = 7,
                                        text_position = 'outside-end',
                                        icon_color = 'firebrick',
                                        icon_size = 15,
                                        round_edges = TRUE
                                      )
          ),
          pct_dias_sin_actividad = colDef(name = "Percentage of inactivity", format = colFormat(percent = T, digits = 1)),
          Occupancy_percent = colDef(name = "Occupancy percentage", format = colFormat(percent = T, digits = 1)),
          Utilization_percent = colDef(name = "Utilization percentage", format = colFormat(percent = T, digits = 1))
        )
      )
    
    
  })
  
  
  output$utilizacion_graf <- renderEcharts4r({
    
    CALL_CENTER_DATA |> 
      group_by(`Call Center`) |> 
      summarise(
        Occupancy_percent = mean(`Occupancy %`, na.rm = T),
        Utilization_percent = mean(`Utilization %`, na.rm = T)
      ) |> 
      left_join(
        SKILL_DATA |> 
          group_by(`Call Center`) |> 
          summarise(
            Total_calls = sum(`[# Contacts at BPO Skill]`)
          ),
        by = c("Call Center" = "Call Center")
      ) |> 
      e_charts(`Call Center`) |> 
      e_bar(Total_calls) |> 
      e_line(Occupancy_percent, y_index = 1, symbol = "none") |> 
      e_line(Utilization_percent, y_index = 1, symbol = "none") |> 
      e_theme("infographic") |>
      e_tooltip(trigger = "axis", confine = T,
                backgroundColor = "#fff"
      ) |>
      e_toolbox_feature(
        feature = "dataZoom"
      ) |> 
      e_legend(
        textStyle = list(color = if_else(input$dark_mode == T, "#ffffff", "#000000"))
      )
    
  })
  
  
  output$utilization_global <- renderEcharts4r({
    
    tibble(val = c(
      mean(CALL_CENTER_DATA$`Utilization %`, na.rm = T),
      0.3),
      color = c("#f5edd7", "#f2b716")) |>
      e_charts(dispose = F) |>
      e_liquid(val,
               label = list( fontSize = 40),
               color = color,
               backgroundStyle = list(color = "#c5c9c6"),
               amplitude = 20,
               radius = "90%",
               outline = FALSE,
               shape = shape
      ) 
    
  })
  
  
  
  output$general_count <- renderCountup({
    
    total <- sum(data_reactive()$`[# Contacts at BPO Skill]`, na.rm = T)
    answer <- sum(data_reactive()$`[# Contacts Answered]`, na.rm = T)
    
    
    countup(
      sum(data_reactive()$`[# Contacts at BPO Skill]`, na.rm = T),
      options = list(
        suffix = paste0(" (", scales::percent(answer/total, accuracy = 1), " answered)")
      )
    )
    
  })
  
  
  output$avg_time_to_waite <- renderCountup({
    
    countup(
      round(mean(data_reactive()$AHT, na.rm = T), digits = 1)
    )
    
  })
  
  
  output$percent_suc <- renderCountup({
    
    countup(
      round((1-mean(data_reactive()$`[RCR %]`, na.rm = T))*100),
      options = list(
        suffix = "%"
      )
    )
    
  })
  
  
  output$avg_waite_time <- renderCountup({
    
    countup(
      mean(data_reactive()$`[ASA Secs]`, na.rm = T),
      options = list(
        suffix = " seconds"
      )
    )
    
  })
  
}







