# Description
This V module make it much easier to:
- Print text to the console with foreground/background/styling
- Sort logs using headings and indentation (see example usage)
- Easily print all logs to a file for further debugging

# Example Usage
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
Here is the general use of how to use the indentation:

<img width="316" height="108" alt="image" src="https://github.com/user-attachments/assets/bb4f38c4-b666-4586-a814-896164de8e46" />

```v
// This is optional, creates a log file relative to the executable's location
// and writes all uses of log, log_message, etc.
ezlog.set_log_file("log.txt", "=== BEGIN LOG ===")
ezlog.start_section_heading("This is my Heading")

ezlog.log_message("Hello, World!")
ezlog.log_message_formatted("Hello, World In Green!", foreground_color: .green)

ezlog.start_section_heading("Here comes a subheading!")
ezlog.log_message("Hello, Subheading!")
ezlog.end_section()

ezlog.log_message("And we're back to the first heading again!")
ezlog.end_section()
```
This module also generally enforces the use of having a "caller name" in the default log(), log_error(), etc. functions, as to make it easier to track down what is logging to the console.
```v
// This will print:
// "[Engine]: Starting Engine..."
// to the console
ezlog.log("Engine", "Engine Starting...")
```
