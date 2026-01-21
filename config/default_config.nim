# config/default_config.nim
import std/tables

# استخدام Table لتخزين إعدادات الألوان الافتراضية
let DEFAULT_COLORS*: Table[string, string] = {
    "info_key_color": "light_yellow",
    "info_value_color": "white",
    "logo_color": "light_cyan",
    "quote_color": "light_green" # لون جديد للاقتباس
}.toTable()
