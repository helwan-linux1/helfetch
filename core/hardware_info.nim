# core/hardware_info.nim
import std/[os, osproc, strutils, tables] 

proc getHardwareInfo*(): Table[string, string] =
  var info = initTable[string, string]()

  # 1. CPU
  try:
    when defined(posix):
      # كود آرتش الأصلي الخاص بك
      if fileExists("/proc/cpuinfo"):
        for line in lines("/proc/cpuinfo"):
          if line.startsWith("model name"):
            info["CPU"] = line.split(':')[1].strip()
            break
      else:
        info["CPU"] = "N/A"
    elif defined(windows):
      # كود بديل لويندوز لجلب اسم المعالج
      info["CPU"] = getEnv("PROCESSOR_IDENTIFIER", "N/A")
  except: 
    info["CPU"] = "N/A"

  # 2. RAM
  try:
    when defined(posix):
      # كود آرتش الأصلي الخاص بك
      let ramOut = execProcess("free -h").strip().splitLines()
      if ramOut.len > 1:
        let parts = ramOut[1].splitWhitespace()
        if parts.len >= 3:
          info["RAM"] = parts[2] & "/" & parts[1]
    elif defined(windows):
      # مجرد نص توضيحي لويندوز لعدم تعقيد الكود
      info["RAM"] = "Available on Linux"
  except: 
    info["RAM"] = "N/A"

  # 3. Disk
  try:
    when defined(posix):
      # كود آرتش الأصلي الخاص بك
      let diskOut = execProcess("df -h /").strip().splitLines()
      if diskOut.len > 1:
        let parts = diskOut[1].splitWhitespace()
        if parts.len >= 5:
          info["Disk"] = parts[4]
    elif defined(windows):
      info["Disk"] = "N/A"
  except: 
    info["Disk"] = "N/A"

  # 4. GPU
  try:
    when defined(posix):
      # كود آرتش الأصلي الخاص بك (lspci)
      let lspciOut = execProcess("lspci -k").strip().splitLines()
      var gpus: seq[string] = @[]
      for line in lspciOut:
        if "VGA compatible controller" in line or "3D controller" in line:
          if ":" in line:
            gpus.add(line.split(':')[^1].strip())
      info["GPU"] = if gpus.len > 0: gpus.join(", ") else: "N/A"
    elif defined(windows):
      info["GPU"] = "N/A"
  except: 
    info["GPU"] = "N/A"

  return info
