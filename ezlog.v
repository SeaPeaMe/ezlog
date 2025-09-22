module ezlog

import os

pub enum ConsoleForegroundColor {
    default = 0
    black = 30
    red
    green
    yellow
    blue
    purple
    cyan
    light_gray
    gray = 90
    bright_red
    bright_green
    bright_yellow
    bright_blue
    magenta
    bright_cyan
    white
}

pub enum ConsoleBackgroundColor {
    none = -1
    black = 40
    red
    green
    yellow
    blue
    purple
    cyan
    light_gray
    gray = 100
    bright_red
    bright_green
    bright_yellow
    bright_blue
    magenta
    bright_cyan
    white
}

pub enum ConsoleStyling {
    none = 0
    bold
    italic = 3
    underline
    blink
    reverse_text
    inverse_color
    hidden
    strikethrough
    overlined = 53
}

@[params]
pub struct ConsoleTextFormat {
  pub:
     foreground_color    ConsoleForegroundColor = .default
     background_color    ConsoleBackgroundColor
     styling             []ConsoleStyling
}

pub struct LogFile {
mut:
    indentation   int = 0
pub mut:
    file          os.File
}

// print_formatted prints a string of text to the console with a given set of styling conditions.
// # Example Usage
// The following will print "Hello, World!" to the console in blue, with bold and italics:
// `ezlog.print_formatted("Hello, World!", foreground_color: .blue, styling: [ .bold, .italic ])`
pub fn print_formatted(text string, format ConsoleTextFormat) {
    print("\e[${int(format.foreground_color).str()}m") // Foreground Color

    // Background Color
    if format.background_color != ConsoleBackgroundColor.none {
        print("\e[${int(format.background_color).str()}m")
    }

    for f in format.styling {
        print("\e[${int(f).str()}m") // Formatting
    }

    println("${text}\e[0m")
}

// print_formatted_file prints a string of text to the console with a given set of styling conditions, and
// writes the text to a given file.
pub fn print_formatted_file(text string, mut file LogFile, format ConsoleTextFormat) {
    print_formatted(text, format)
    file.file.writeln(text) or {  }
}

// start_section prints a heading in the format "[[caller_name]]: [message]", and
// indents any following calls to `log()`, `log_message()`, etc. by 1
pub fn start_section(caller_name string, message string, format ConsoleTextFormat) {
    log(caller_name, message, format)
    unsafe { delta_indentation(1) }
}

// start_section_file prints a heading in the format "[[caller_name]]: [message]",
// indents any following calls to `log()`, `log_message()`, etc. by 1 and
// writes the heading to the given file
pub fn start_section_file(caller_name string, message string, mut file LogFile, format ConsoleTextFormat) {
    log_file(caller_name, message, mut file, format)
    unsafe {
        delta_indentation(1)
        file.indentation += 1
    }
}

// start_section_heading prints a heading in the format "[message]", and
// indents any following calls to `log()`, `log_message()`, etc. by 1.
// This is essentially the same as `start_section`, but without a caller's name needing to be explicitly added
pub fn start_section_heading(message string, format ConsoleTextFormat) {
    log_message(message, format)
    unsafe { delta_indentation(1) }
}

// start_section_heading_file prints a heading in the format "[message]",
// indents any following calls to `log()`, `log_message()`, etc. by 1 and
// writes the heading to a given file
// This is essentially the same as `start_section_file`, but without a caller's name needing to be explicitly added
pub fn start_section_heading_file(message string, mut file LogFile, format ConsoleTextFormat) {
    log_message_file(message, mut file, format)
    unsafe {
        delta_indentation(1)
        file.indentation += 1
    }
}

// end_section ends the messages that should come under whatever heading/subheading name that was made in `start_section` or
// `start_section_heading`, and un-indents any following calls to `log()`, `log_message()`, etc. by 1.
pub fn end_section() {
    unsafe { delta_indentation(-1) }
}

// end_section_file ends the messages that should come under whatever heading/subheading name that was made in `start_section_file` or
// `start_section_heading_file`, and un-indents any following calls to `log_file()`, `log_message_file()`, 'log()`, etc. by 1.
pub fn end_section_file(mut file LogFile) {
    unsafe {
        delta_indentation(-1)
        file.indentation -= 1
    }
}

// log prints a message to the console in the format "[[caller_name]]: [message]" with specified styling
pub fn log(caller_name string, message string, format ConsoleTextFormat) {
    unsafe { print_indentations(delta_indentation(0)) }
    print_formatted("[${caller_name}]: ${message}", format)
}

// log_file prints a message to the console in the format "[[caller_name]]: [message]" with specified styling
// and writes to the file specified.
pub fn log_file(caller_name string, message string, mut file LogFile, format ConsoleTextFormat) {
    unsafe {
        print_indentations(delta_indentation(0))
        print_indentations_file(file.indentation, mut file)
    }
    print_formatted_file("[${caller_name}]: ${message}", mut file, format)
}

