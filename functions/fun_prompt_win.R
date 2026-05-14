require(tcltk)

#------------------------------------#
#--> special thanks to Mistral AI <--#
#------------------------------------#

# Create a function to show a pop-up input dialog
get_user_input <- function() {
  # Create a new top-level window
  win <- tktoplevel()
  tkwm.title(win, "Input Dialog")
  
  # Add a label
  label <- tklabel(win, text = "Please enter your input:")
  tkpack(label, side = "top", padx = 10, pady = 10)
  
  # Add an entry widget for user input
  entry <- tkentry(win, width = 50)
  tkpack(entry, side = "top", padx = 10, pady = 5)
  
  # Add an OK button
  on_ok <- function() {
    input_value <<- tclvalue(tkget(entry))
    tkdestroy(win)
  }
  ok_button <- tkbutton(win, text = "OK", command = on_ok)
  tkpack(ok_button, side = "left", padx = 10, pady = 10)
  
  # Add a Cancel button
  on_cancel <- function() {
    input_value <<- NULL
    tkdestroy(win)
  }
  cancel_button <- tkbutton(win, text = "Cancel", command = on_cancel)
  tkpack(cancel_button, side = "right", padx = 10, pady = 10)
  
  # Bind the Enter key to the on_ok function
  tkbind(entry, "<Return>", function() on_ok())
  
  # Bind the Escape key to the on_cancel function
  tkbind(win, "<Escape>", function() on_cancel())
  
  # Focus the window and the entry field
  tkraise(win)          # Bring window to front
  tkfocus(win)          # Focus the window
  tkfocus(entry)        # Focus the entry field
  
  # Wait for the window to be closed
  tkwait.window(win)
  
  # Return the user input
  return(input_value)
}

