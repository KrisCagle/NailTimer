# Release process

## One-time setup

### 1. Generate the upload keystore

Run this once. Replace passwords with strong ones. **Save the keystore and passwords in 3 separate secure places. If you lose them, you can never publish updates to this app again.**

```bash
cd "/Users/kriscagle/Documents/New project/NailTimer/android"
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

It will prompt for:
- A keystore password (memorize/save it)
- Your name, organizational unit, organization, city, state, country code
- A key password — you can press Enter to reuse the keystore password
- Confirmation

The file `android/upload-keystore.jks` is created.

### 2. Create `android/key.properties`

```bash
cd "/Users/kriscagle/Documents/New project/NailTimer/android"
cp key.properties.example key.properties
```

Then edit `android/key.properties`:

```
storePassword=<the password you set>
keyPassword=<same password or the key password if different>
keyAlias=upload
storeFile=../upload-keystore.jks
```

Both files are gitignored. Never commit them.

### 3. Back up the keystore

Copy `upload-keystore.jks` to:
- A password manager (1Password / Bitwarden / Apple Keychain attachment)
- An encrypted cloud drive folder (iCloud Drive, Google Drive with 2FA)
- An offline encrypted USB drive

If you ever lose all copies, you cannot push updates to this app on Play Store. Google now offers Play App Signing (recommended) which mitigates this — see step 5 below.

---

## Building a release App Bundle

After signing is set up, build the AAB (Android App Bundle) for upload:

```bash
cd "/Users/kriscagle/Documents/New project/NailTimer"
flutter build appbundle --release
```

Output appears at:
```
build/app/outputs/bundle/release/app-release.aab
```

Current build size: ~52 MB (this is the bundle; Play splits it into device-specific APKs of ~25 MB each that users download).

That's the file you upload to Play Console.

**Note on the "failed to strip debug symbols" warning:** This is a known NDK tooling warning that does not prevent the AAB from being valid. The bundle still uploads and installs fine. To eliminate it later, ensure the Android NDK is properly installed and `ANDROID_NDK_HOME` is set.

You can also build an APK for sideloading or quick testing:
```bash
flutter build apk --release
```

Output at `build/app/outputs/flutter-apk/app-release.apk`.

---

## First Play Console upload (Internal Testing)

1. Go to <https://play.google.com/console>
2. Create a new app → "Manicure Masterpiece"
3. Fill in basic details (default language, free/paid, etc.)
4. **Setup → App content** — work through the questionnaires:
   - Privacy policy (paste the public URL of your hosted privacy.html)
   - App access (no login required — easy)
   - Ads (no)
   - Content rating (run the IARC questionnaire — should land on "Everyone")
   - Target audience (13+ recommended)
   - Data safety form (everything is local — easy)
5. **Test and release → Internal testing → Create new release**
6. Upload `app-release.aab`
7. Add release notes (use `store/listing.md` → "What's new")
8. **Save → Review release → Roll out**
9. **Internal testing → Testers → Create email list** — add up to 100 testers by email
10. Send the share link from "Copy link" to your testers

Internal testing builds skip the Google review process and are available within minutes.

---

## After Internal Testing → next stages

- **Closed testing** — 100+ testers, Google reviews the build (~1-3 days)
- **Open testing** — anyone with the link can join
- **Production** — public release in the Play Store

Same flow each time: build new AAB → upload to the appropriate track → release notes → roll out.

---

## Pre-publish checklist

Before clicking "Roll out to production":
- [ ] Keystore backed up in 3 places
- [ ] Privacy policy URL accessible publicly
- [ ] All store listing fields filled (`store/listing.md`)
- [ ] At least 2 phone screenshots uploaded
- [ ] Feature graphic (1024×500) uploaded
- [ ] App icon (1024×1024) uploaded — the placeholder works for internal testing; commission a designed icon before production
- [ ] Content rating completed
- [ ] Data safety completed
- [ ] Tested on at least one real device
- [ ] App opens, all key flows work end-to-end
- [ ] Version bumped in `pubspec.yaml` (currently 0.9.0+1; bump to 1.0.0+1 for production)

---

## Play App Signing (recommended)

When uploading your first AAB, Google offers Play App Signing. **Opt in.** Google keeps the final app signing key in their secure vault; you keep an "upload key" (the one we just generated) which is much easier to recover if lost — Google can issue you a new upload key.

Without Play App Signing, losing your keystore = lose your app's identity forever. With it, you can recover.
