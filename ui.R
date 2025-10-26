
frontend <-
dashboardPage(
  #dark = as.numeric(format(Sys.time(), "%H")) >= 23,
  header = dashboardHeader(
    compact = T,
    status = "gray-dark",
    sidebarIcon = icon("house"),
    controlbarIcon = icon("filter"),
    rightUi = tagList(
      userOutput("user")
    )
  ),
  sidebar = dashboardSidebar(
    status = "secondary",
    minified = F,
    elevation = 4,
    fixed = T,
    skin = "light",
    bs4SidebarUserPanel("Operations Dashboard",
                        image = "https://static.vecteezy.com/system/resources/previews/017/396/804/non_2x/netflix-mobile-application-logo-free-png.png"),
    sidebarMenu(
      id = "current_tab",
      sidebarHeader("Menú"),
      menuItem(
        "Global Overview",
        tabName = "general",
        icon = icon("earth-americas")
      ),
      menuItem(
        "Capacity Ops",
        tabName = "details",
        icon = icon("file-invoice")
      )
    )
  ),
  body = body,
  controlbar = dashboardControlbar(
    skin = "light",
    collapsed = T,
    width = 350,
    id = "controlbar",
    controlbarMenu(
      id = "menu",
      controlbarItem(
        "Filtros",
        "Filtros generales:",
        br(),br(),
        column(width = 12, 
               align = "center",
               pickerInput("skills_t_input", "Skills type",
                           choices = unique(SKILL_DATA$Skill_type),
                           selected = unique(SKILL_DATA$Skill_type),
                           multiple = T, options = opts
               ),
               pickerInput("skill_input", "Skills",
                           choices = unique(SKILL_DATA$Skill),
                           selected = unique(SKILL_DATA$Skill),
                           multiple = T, options = opts
               ),
               pickerInput("lang_input", "Language",
                           choices = unique(SKILL_DATA$Language),
                           selected = unique(SKILL_DATA$Language),
                           multiple = T, options = opts
               ),
               pickerInput("callc_input", "Call center",
                           choices = unique(SKILL_DATA$`Call Center`),
                           selected = unique(SKILL_DATA$`Call Center`),
                           multiple = T, options = opts
               ),
               airDatepickerInput("fecha_rotacion", "Rango de fechas", 
                                  multiple = T, range = T, 
                                  value = c(min(SKILL_DATA$`UTC Week (Sun-Sat)`),
                                            max(SKILL_DATA$`UTC Week (Sun-Sat)`) 
               ) )
               
            )
      )
    )
  ),
  footer = dashboardFooter(
    right = paste0("Netflix, ", year(today())),
    left = "Build by data analytics department",
    fixed = T
  )
)


secure_app(frontend,choose_language = FALSE,
           tags_top =
             tags$div(
               tags$img(
                 src = "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/Netflix_2015_N_logo.svg/1128px-Netflix_2015_N_logo.svg.png", width = 100
               )
             ),
           theme = shinythemes::shinytheme("darkly"),
           background  = "linear-gradient(rgba(0, 0, 0, 0.5),
                    rgba(0, 0, 0, 0.5)),
                    url('https://wallpaperaccess.com/full/1686771.jpg')
                    no-repeat center fixed;
                    -webkit-background-size: cover;
                    -moz-background-size: cover;
                    -o-background-size: cover;
                    background-size: cover;")




