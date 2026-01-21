# core/network_info.nim
import std/[osproc, strutils, tables, httpclient, json, net]

proc getNetworkInfo*(): Table[string, string] =
  var info = initTable[string, string]()
  
  # 1. Local IP (دعم مزدوج)
  try:
    when defined(posix):
      # منطق آرتش لينكس الأصلي كما هو
      let ipOut = execProcess("ip route get 1.1.1.1").strip()
      if "src " in ipOut:
        info["Local IP"] = ipOut.split("src ")[1].splitWhitespace()[0]
      else:
        info["Local IP"] = "N/A"
    elif defined(windows):
      # الطريقة المتوافقة مع Nim 2.0+ لجلب الـ IP المحلي في ويندوز
      var localIp = "N/A"
      try:
        # استخدام newSocket بدلاً من newDatagramSocket
        let socket = newSocket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
        socket.connect("1.1.1.1", Port(80))
        localIp = socket.getLocalAddr()[0]
        socket.close()
      except: discard
      info["Local IP"] = localIp
  except:
    info["Local IP"] = "N/A"

  # 2. Public IP & ISP (يعمل على النظامين)
  let client = newHttpClient(timeout = 1500) 
  try:
    let response = client.getContent("http://ip-api.com/json/")
    let data = parseJson(response)
    
    if data{"status"}.getStr() == "success":
      info["Public IP"] = data{"query"}.getStr("N/A")
      info["ISP"] = data{"isp"}.getStr("N/A")
      info["Location"] = data{"city"}.getStr("N/A") & ", " & data{"country"}.getStr("N/A")
  except:
    info["Public IP"] = "Disconnected"
    info["ISP"] = "N/A"
    info["Location"] = "N/A"
  finally:
    client.close()

  return info
