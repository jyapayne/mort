# mort
A dead code branch locator for Nim. This library will find places in your code that contain dead branches that are not executed at _runtime_. Nim already has dead code elimination at _compile time_ but this won't, for example, eliminate a dead branch on your if else statement, because that can only be determined at _run time_.

Say you have a Nim module like so:

```nim
proc notUsedProc() =
  echo "being optimized"
  
proc main() =
  let input = stdin.readLine()
  if input == "hello":
    echo "Hi!"
  else:
    echo "You're supposed to greet me"

main()
```

You can see by the above code that the `notUsedProc()` can be optimized away at compile time, but the if/else statement depends on user input and cannot be optimized away.

But maybe you have a bug in the `if input == "hello"` branch but that never gets called very often or at all. This library can tell you (based on runtime usage) whether or not your branches get called and let you know. This could be useful for **test coverage** for example.

## Usage

Simply use the `findDeadCode` macro on your code, shown below, then call either or both of `printCodeUsage` or `printDeadCode`. Or you can get the usage table itself to do with what you like via `getUsageTable`, which returns a `TableRef[string, TableRef[int, int]]` where the string is the filename and the inner table has key = lineNumber and value = timesCalled.

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
  
  # or get the information yourself:
  let usageTable: TableRef[string, TableRef[int, int]] = getUsageTable()
  # Do cool stuff, like get test coverage

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
