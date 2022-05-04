# fuzzme
Collection of intentionally vulnerable applications for [fuzz](https://en.wikipedia.org/wiki/Fuzzing) tools development.<br>
The apps are not secure by any means nor they are useful for anything else except for testing your tools.<br>


Note: fuzzme is not a fuzzing challenge as it is very easy to fuzz and crash. Instead it contains multitude of different bug types to crash in many different ways.

## What's inside
### cpp
C++ target buildable with CMake and fuzzable with [libFuzzer](https://llvm.org/docs/LibFuzzer.html).

### go
Go target buildable and fuzzable with [go-fuzz](https://github.com/dvyukov/go-fuzz).

## Credits and License
Originally written by Valery Korolyov for testing [BugBane](https://github.com/gardatech/bugbane).<br>
License: MIT.<br>
