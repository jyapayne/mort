# mort
A dead code locator for Nim

## Usage

Simply use the `findDeadCode` macro on your code, shown below, then call either or both of `printCodeUsage` or `printDeadCode`.

```nim
import mort

findDeadCode:
  # ... insert Nim code here
  discard

# OR

proc myNimProc() {.findDeadCode.} =
  # .. insert Nim code here
  discard
  
  
proc main() =
  # Call your proc/code that you want to be logged
  myNimProc()
  
  # then call ``printCodeUsage`` and/or ``printDeadCode``
  printCodeUsage()
  printDeadCode()

main()
```

Then compile your code with the `-d:findDeadCode` compiler flag to enable finding dead code.

## Example usage

```bash
nim c -r -d:findDeadCode tests/testmort.nim
```

Output:

```
6: 2
8: 1
10: 20
11: 0
13: 4
18: 16
22: 2
25: 0

Dead code found in /Users/joey/Projects/mort/tests/testmort.nim
at line 11

Dead code found in /Users/joey/Projects/mort/tests/testmort.nim
at line 25
```
