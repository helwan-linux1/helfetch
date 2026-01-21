# core/system_info.nim
import std/[os, osproc, strutils, random, tables, nativesockets]
import ../config/quotes

proc getSystemInfo*(): Table[string, string] =
  var info = initTable[string, string]()

  # 1. User
  # نستخدم getEnv للتحقق من USER (لينكس) أو USERNAME (ويندوز)
  info["User"] = getEnv("USER", getEnv("USERNAME", "N/A"))

  # 2. Host
  try:
    info["Host"] = getHostname()
  except:
    info["Host"] = "N/A"

  # 3. OS (دعم مزدوج)
  var osName = "N/A"
  when defined(posix):
    # كود آرتش لينكس الأصلي بالكامل
    if fileExists("/etc/os-release"):
      for line in lines("/etc/os-release"):
        if line.startsWith("PRETTY_NAME="):
          osName = line.split('=')[1].strip(chars = {'\"'})
          break
      if "Arch Linux" in osName:
        osName = osName.replace("Arch Linux", "Helwan Linux")
    else:
      osName = "Arch Linux"
  elif defined(windows):
    # كود ويندوز للتجربة
    osName = "Windows " & getEnv("OS", "OS")
  
  info["OS"] = osName

  # 4. Kernel
  var kernelInfo = "N/A"
  when defined(posix):
    try:
      kernelInfo = execProcess("uname -r").strip()
    except: discard
  elif defined(windows):
    kernelInfo = getEnv("PROCESSOR_IDENTIFIER", "NT Kernel")
  
  info["Kernel"] = kernelInfo

  # 5. Uptime (مع الحفاظ على منطق الثواني والحسابات بدقة)
  var uptimeVal = "N/A"
  when defined(posix):
    try:
      let uptimeProc = execProcess("uptime -p").strip()
      if uptimeProc.startsWith("up "):
        uptimeVal = uptimeProc[3..^1]
    except:
      if fileExists("/proc/uptime"):
        try:
          let content = readFile("/proc/uptime").split()
          let totalSeconds = content[0].parseFloat().int 
          let days = totalSeconds div 86400
          let hours = (totalSeconds mod 86400) div 3600
          let minutes = (totalSeconds mod 3600) div 60
          if days > 0: uptimeVal = $days & "d " & $hours & "h " & $minutes & "m"
          elif hours > 0: uptimeVal = $hours & "h " & $minutes & "m"
          else: uptimeVal = $minutes & "m"
        except: discard
  elif defined(windows):
    uptimeVal = "Available on Boot" # ويندوز يتطلب مكتبات معقدة للـ uptime

  info["Uptime"] = uptimeVal

  # 6. Shell
  let shellPath = getEnv("SHELL", getEnv("ComSpec", "N/A"))
  info["Shell"] = if shellPath != "N/A": lastPathPart(shellPath) else: "N/A"

  # 7. Terminal
  info["Terminal"] = getEnv("TERM", getEnv("COLORTERM", "N/A"))

  # 8. Packages (لن تعمل إلا على آرتش)
  info["Packages (Pacman)"] = "N/A"
  when defined(posix):
    try:
      let pacmanOut = execProcess("pacman -Qq").strip()
      if pacmanOut != "":
        let count = pacmanOut.splitLines().len
        info["Packages (Pacman)"] = $count
    except: discard

  return info

proc getInspirationalQuote*(): string =
  if QUOTES.len > 0:
    randomize()
    return sample(QUOTES)
  return ""
