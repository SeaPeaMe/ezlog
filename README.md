# Description
This V module make it much easier to:
- Print text to the console with foreground/background/styling
- Sort logs using headings and indentation (see example usage)
- Easily print all logs to a file for further debugging

# Example Usage
## Print Formatted Text
Here are some examples on how to print text with different colors and styling:
```v
// Prints "Hello, World!" to the console in blue text
ezlog.print_formatted("Hello, World!", foreground_color: .blue)
```
```v
// Prints "Hello, World!" to the console in red text that is underlined
ezlog.print_formatted("Hello, World!", foreground_color: .red, styling: [ .underline ])
```
```v
// Prints "Hello, World!" to the console in bright cyan text that is bold, italicized and blinks
ezlog.print_formatted("Hello, World!", foreground_color: .bright_cyan, styling: [ .bold, .italic, .blink ])
```
## Print Text With Headings
Here is the general use of how to use the indentation:

<img width="316" height="108" alt="image" src="https://github.com/user-attachments/assets/bb4f38c4-b666-4586-a814-896164de8e46" />

```v
ezlog.start_section_heading("This is my Heading")

ezlog.log_message("Hello, World!")
ezlog.log_message("Hello, World In Green!", foreground_color: .green)

ezlog.start_section_heading("Here comes a subheading!")
ezlog.log_message("Hello, Subheading!")
ezlog.end_section()

ezlog.log_message("And we're back to the first heading again!")
ezlog.end_section()
```
## Caller Names
This module also generally enforces the use of having a "caller name" in the default log(), log_error(), etc. functions, as to make it easier to track down what is logging to the console.
```v
// This will print:
// "[Engine]: Starting Engine..."
// to the console
ezlog.log("Engine", "Engine Starting...")
```

## Write Logs To File
You can write logs to a file by using either creating a LogFile struct and passing in an 
os.File or by using `ezlog.open_log_file()`
```v
// Open a log file relative to the executable's location
mut log_file := ezlog.open_log_file("log.txt", "My Log") or { return }

// Do the same functions as with logging to the console, but just append "_file" to the name
// and pass in a mut reference to os.File
ezlog.start_section_file("Application", "This is my Heading", mut log_file)
ezlog.log_file("Application", "Hello, Heading!", mut log_file)
ezlog.log_file("Application", "Hello, Heading Again!", mut log_file)
ezlog.end_section_file(mut log_file)
log_file.close() // Don't forget to close the file after you're done with it!
```