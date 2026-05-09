# 08.Strings

Most sketches in this category depend on the Arduino `String` class
(`String stringOne = "Hello"; stringOne.length();` etc.) which rubyduino
doesn't currently expose. Only `character_analysis.rb` is ported here
because it relies solely on the `is_*?` character classifiers, which
rubyduino does provide.

If `String` support lands later, the following can be ported:
StringAdditionOperator, StringAppendOperator, StringCaseChanges,
StringCharacters, StringComparisonOperators, StringConstructors,
StringIndexOf, StringLength, StringLengthTrim, StringReplace,
StringStartsWithEndsWith, StringSubstring, StringToInt.
