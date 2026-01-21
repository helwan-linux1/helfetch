# Maintainer: Helwan Linux Team
pkgname=helfetch
pkgver=1.0.0
pkgrel=1
pkgdesc="A fast system information fetcher written in Nim for Helwan Linux"
arch=('x86_64')
url="https://github.com/yourusername/helfetch" # ضع رابط مستودعك هنا
license=('MIT')
depends=('openssl' 'pciutils')
makedepends=('nim')
source=("helfetch-${pkgver}.tar.gz") # يفترض وجود سورس مضغوط أو رابط
sha256sums=('SKIP') # يمكن توليد الـ Hash لاحقاً لضمان الأمان

build() {
  cd "$srcdir"
  # تجميع البرنامج باستخدام Nim مع تفعيل التحسينات القصوى
  # -d:release للسرعة، --opt:speed لأفضل أداء، --mm:orc لإدارة ذاكرة حديثة
  nim c -d:release --opt:speed --mm:orc helfetch.nim
}

package() {
  cd "$srcdir"
  # إنشاء مجلد bin في نظام التوزيعة ونقل الملف التنفيذي إليه
  install -Dm755 helfetch "${pkgdir}/usr/bin/helfetch"
  
  # إذا كان لديك ترخيص (License)
  # install -Dm644 LICENSE "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}