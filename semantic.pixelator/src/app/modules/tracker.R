#' Allows collecting usage metrics on diferent events.
#'
#' @param session Current session object
#' @param category The category of the event
#' @param action The event action name
#' @param label The event description
trackEvent <- function(session, category, action, label) {
  session$sendCustomMessage(
    "trackEvent",
    list(
      category = category,
      action = action,
      label = label
    )
  )
}
