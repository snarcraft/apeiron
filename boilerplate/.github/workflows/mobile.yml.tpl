name: Publish mobile

on:
  workflow_dispatch:
  push:
    branches:
      - main
    tags:
      - '*'

env:
  FLUTTER_VERSION: 3.35.0
  APP_BUNDLE: {{MOBILE_ORG}}.{{APP_SLUG}}

concurrency:
  group: mobile-${{ github.ref }}
  cancel-in-progress: true

jobs:
  changes:
    name: Detect relevant changes
    runs-on: ubuntu-latest
    outputs:
      changed: ${{ steps.diff.outputs.changed }}
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Diff against previous ref
        id: diff
        run: |
          PREVIOUS=$(git describe --abbrev=0 --tags ${{ github.ref }}^ 2>/dev/null || true)
          if [ -z "$PREVIOUS" ]; then
            echo "changed=true" >> "$GITHUB_OUTPUT"
            exit 0
          fi
          CHANGED=$(git diff --name-only "$PREVIOUS".."${{ github.ref }}" -- apps/mobile .github/workflows/mobile.yml | head -1)
          if [ -n "$CHANGED" ]; then
            echo "changed=true" >> "$GITHUB_OUTPUT"
          else
            echo "changed=false" >> "$GITHUB_OUTPUT"
          fi

  build:
    name: Build artifacts
    needs: changes
    if: github.event_name == 'workflow_dispatch' || needs.changes.outputs.changed == 'true'
    runs-on: macos-latest
    environment: mobile
    timeout-minutes: 45
    defaults:
      run:
        working-directory: apps/mobile
    steps:
      - uses: actions/checkout@v4

      # ── Android signing ─────────────────────────────────────
      - name: Materialize Android service account
        uses: timheuer/base64-to-file@v1.2
        id: service_account
        with:
          fileName: service-account.json
          encodedString: ${{ secrets.ANDROID_SERVICE_ACCOUNT }}

      - name: Materialize Android keystore
        uses: timheuer/base64-to-file@v1.2
        id: android_keystore
        with:
          fileName: upload-keystore.jks
          encodedString: ${{ secrets.ANDROID_KEYSTORE }}

      - name: Write key.properties
        run: |
          cat > android/key.properties <<EOF
          storeFile=${{ steps.android_keystore.outputs.filePath }}
          storePassword=${{ secrets.ANDROID_STORE_PASSWORD }}
          keyPassword=${{ secrets.ANDROID_KEY_PASSWORD }}
          keyAlias=${{ secrets.ANDROID_KEY_ALIAS }}
          EOF

      # ── App config (the mobile .env) ────────────────────────
      - name: Materialize assets/app.json
        run: echo -n "${{ secrets.APP_CONFIG }}" | base64 --decode --output assets/app.json

      - name: Materialize Firebase configs
        run: |
          echo -n "${{ secrets.ANDROID_GOOGLE_SERVICES }}" | base64 --decode --output android/app/google-services.json
          echo -n "${{ secrets.IOS_GOOGLE_SERVICES }}" | base64 --decode --output ios/Runner/GoogleService-Info.plist
          echo -n "${{ secrets.IOS_FIREBASE_APP_ID_FILE }}" | base64 --decode --output ios/firebase_app_id_file.json

      # ── Toolchain ───────────────────────────────────────────
      - uses: actions/setup-java@v4
        with:
          distribution: zulu
          java-version: 18.x
          cache: gradle

      - uses: android-actions/setup-android@v3

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

      - name: Cache Pods
        uses: actions/cache@v4
        with:
          path: apps/mobile/ios/Pods
          key: ${{ runner.os }}-pods-${{ hashFiles('apps/mobile/ios/Podfile.lock') }}
          restore-keys: ${{ runner.os }}-pods-

      # ── Build ───────────────────────────────────────────────
      - run: flutter doctor --verbose
      - run: flutter pub get
      - run: flutter pub run build_runner build --delete-conflicting-outputs
      - run: flutter build appbundle --release --target lib/release.dart

      # ── Release ─────────────────────────────────────────────
      - name: Upload to Google Play (internal)
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJson: ${{ steps.service_account.outputs.filePath }}
          packageName: ${{ env.APP_BUNDLE }}
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal
          status: completed

      # iOS path — enable once App Store Connect secrets exist:
      #
      # - uses: apple-actions/import-codesign-certs@v3
      #   with:
      #     p12-file-base64: ${{ secrets.IOS_CERTIFICATE }}
      #     p12-password: ${{ secrets.IOS_CERTIFICATE_PASSWORD }}
      # - run: flutter build ipa --release --target lib/release.dart --export-options-plist ios/ExportOptions.plist
      # - uses: apple-actions/upload-testflight-build@v3
      #   with:
      #     app-path: build/ios/ipa/*.ipa
      #     issuer-id: ${{ secrets.APP_STORE_ISSUER_ID }}
      #     api-key-id: ${{ secrets.APP_STORE_KEY_ID }}
      #     api-private-key: ${{ secrets.APP_STORE_PRIVATE_KEY }}

      - name: Notify Discord
        uses: ./.github/actions/notify-discord
        if: always()
        with:
          service: mobile
          sha: ${{ github.sha }}
          branch: ${{ github.ref_name }}
          registry: ghcr.io
          repository: {{GITHUB_REPOSITORY}}
          app-name: ${{ vars.APP_NAME }}
          app-env: ${{ github.ref_name == 'main' && 'staging' || 'production' }}
          app-version: ${{ vars.APP_VERSION }}
          discord-webhook-url: ${{ secrets.DISCORD_SERVER_WEBHOOK_URL }}
          discord-user-id: ${{ secrets.DISCORD_USER_ID }}
