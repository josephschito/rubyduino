# toneKeyboard
#
# Plays a different note for each of three force-sensing resistors on A0–A2.
#
# https://docs.arduino.cc/built-in-examples/digital/toneKeyboard/

threshold = 10
notes = [440, 494, 131] # NOTE_A4, NOTE_B4, NOTE_C3

loop do
  i = 0
  while i < 3
    sensor_reading = analog_read(i)
    if sensor_reading > threshold
      tone(8, notes[i], 20)
    end
    i += 1
  end
end
