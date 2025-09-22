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

pub struct ConsoleTextFormat {
  pub:
     foreground_color    ConsoleForegroundColor = .default
     background_color    ConsoleBackgroundColor
     styling             []ConsoleStyling
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

// start_section prints a heading in the format "[[caller_name]]: [message]", and
// indents any following calls to `log()`, `log_message()`, etc. by 1
pub fn start_section(caller_name string, message string) {
    log(caller_name, message)
    unsafe { delta_indentation(1) }
}

// start_section_heading prints a heading in the format "[message]", and
// indents any following calls to `log()`, `log_message()`, etc. by 1.
// This is essentially the same as `start_section`, but without a caller's name needing to be explicitly added
pub fn start_section_heading(message string) {
    log_message(message)
    unsafe { delta_indentation(1) }
}

// end_section ends the messages that should come under whatever heading/subheading name that was made in `start_section` or
// `start_section_heading`, and un-indents any following calls to `log()`, `log_message()`, etc. by 1.
pub fn end_section() {
    unsafe { delta_indentation(-1) }
}

// log prints a message to the console in the format "[[caller_name]]: [message]" with default console colors,
// and prints to the file specified in `set_log_file` if it has been set.
pub fn log(caller_name string, message string) {
    unsafe { print_indentations(delta_indentation(0)) }
    print_formatted("[${caller_name}]: ${message}", ConsoleTextFormat{})
    append_line_to_log_file("[${caller_name}]: ${message}")
}

// log_message prints a message to the console in the format "[message]" with default console colors,
// and prints to the file specified in `set_log_file` if it has been set.
// This is essentially the same as `log`, but without a caller's name needing to be explicitly added
pub fn log_message(message string) {
    unsafe { print_indentations(delta_indentation(0)) }
    print_formatted(message, ConsoleTextFormat{})
    append_line_to_log_file(message)
}

// log_error prints a message to the console in the format "{ERROR} [[caller_name]]: [message]" in red
// and prints to the file specified in `set_log_file` if it has been set.
// Note that [print_back_trace] *does not* print to the file, just the console.
pub fn log_error(caller_name string, message string, print_back_trace bool) {
    unsafe { print_indentations(delta_indentation(0)) }
    print_formatted("{ERROR} [${caller_name}]: ${message}", foreground_color: .red)
    append_line_to_log_file("{ERROR} [${caller_name}]: ${message}")

    if print_back_trace {
        print_backtrace()
    }
}

// log_error_message prints a message to the console in the format "{ERROR} [message]" in red
// and prints to the file specified in `set_log_file` if it has been set.
// Note that [print_back_trace] *does not* print to the file, just the console.
// This is essentially the same as `log_error`, but without a caller's name needing to be explicitly added
pub fn log_error_message(message string, print_back_trace bool) {
    unsafe { print_indentations(delta_indentation(0)) }
    print_formatted("{ERROR} ${message}", foreground_color: .red)
    append_line_to_log_file("{ERROR} ${message}")

    if print_back_trace {
        print_backtrace()
    }
}

// log_formatted prints a message to the console in the format "[[caller_name]]: [message]" with custom console formatting
// and prints to the file specified in `set_log_file` if it has been set.
pub fn log_formatted(caller_name string, message string, format ConsoleTextFormat) {
    unsafe { print_indentations(delta_indentation(0)) }
    print_formatted("[${caller_name}]: ${message}", format)
    append_line_to_log_file("[${caller_name}]: ${message}")
}

// log_message_formatted prints a message to the console in the format "[message]" with custom console formatting
// and prints to the file specified in `set_log_file` if it has been set.
// This is essentially the same as `log_formatted`, but without a caller's name needing to be explicitly added
pub fn log_message_formatted(message string, format ConsoleTextFormat) {
    unsafe { print_indentations(delta_indentation(0)) }
    print_formatted(message, format)
    append_line_to_log_file(message)
}

fn print_indentations(count int) {
    for _ in 0..count {
        unsafe {
            print(set_indentation_text_unsafe(""))
            append_text_to_log_file(set_indentation_text_unsafe(""))
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

// set_log_file sets a file that all calls to `log`, `log_message`, etc. will also write to, so it can be read over later.
// If this is never set, no log file will be made and all calls will simply output to the console.
pub fn set_log_file(file_name string, heading string) {
    unsafe { set_opened_file(file_name, heading) }
}

@[unsafe]
fn set_opened_file(file_name string, heading string) int {
    mut static opened_file_name := ""
    mut static opened_fd := -1

    if (file_name == "" || file_name == opened_file_name) && opened_fd != -1 {
        return opened_fd
    } else if (file_name != "" && file_name != opened_file_name) && opened_fd != -1
    {
        // If file was previously opened, close it so another one can be opened
        os.fd_close(opened_fd)
    }

    if file_name != "CLOSE_FILE" {
        println("=== Writing log file to: ${os.dir(os.executable())}/${file_name} ===")
        opened_file := os.open_file("${os.dir(os.executable())}/${file_name}", "w") or { return -1  }
        opened_fd = opened_file.fd
        opened_file_name = file_name
        append_line_to_log_file(heading)
    } else {
        return -1
    }

    return opened_fd
}

fn append_text_to_log_file(text string) {
    mut fd := unsafe { set_opened_file("", "") } // If no file opened, simply return

    if fd == -1 {
        return
    }

    os.fd_write(fd, text)
}

fn append_line_to_log_file(text string) {
    mut fd := unsafe { set_opened_file("", "") } // If no file opened, simply return

    if fd == -1 {
        return
    }

    os.fd_write(fd, "${text}\n")
}

fn cleanup() {
    unsafe { set_opened_file("CLOSE_FILE", "") } // Closes the file logs are being written to
}