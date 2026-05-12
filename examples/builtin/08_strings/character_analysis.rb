# CharacterAnalysis
#
# Reports everything the rubyduino character helpers know about each byte
# received over serial. The other 08.Strings sketches are skipped because
# they depend on the Arduino String class, which rubyduino does not expose.
#
# https://docs.arduino.cc/built-in-examples/strings/CharacterAnalysis/

serial_begin(9600)
serial_println("send any byte and I'll tell you everything I can about it")
serial_println("")

loop do
  if serial_available > 0
    this_char = serial_read

    serial_print("You sent me: '")
    serial_write(this_char)
    serial_print("'  ASCII Value: ")
    serial_println(this_char)

    serial_println("it's alphanumeric")             if is_alpha_numeric?(this_char)
    serial_println("it's alphabetic")               if is_alpha?(this_char)
    serial_println("it's ASCII")                    if is_ascii?(this_char)
    serial_println("it's whitespace")               if is_whitespace?(this_char)
    serial_println("it's a control character")      if is_control?(this_char)
    serial_println("it's a numeric digit")          if is_digit?(this_char)
    serial_println("it's a printable non-whitespace") if is_graph?(this_char)
    serial_println("it's lower case")               if is_lower_case?(this_char)
    serial_println("it's printable")                if is_printable?(this_char)
    serial_println("it's punctuation")              if is_punct?(this_char)
    serial_println("it's a space character")        if is_space?(this_char)
    serial_println("it's upper case")               if is_upper_case?(this_char)
    serial_println("it's a hexadecimal digit")      if is_hexadecimal_digit?(this_char)

    serial_println("")
    serial_println("Give me another byte:")
    serial_println("")
  end
end
