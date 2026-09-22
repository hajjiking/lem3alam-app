# Dispute response workflow

Deployed to lem3alam.ma on 2026-09-12.

- Respondent proposes a solution or appeals.
- Complainant accepts a proposal or requests another solution.
- The first appeal/rejection allows one more proposal; the second escalates.
- Only a user with manage_disputes permission who is not a party can decide an escalated case.
- The existing dispute_actions table is the canonical history, shared by web and app.
- Every action carries a version; stale responses are rejected.

Production backup: /var/backups/lem3alam-deployments/workflow-20260912-172251
Moderation page: https://lem3alam.ma/admin/disputes/workflow
API: POST /public/api/v1/disputes/{id}/actions

Verification: 17 Flutter tests, 8 Laravel tests (64 assertions), clean Flutter analysis;
production PHP syntax and Blade compilation passed. API endpoints returned unauthenticated
401 and the moderation page redirected guests to login. No real dispute was submitted for testing.

The live server already had the dispute_actions migration. No new production migration
was run. For a local backend that lacks this table, run only:
php artisan migrate --path=database/migrations/2026_09_12_000000_create_dispute_actions_table.php

Use PHP 8.4 at /www/server/php/84/bin/php on this server. The default CLI lacks mbstring.
The release directory records the deployed compatibility changes; do not blindly reapply
apply_remote.py because route insertions are not idempotent.

Android APK built successfully on 2026-09-12:
build/app/outputs/flutter-apk/app-release.apk (78,177,120 bytes).
SHA-256: 3A15AC4D028CB7F9BB640A54F9BBCF7405975CB8583B01AC71915D4102C45946
Android apksigner verification passed. Package rf.gd.lem3alam.lem3alam_mobile,
version 1.0.0 (1), minimum SDK 24, target SDK 36. Uses the existing Android Debug
signing certificate, suitable for direct installation/testing; store publishing
requires the project's production signing setup. No device installation was performed.

For this Windows environment, Gradle's Java socket initialization failed with the
default temporary directory. The successful build used process-local variables:
```powershell
New-Item -ItemType Directory -Force -Path "$PWD/build/java-temp" | Out-Null
$env:TEMP = "$PWD/build/java-temp"
$env:TMP = $env:TEMP
$env:JAVA_TOOL_OPTIONS = "-Djava.io.tmpdir=$env:TEMP"
flutter build apk --release
```
Run from the Flutter project root; these settings do not change system-wide Java configuration.
