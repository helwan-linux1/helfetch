# core/desktop_info.nim
import std/[os, osproc, strutils, tables]

proc getDesktopInfo*(): Table[string, string] =
  var info = initTable[string, string]()
  
  # 1. جلب واجهة سطح المكتب (DE)
  # في لينكس نستخدم XDG_CURRENT_DESKTOP، في ويندوز نضع Explorer
  when defined(posix):
    let de = getEnv("XDG_CURRENT_DESKTOP", "N/A")
  else:
    let de = if getEnv("OS") != "": "Explorer (Windows)" else: "N/A"
  
  info["DE"] = de

  # 2. جلب مدير النوافذ (WM)
  var wmName = "N/A"
  when defined(posix):
    if getEnv("I3SOCK") != "": wmName = "i3"
    elif getEnv("BSPWM_SOCKET") != "": wmName = "bspwm"
    elif de.contains("GNOME"): wmName = "Mutter (GNOME)"
    elif de.contains("KDE"): wmName = "KWin"
    elif de.contains("XFCE"): wmName = "Xfwm4"
  elif defined(windows):
    wmName = "DWM (Desktop Window Manager)"
  
  info["WM"] = wmName

  # 3. جلب السمات والأيقونات (GTK Theme & Icons)
  # هذه الأوامر (gsettings) لن تعمل إلا على الأنظمة التي تدعم GTK
  when defined(posix):
    proc getGSettings(schema, key: string): string =
      try: 
        let res = execProcess("gsettings get " & schema & " " & key).strip(chars = {'\'', '\"'})
        return if res != "": res else: "N/A"
      except: return "N/A"

    if de in ["GNOME", "Cinnamon", "MATE", "XFCE"]:
      info["Theme"] = getGSettings("org.gnome.desktop.interface", "gtk-theme")
      info["Icons"] = getGSettings("org.gnome.desktop.interface", "icon-theme")
      info["Font"] = getGSettings("org.gnome.desktop.interface", "font-name")
    else:
      info["Theme"] = "N/A"
      info["Icons"] = "N/A"
      info["Font"] = "N/A"
  else:
    # في ويندوز نكتفي بـ N/A أو يمكن توسيعها لاحقاً
    info["Theme"] = "N/A"
    info["Icons"] = "N/A"
    info["Font"] = "N/A"

  return info
