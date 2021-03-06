
# ------------------------------------------------------------------------ #
#
# Descriptif : Radio Group Buttons : fonctions R
#        Via : http://getbootstrap.com/javascript/#buttons-checkbox-radio
#
#
# Auteur : Victor PERRIER
#
# Date creation : 01/07/2016
# Date modification : 01/07/2016
#
# Version 1.0
#
# ------------------------------------------------------------------------ #


#' @title Buttons Group Radio Input Control
#'
#' @description
#' Create buttons grouped that act like radio buttons.
#'
#' @param inputId The \code{input} slot that will be used to access the value.
#' @param label Input label.
#' @param choices List of values to select from (if elements of the list are named then that name rather than the value is displayed to the user).
#' @param selected The initially selected value.
#' @param status Color of the buttons
#' @param size Size of the buttons ('xs', 'sm', 'normal', 'lg')
#' @param direction Horizontal or vertical
#' @param justified If TRUE, fill the width of the parent div
#' @param individual If TRUE, buttons are separated.
#' @param checkIcon A list, if no empty must contain at least one element named 'yes' corresponding to an icon to display if the button is checked.
#' @return A buttons group control that can be added to a UI definition.
#'
#'
#' @examples
#' \dontrun{
#' ## Only run examples in interactive R sessions
#' if (interactive()) {
#'
#' ui <- fluidPage(
#'   radioGroupButtons(inputId = "somevalue", choices = c("A", "B", "C")),
#'   verbatimTextOutput("value")
#' )
#' server <- function(input, output) {
#'   output$value <- renderText({ input$somevalue })
#' }
#' shinyApp(ui, server)
#' }
#' }
#'
#' @import shiny
#' @importFrom htmltools htmlDependency attachDependencies
#'
#' @export


radioGroupButtons <- function(
  inputId, label = NULL, choices, selected = NULL, status = "default", size = "normal",
  direction = "horizontal", justified = FALSE, individual = FALSE, checkIcon = list()
) {
  choices <- choicesWithNames(choices)
  if (!is.null(selected) && length(selected) > 1)
    stop("selected must be length 1")
  if (is.null(selected))
    selected <- choices[1]
  size <- match.arg(arg = size, choices = c("xs", "sm", "normal", "lg"))
  direction <- match.arg(arg = direction, choices = c("horizontal", "vertical"))
  status <- match.arg(arg = status, choices = c("default", "primary", "success", "info", "warning", "danger"))

  if (!is.null(checkIcon) && !is.null(checkIcon$yes)) {
    displayIcon <- TRUE
  } else {
    displayIcon <- FALSE
  }

  divClass <- if (individual) "" else "btn-group"
  if (!individual & direction == "vertical") {
    divClass <- paste0(divClass, "-vertical")
  }
  if (justified) {
    divClass <- paste(divClass, "btn-group-justified")
  }
  if (size != "normal") {
    divClass <- paste0(divClass, " btn-group-", size)
  }


  if (individual) {
    # div_class <- gsub(pattern = "btn-group ", replacement = "", x = div_class)
    btn_wrapper <- tagList
  } else {
    btn_wrapper <- function(...) {
      tags$div(
        class="btn-group",
        class=if (size != "normal") paste0("btn-group-", size),
        role="group",
        ...
      )
    }
  }

  radioGroupButtonsTag <- tagList(
    tags$div(
      id=inputId, class="radioGroupButtons", # , class="shiny-input-container"
      if (!is.null(label)) tags$label(class="control-label", `for`=inputId, label),
      if (!is.null(label)) br(),
      style="margin-top: 3px; margin-bottom: 3px; ",
      style=if (justified) "width: 100%;",
      tags$div(
        class=divClass, role="group", `aria-label`="...", `data-toggle`="buttons",
        lapply(
          X = seq_along(choices),
          FUN = function(i) {
            tags$div(
              class="btn-group",
              class=if (size != "normal") paste0("btn-group-", size),
              role="group",
              tags$button(
                class=paste0("btn radiobtn btn-", status),
                class=if (choices[i] %in% selected) "active",
                type="button",
                if (displayIcon) tags$span(class="radio-btn-icon-yes", checkIcon$yes),
                if (displayIcon) tags$span(class="radio-btn-icon-no", checkIcon$no),
                tags$input(
                  type="radio", autocomplete="off", HTML(names(choices)[i]),
                  name=inputId, value=choices[i],
                  checked=if (choices[i] %in% selected) "checked"
                )
              )
            )
          }
        )
      )
    )
  )

  # Dep
  dep <- htmltools::htmlDependency(
    name = "radioGroupButtons", version = "0.1.0", src = c(href="shinyWidgets"),
    script = "radioGroupButtons/radioGroupButtons-bindings.js",
    stylesheet = "radioGroupButtons/radioGroupButtons.css"
  )
  htmltools::attachDependencies(radioGroupButtonsTag, dep)
}




#' @title Change the value of a radio group buttons input on the client
#'
#' @description
#' Change the value of a radio group buttons input on the client
#'
#' @param session The session object passed to function given to shinyServer.
#' @param inputId	The id of the input object.
#' @param selected The value selected.
#'
#' @export

updateRadioGroupButtons <- function(session, inputId, selected = NULL) {
  message <- dropNulls(list(selected = selected))
  session$sendInputMessage(inputId, message)
}

