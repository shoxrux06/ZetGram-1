# Dev Lug‘at

IT va dasturlash inglizchasi uchun kartochkali ilova (Flutter). B1–B2 darajasidagi 60 ta so‘z 6 bo‘limga ajratilgan: Git, kod sharhi, debug, arxitektura, DevOps, jamoa va Agile.

- Kartani bosib ag‘darasiz, chapga yoki o‘ngga surib keyingi so‘zga o‘tasiz.
- Talaffuz telefonning o‘z ovozi bilan o‘qiladi va internetsiz ishlaydi. Sekin o‘qish ham bor.
- Har bir so‘zda o‘zbekcha tarjima, inglizcha izoh, misol gap va uning tarjimasi bor.
- “Bilaman” va “Takrorlash” belgilari telefonda saqlanadi.
- Yorug‘ va tungi mavzu, EN → UZ va UZ → EN yo‘nalishlari bor.

## Ilovani yuklab olish

Har safar `dev_lugat/` papkasi o‘zgarganda GitHub Actions ilovani avtomatik yig‘adi:

1. Repozitoriyning **Actions** bo‘limida **Dev Lug'at build** ni oching.
2. Eng oxirgi muvaffaqiyatli (yashil) ishga tushirishni tanlang.
3. **Artifacts** qismidan yuklab oling:
   - `DevLugat-iOS-ipa` — iPhone uchun `.ipa`
   - `DevLugat-Android-apk` — Android uchun `.apk`

Yuklab olingan fayl `.zip` bo‘ladi. Uni ochsangiz, ichidan `DevLugat.ipa` yoki `DevLugat.apk` chiqadi.

## iPhone’ga o‘rnatish (Mac shart emas)

`.ipa` imzosiz yig‘iladi. Uni Apple ID’ingiz bilan imzolab o‘rnatish uchun **Sideloadly** (Windows yoki Mac) yoki **AltStore** dasturidan foydalaning:

1. Kompyuterga Sideloadly’ni o‘rnating: <https://sideloadly.io>. Windows’da iTunes va iCloud ham kerak bo‘ladi (Microsoft Store versiyasi emas, Apple saytidagisi).
2. iPhone’ni kabel bilan ulang va telefonda “Trust / Ishonish” tugmasini bosing.
3. Sideloadly’ga `DevLugat.ipa` faylini tashlang, Apple ID’ingizni kiriting va **Start** tugmasini bosing.
4. iPhone’da quyidagilarni bajaring:
   - **Sozlamalar → Umumiy → VPN va qurilmalarni boshqarish** bo‘limida Apple ID’ingizga “Ishonish” bosing.
   - iOS 16 va undan yangi versiyalarda: **Sozlamalar → Maxfiylik va xavfsizlik → Developer Mode** ni yoqing, telefon qayta yonadi.
5. Ilova ekranda **Dev Lug‘at** nomi bilan paydo bo‘ladi.

> Bepul Apple ID bilan o‘rnatilgan ilova **7 kun** ishlaydi. Keyin Sideloadly orqali qayta o‘rnatasiz, bunda progress saqlanib qoladi. AltStore buni Wi‑Fi orqali avtomatik yangilab turadi. Pullik Apple Developer akkaunti ($99/yil) bilan bu cheklov 1 yilgacha uzayadi.

### Mac va Xcode bo‘lsa

```bash
cd dev_lugat
flutter pub get
open ios/Runner.xcworkspace   # Signing & Capabilities → Team: Apple ID’ingiz
flutter run --release         # iPhone kabel bilan ulangan bo‘lishi kerak
```

## Android’ga o‘rnatish

`DevLugat.apk` faylini telefonga yuboring, oching va “Noma’lum manbalardan o‘rnatish”ga ruxsat bering.

## Ishlab chiqish

```bash
flutter pub get
flutter test
flutter run
```

- So‘zlar ro‘yxati: `lib/data/words.dart`
- Progress va filtrlar: `lib/state/study_store.dart`
- Ikonka: `assets/icon/`. O‘zgartirgandan keyin `dart run flutter_launcher_icons` ni ishga tushiring.
- Shrift: IBM Plex Mono (SIL Open Font License, `assets/fonts/OFL.txt`).