// log_message prints a message to the console in the format "[message]" with specified styling
// and prints to the file specified in `set_log_file` if it has been set.
// This is essentially the same as `log`, but without a caller's name needing to be explicitly added
pub fn log_message(message string, format ConsoleTextFormat) {
    unsafe { print_indentations(delta_indentation(0)) }
    print_formatted(message, format)
}

// log_message_file prints a message to the console in the format "[message]" with specified styling
// and writes to the file specified.
// This is essentially the same as `log_file`, but without a caller's name needing to be explicitly added
pub fn log_message_file(message string, mut file LogFile, format ConsoleTextFormat) {
    unsafe {
        print_indentations(delta_indentation(0))
        print_indentations_file(file.indentation, mut file)
    }
    print_formatted_file(message, mut file, format)
}

// log_error prints an error message to the console in the format "{ERROR} [[caller_name]]: [message]" in red
// and prints to the file specified in `set_log_file` if it has been set.
// Note that [print_back_trace] *does not* print to the file, just the console.
pub fn log_error(caller_name string, message string, print_back_trace bool) {
    unsafe { print_indentations(delta_indentation(0)) }
    log_message("{ERROR} [${caller_name}]: ${message}", foreground_color: .red)

    if print_back_trace {
        print_backtrace()
    }
}

// log_error_file prints an error message to the console in the format "{ERROR} [[caller_name]]: [message]" in red
// and prints to the file specified in `set_log_file` if it has been set.
// Note that [print_back_trace] *does not* print to the file, just the console.
pub fn log_error_file(caller_name string, message string, print_back_trace bool, mut file LogFile) {
    unsafe {
        print_indentations(delta_indentation(0))
        print_indentations_file(file.indentation, mut file)
    }
    log_message_file("{ERROR} [${caller_name}]: ${message}", mut file, foreground_color: .red)

    if print_back_trace {
        print_backtrace()
    }
}

// log_error_message prints an error message to the console in the format "{ERROR} [message]" in red
// and prints to the file specified in `set_log_file` if it has been set.
// Note that [print_back_trace] *does not* print to the file, just the console.
// This is essentially the same as `log_error`, but without a caller's name needing to be explicitly added
pub fn log_error_message(message string, print_back_trace bool) {
    unsafe { print_indentations(delta_indentation(0)) }
    log_message("{ERROR} ${message}", foreground_color: .red)

    if print_back_trace {
        print_backtrace()
    }
}

// log_error_message prints an error message to the console in the format "{ERROR} [message]" in red
// and prints to the file specified in `set_log_file` if it has been set.
// Note that [print_back_trace] *does not* print to the file, just the console.
// This is essentially the same as `log_error`, but without a caller's name needing to be explicitly added
pub fn log_error_message_file(message string, print_back_trace bool, mut file LogFile) {
    unsafe {
        print_indentations(delta_indentation(0))
        print_indentations_file(file.indentation, mut file)
    }
    log_message_file("{ERROR} ${message}", mut file, foreground_color: .red)

    if print_back_trace {
        print_backtrace()
    }
}

fn print_indentations(count int) {
    for _ in 0..count {
        unsafe {
            print(set_indentation_text_unsafe(""))
        }
    }
}

fn print_indentations_file(count int, mut file LogFile) {
    for _ in 0..count {
        unsafe {
            file.file.write_string(set_indentation_text_unsafe("")) or {  }
        }
    }
}

// set_indentation_text will set the text that pads all text used by ezlog. By default it is 3 spaces.
// Returns the currently used indentation characters.
pub fn set_indentation_text(text string) {
    unsafe { set_indentation_text_unsafe(text) }
}

// set_indentation_text_unsafe will set the text that pads all text used by ezlog. By default it is 3 spaces.
// Returns the currently used indentation characters.
// Note that if you pass a blank string "" into [text], the indentation will not be changed, and the current indentation characters
// will be returned instead
@[unsafe]
fn set_indentation_text_unsafe(text string) string {
    mut static indentation_text := "   "
    if text != "" {
        indentation_text = text
    }
    return indentation_text
}


@[unsafe]
fn delta_indentation(delta int) int {
    mut static indentation := 0
    indentation += delta
    return indentation
}

// open_log_file opens a file relative to the executable and writes the heading.
// This returns an os.File that can then be used to write logs to.
// *Don't forget to call `close()` on the file!*
pub fn open_log_file(log_file_name string, heading string) !LogFile {
    mut log_file := os.open_file(os.dir(os.executable()) + "/${log_file_name}", "w", 0)!
    log_file.writeln("=== ${heading} ===")!
    return LogFile {
        indentation: 0
        file: log_file
    }
}

// close closes the log file and allows other programs to access it
pub fn (mut file LogFile) close() {
    file.file.close()
}