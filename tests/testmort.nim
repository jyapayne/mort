import strutils

import mort

proc mysnakeToCamel(s: cstring): string {.findDeadCode.} =
  var i, j: int
  result = newString(s.len)
  if s[i] == '_': inc(i)
  while true:
    if s[i] == '_' and (s[i + 1] == '\0' or s[i + 1] == '_'):
      inc(i)
    elif (s[i] == '_' or s[i] == '-') and s[i + 1].isLowerAscii and not s[i - 1].isUpperAscii:
      inc(i)
      result[j] = toUpperAscii(s[i])
      inc(i)
      inc(j)
    else:
      result[j] = s[i]
      inc(i)
      inc(j)
    if s[i] == '\0':
      result.setLen(j)
      break
  if result[0] == '\0': # this may result, so we emit a dummy name as marker
    result = "QQQ"

proc main() =
  discard mySnakeToCamel("diff_is_good")
  discard mySnakeToCamel("_diff_is_good")
  printCodeUsage()
  printDeadLines()

main()
