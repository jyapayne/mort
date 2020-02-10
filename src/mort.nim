import macros, tables, strformat, algorithm

type
  IndexStack[T] = seq[T]

template childAt(node: NimNode, indexList: seq[int]): NimNode =
  var curNode = node
  for i in indexList:
    curNode = curNode[i]
  curNode

iterator iterNode(node: NimNode): NimNode =
  ## Recursive iterator for NimNodes. There's weird index stuff going on
  ## because deep nodes can't be modified in place for some reason when iterating
  var
    stack: seq[IndexStack[int]] = @[newSeq[int]()]
    curNode = node

  # traverse the node tree inorder
  while stack.len() > 0:
    let indexList = stack.pop()
    var newIndices: IndexStack[int] = indexList

    var n = curNode.childAt(indexList)
    yield n
    for i in 0 ..< n.len:
      var nstack = newIndices
      nstack.add(i)
      stack.add(nstack)

template sortedIter(iter: untyped): seq[(int, int)] =
  ## Iterate over a pairs iterator and return a sorted iterator
  var arr: seq[(int, int)] = @[]
  for k, v in iter:
    arr.add((k, v))
  sorted(arr, SortOrder.Ascending)


var UsageTable = newTable[string, TableRef[int, int]]()

proc initUsage(filename: string, line: int) =
  ## This needs to be called at the start of the profiled code
  ## in order to capture empty lines
  ## This is done automatically by the macro
  var lineTable = UsageTable.mgetOrPut(filename, newTable[int, int]())
  discard lineTable.hasKeyOrPut(line, 0)

proc logUsage(filename: string, line: int) =
  ## This needs to be sprinkled in between the code where a path begins
  ## This is done automatically by the macro
  UsageTable[filename][line] += 1

######################## User API ################################

proc getUsageTable*(): TableRef[string, TableRef[int, int]] =
  return UsageTable

proc printCodeUsage*() =
  ## Prints usage for all code paths
  for filename, lineTable in UsageTable.pairs:
    echo fmt"Printing usage in: {filename}"
    for _, (lineNum, count) in sortedIter(lineTable.pairs()):
      echo fmt"{lineNum}: {count}"
  echo ""

proc printDeadLines*() =
  ## Prints only the locations where dead lines exist
  for filename, lineTable in UsageTable.pairs:
    for _, (lineNum, count) in sortedIter(lineTable.pairs()):
      if count == 0:
        echo fmt"Dead code found in {filename}"
        echo fmt"at line {lineNum}"
        echo ""

macro findDeadCode*(code: untyped): untyped =
  ## This is the main macro. It can be used in the style of a pragma or
  ## as a block. To activate it, use the ``-d:findDeadCode`` compiler flag.
  ##
  ## After sprinkling it around your code, call ``printCodeUsage`` or
  ## ``printDeadLines`` to get output about where dead lines exist in
  ## your code.
  ##
  ##
  ## .. code-block:: nim
  ##
  ##   findDeadCode:
  ##     # ... Put a bunch of Nim code here
  ##     discard
  ##
  ##   proc myFancyProc() {.findDeadCode.} =
  ##     # ... Put a bunch of Nim code here
  ##     discard
  ##
  result = code

  if not defined(findDeadCode):
    return

  template logUsageTemplate(lineInfo) =
    logUsage(lineInfo.filename, lineInfo.line)

  template initUsageTemplate(lineInfo) =
    initUsage(lineInfo.filename, lineInfo.line)

  var initUsages = newNimNode(nnkStmtList)

  for n in iterNode(result):
    if n.kind == nnkStmtList:
      let
        lineInfo = n.lineInfoObj()
        callNode = getAst(logUsageTemplate(lineInfo))
      n.insert(0, callNode)
      initUsages.add(getAst(initUsageTemplate(lineInfo)))

  if result.kind == nnkStmtList:
    result.insert(0, initUsages)
  else:
    for child in result.children:
      if child.kind == nnkStmtList:
        child.insert(0, initUsages)
        break
