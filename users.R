


credentials <-
  tibble(
    user = c(
      "invitado"
    ),
    password = "12345",
    admin = F,
    nombre = c(
      "Colaborador"
    ),
    puesto = c(
      "General employer"
    ),
    prof_pic = c(
      "https://static.vecteezy.com/system/resources/previews/000/439/863/original/vector-users-icon.jpg"
    )
  )



set_labels(
  language = "en",
  "Please authenticate" = "Please authenticate",
  "Username:" = "User:",
  "Password:" = "Password:",
  "Login" = "Login")