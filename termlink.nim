import os, terminal, winlean, sequtils, unicode, json, system, rdstdin, strutils

# capture keyboard on windows
when defined(windows):
  when defined(useConio):
    echo "using conio"
    proc getch(): cint {.importc: "_getch", header: "<conio.h>".}
    proc kbhit(): cint {.importc: "_kbhit", header: "<conio.h>".}
  else:
    proc getch(): cint {.importc: "_getch", dynlib: "msvcrt.dll".}
    proc kbhit(): cint {.importc: "_kbhit", dynlib: "msvcrt.dll".}

# capture keyboard on linux
# TODO 


# Create main.json if does not exist
if not fileExists("main.json"):
  var define = %*{
    "main": {
      "name": "Example Terminal - Page 1",
      "data": [
        {
          "name": "Goto Page 2",
          "page": "two"
        },
        {
          "name": "Run an example program",
          "exec": "calc"
        }
      ]
    },
    "two": {
      "name": "Example Terminal - Page 2",
      "text": "Welcome to the empty page 2",
      "data": []
    }
  }
  writeFile("main.json",define.pretty)


# Predefinitions
var letter     = -1
var screen     = "main"
var message    = ""
var cursor_pos = -1
var page       = "main"
var data       = json.parseJSON(readFile("main.json"))
var options    = data[page]["data"];
var title      = data[page]["name"].getStr();
var attempts   = 3
var gm_matches = 0
var hack_story: seq[string]

# Detecting pressed key
proc detect_key(): cint =
  if kbhit() != 0:
    return getch()
  else:
    return -1

# Drawing main screen headers
proc drawMotd() =
  stdout.setForeGroundColor(fgGreen)
  stdout.setBackGroundColor(bgBlack)
  echo "  "
  echo "  Welcome to ROBCO Industries(TM) Termlink"
  if title.len > 0:
    echo "  "
    echo "  " & title
  else:
    echo "  "
    echo "  Unknown Terminal"
  echo "  ";

proc drawMenu() =
  stdout.setForeGroundColor(fgGreen)
  stdout.setBackGroundColor(bgBlack)
  var pos = 0
  if options.len > 0:
    for o in options:
      if cursor_pos == pos:
        stdout.setForeGroundColor(fgBlack)
        stdout.setBackGroundColor(bgGreen)
      var output = "  [" & o["name"].getStr() & "]"
      while terminalWidth()-1 > output.len:
        output = output & " "
      echo output
      pos = pos + 1
      stdout.setForeGroundColor(fgGreen)
      stdout.setBackGroundColor(bgBlack)

proc getRandomByte(index: int): string =
  try:
    var bytes = "@!$!....%$^#%.....&)(%#*(#$}{$@....^(%#()#@$_%_+%.......$(*&$%()[%.......$#^]$^#{......}$%#%^)....(#@)"
    var pos   = index
    while pos > bytes.len - 1:
      pos = pos - (bytes.len)
    return bytes[pos..pos]
  except:
    echo "Byte error"
  return "0"

proc unlock() =
  stdout.setCursorPos(0,0)
  eraseScreen()
  echo "  "
  echo "  Terminal hacked"
  echo "  "
  sleep(300)
  eraseScreen()

proc lock() = 
  stdout.setCursorPos(0,0)
  eraseScreen()
  echo "  "
  echo "  Terminal locked for 10 seconds"
  echo "  "
  sleep(10000)
  eraseScreen()

proc hack(page: JsonNode): bool =
  eraseScreen()
  stdout.setCursorPos(0,0)
  hideCursor()
  echo "  "
  echo "  Welcome to ROBCO Industries(TM) Termlink"
  echo "  "
  echo "  Password Required"
  echo "  "
  stdout.write("  Attempts Remaining: ")
  for i in 1..attempts:
    stdout.write(" █")
  echo "  "
  echo "  "
  var pass = page["hack"]["pass"].getStr()
  var increment = 0
  var bytecode = ""
  for i in 0..512:
    bytecode = bytecode & getRandomByte(i)
  var offset = 0
  var word_offset = 0
  for word in page["hack"]["data"]:
    var w = word.getStr()
    bytecode[word_offset..word_offset+w.len-1] = w
    word_offset = word_offset + 30 + w.len    
  for i in 1..16:
    echo "  0x0000 " & bytecode[offset..offset+11] & " 0x0000 " & bytecode[offset+12..offset+23]
    offset = offset + 24
  for o in hack_story:
    stdout.setCursorPos(42,increment+7)
    stdout.write(">" & o)
    increment = increment + 1
  stdout.setCursorPos(42,increment+7)
  var x = readLineFromStdin ">"
  if x.len > pass.len:
    x = x[0..pass.len-1]
  if x != pass:
    hack_story.add x
    var matches = 0;
    for i in 0..pass.len-1:
      if x.len > i:
        if x[i..i] == pass[i..i]: matches = matches + 1
    gm_matches = matches
    hack_story.add "Entry denied."
    hack_story.add "Likeness=" & $matches
    attempts = attempts - 1
    if attempts > 0: return hack(page)
    else:
      title   = data["main"]["name"].getStr();
      options = data["main"]["data"]
  else:
    unlock()
    return true
  lock()
  return false

# Draws the main interface
proc drawInterface() =
  stdout.setCursorPos(0,0)
  hideCursor()
  drawMotd()
  if message.len > 0:
    var rows = message.split("\n")
    for r in rows:
      echo "  " & r
  drawMenu()
  echo "  "
  echo "  "
  echo "  "
  echo "  "
  echo "  "
  echo "  "
  echo "  "
  echo "  "
#   echo "  cursor pos: " & $cursor_pos & "    "
#   echo "  character code: " & $letter & "    "
#   echo "  menu items: " & $options.len & "    "

# Reset screen before operating
eraseScreen()
hideCursor()
drawInterface()

# Main While
while true:
  var key = detect_key()
  letter = key
  try:
    # Cursor Down
    if key == 115 or key == 80:
      cursor_pos = cursor_pos + 1
      if cursor_pos > options.len - 1: cursor_pos = 0
    
    # Cursor Up
    if key == 119 or key == 72:
      cursor_pos = cursor_pos - 1
      if 0 > cursor_pos: cursor_pos = options.len - 1
    
    # Wayback (tab)
    if key == 9 or key == 8:
      eraseScreen()
      title   = "Main"
      message = ""
      options = data["main"]["data"]
  
    # if item selected
    if cursor_pos >= 0 and options.len > cursor_pos:
      if key == 13 or key == 32:
        eraseScreen()
        # select anything
        try:
          if options[cursor_pos].hasKey("exec"):
            var c = options[cursor_pos]["exec"].getStr()
            discard execShellCmd(c)
          if options[cursor_pos].hasKey("page"):
            var p = options[cursor_pos]["page"].getStr()
            if data.hasKey(p):
              attempts = 3
              setLen(hack_story,0)
              var load = false
              if data[p].hasKey("hack"):
                if hack(data[p]):
                    load = true
              else:
                load = true
              if load:
                page       = p
                title      = data[p]["name"].getStr()
                options    = data[p]["data"]
                cursor_pos = -1
                if data[p].hasKey("text"):
                  message = data[p]["text"].getStr()
        except: echo "Failed to process option"
  except: echo "Failed to navigate option"
  try:
    if key != -1:
      drawInterface()
  except: echo "Failed to draw interface"
  sleep(100)

eraseScreen()
