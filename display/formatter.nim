# display/formatter.nim
import std/[strutils, re, tables, math]
import ascii_art
import ../config/default_config

proc stripAnsiCodes*(text: string): string =
  ## Removes ANSI escape codes from a string to get its 'visual' length.
  let ansiRegex = re"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])"
  return text.replace(ansiRegex, "")

proc createProgressBar*(percentage: float, barLength: int = 20, filledChar: string = "█", 
                       emptyChar: string = "-", barColor: string = "green", 
                       emptyColor: string = "white"): string =
  let percent = clamp(percentage, 0.0, 100.0)
  let filledCharsCount = int(barLength.float * percent / 100.0)
  let emptyCharsCount = barLength - filledCharsCount

  let filledBar = COLORS.getOrDefault(barColor, COLORS["reset"]) & filledChar.repeat(filledCharsCount)
  let emptyBar = COLORS.getOrDefault(emptyColor, COLORS["reset"]) & emptyChar.repeat(emptyCharsCount)

  return "[" & filledBar & emptyBar & COLORS["reset"] & "]"

proc formatInfoOutput*(infoData: Table[string, string], logoLines: string = "", 
                      inspirationalQuote: string = "", logoColor: string = "light_cyan", 
                      infoKeyColor: string = "light_yellow", 
                      infoValueColor: string = "white"): string =
    
  var coloredInfoLines: seq[string] = @[]
  var maxKeyLength = 0

  # تصحيح المنطق هنا: حساب أطول مفتاح للمحاذاة
  for key, value in infoData:
    if key != "" and value != "" and value != "N/A":
      if key.len > maxKeyLength:
        maxKeyLength = key.len

  # معالجة البيانات وتحويلها لأسطر ملونة
  for key, value in infoData:
    # تعديل طريقة التحقق لتناسب Nim
    if value == "" or value == "N/A": 
      continue
    
    var displayValue = value

    # RAM and Disk processing
    if key == "RAM" and "/" in value:
      try:
        let cleanVal = value.multiReplace([("Gi", ""), ("Mi", ""), (" ", "")])
        let parts = cleanVal.split('/')
        if parts.len == 2:
          let used = parts[0].parseFloat()
          let total = parts[1].parseFloat()
          if total > 0:
            let bar = createProgressBar((used / total) * 100, 15, barColor="blue")
            displayValue = value & " " & bar
      except: discard
    elif key == "Disk" and value.endsWith("%"):
      try:
        let percent = value.strip(chars={'%'}).parseFloat()
        let bar = createProgressBar(percent, 15, barColor="yellow")
        displayValue = value & " " & bar
      except: discard

    let padding = " ".repeat(max(0, maxKeyLength - key.len))
    let line = COLORS.getOrDefault(infoKeyColor, COLORS["reset"]) & key & ":" & padding & 
               COLORS.getOrDefault(infoValueColor, COLORS["reset"]) & " " & displayValue & COLORS["reset"]
    coloredInfoLines.add(line)

  # دمج الشعار مع المعلومات جنباً إلى جنب
  let logoLinesList = if logoLines != "": logoLines.splitLines() else: @[]
  var maxLogoVisualWidth = 0
  for line in logoLinesList:
    let visualLen = stripAnsiCodes(line).len
    if visualLen > maxLogoVisualWidth: maxLogoVisualWidth = visualLen

  let maxLines = max(logoLinesList.len, coloredInfoLines.len)
  var combinedLines: seq[string] = @[]

  for i in 0 ..< maxLines:
    let logoPart = if i < logoLinesList.len: logoLinesList[i] else: ""
    let infoPart = if i < coloredInfoLines.len: coloredInfoLines[i] else: ""
    
    let visualLen = stripAnsiCodes(logoPart).len
    let paddingBetween = " ".repeat(max(1, (maxLogoVisualWidth - visualLen) + 4))
    combinedLines.add(logoPart & paddingBetween & infoPart)

  if inspirationalQuote != "":
    combinedLines.add("")
    let qColor = DEFAULT_COLORS.getOrDefault("quote_color", "light_green")
    combinedLines.add(COLORS.getOrDefault(qColor, COLORS["reset"]) & inspirationalQuote & COLORS["reset"])

  return combinedLines.join("\n")
