# display/ascii_art.nim
import std/tables

# رموز الألوان بتنسيق ANSI متوافق مع كافة الأنظمة
let COLORS* = {
    "red": "\x1b[0;31m",
    "green": "\x1b[0;32m",
    "yellow": "\x1b[0;33m",
    "blue": "\x1b[0;34m",
    "magenta": "\x1b[0;35m",
    "cyan": "\x1b[0;36m",
    "white": "\x1b[0;37m",
    "light_red": "\x1b[1;31m",
    "light_green": "\x1b[1;32m",
    "light_yellow": "\x1b[1;33m",
    "light_blue": "\x1b[1;34m",
    "light_magenta": "\x1b[1;35m",
    "light_cyan": "\x1b[1;36m",
    "light_white": "\x1b[1;37m",
    "reset": "\x1b[0m"
}.toTable()

# [cite_start]شعار حلوان لينكس - تم التأكد من خلوه من أي نصوص خارجية [cite: 1, 2]
let HELWAN_LOGO* = COLORS["light_cyan"] & """
▖▖   ▜
▙▌█▌▐ ▌▌▌▀▌▛▌
▌▌▙▖▐▖▚▚▘█▌▌▌""" & COLORS["reset"]

proc getAsciiLogo*(osName: string = "Helwan Linux"): string =
    ## [cite_start]ترجع شعار ASCII الخاص بتوزيعة حلوان لينكس [cite: 3]
    return HELWAN_LOGO
