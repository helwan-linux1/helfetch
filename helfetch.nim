# helfetch.nim
import std/[os, parseopt, tables, strutils]

# إضافة دعم الألوان لويندوز
when defined(windows):
  import std/terminal

# Import project modules
import core/[system_info, hardware_info, desktop_info, network_info]
import display/[ascii_art, formatter]
import config/default_config

proc main() =
  # تفعيل الألوان في ويندوز (الطريقة الصحيحة)
  when defined(windows):
    terminal.enableTrueColors() # استدعاء مباشر بدون discard

  var showLogo = true
  
  # 1. معالجة وسائط سطر الأوامر
  var p = initOptParser()
  for kind, key, val in p.getopt():
    case kind
    of cmdLongOption, cmdShortOption:
      if key == "no-logo" or key == "n":
        showLogo = false
    else: discard

  # 2. جمع البيانات
  let systemData = getSystemInfo()
  let hardwareData = getHardwareInfo()
  let desktopData = getDesktopInfo()
  let networkData = getNetworkInfo()
  let inspirationalQuote = getInspirationalQuote()

  # 3. دمج البيانات
  var allInfo = initTable[string, string]()
  for k, v in systemData: allInfo[k] = v
  for k, v in hardwareData: allInfo[k] = v
  for k, v in desktopData: allInfo[k] = v
  for k, v in networkData: allInfo[k] = v

  # 4. تجهيز الشعار
  var helwanLogo = ""
  if showLogo:
    helwanLogo = getAsciiLogo("Helwan Linux")

  # 5. التنسيق والطباعة
  try:
    let formattedOutput = formatInfoOutput(
      infoData = allInfo,
      logoLines = helwanLogo,
      inspirationalQuote = inspirationalQuote,
      infoKeyColor = DEFAULT_COLORS.getOrDefault("info_key_color", "light_yellow"),
      infoValueColor = DEFAULT_COLORS.getOrDefault("info_value_color", "white")
    )
    echo formattedOutput
  except Exception as e:
    stderr.writeLine("\x1b[0;31mAn error occurred: " & e.msg & "\x1b[0m")
    quit(1)

if isMainModule:
  main()
