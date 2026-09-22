# Dispute backend deployment

Deployed to lem3alam.ma; independently verified over SSH on 2026-09-12.

Production migration: batch 18. Dispute API routes are registered; unauthenticated
requests return HTTP 401. PHP syntax checks pass. The remote deployment verified
five 5MB files reach Laravel and configured a 50MB Nginx request limit.
Backup: `/var/backups/lem3alam-deployments/dispute-20260911.cIAsc8`.
No test disputes were created in production. Do not reapply this patch blindly.

This patch contains only the dispute controller, model fields, evidence route,
and the additive type/additional_info migration. It excludes unrelated local work.

Before applying, compare the live versions and back up the affected files and database.
From the live Laravel application directory, check and apply the patch:

```sh
git apply --check /path/to/backend.patch
git apply /path/to/backend.patch
php artisan migrate --path=database/migrations/2026_09_11_000001_add_type_and_additional_info_to_disputes.php --force
php artisan route:cache
php artisan migrate:status --path=database/migrations/2026_09_11_000001_add_type_and_additional_info_to_disputes.php
php artisan route:list --path=disputes
```

Verify authenticated multipart creation and listing using an approved test account/task;
unauthenticated GET /public/api/v1/disputes should return 401.
Evidence uses the private local disk and an authenticated download route.
Ensure PHP upload_max_filesize is at least 5M and post_max_size exceeds 25M.
No Composer dependencies or frontend build are required for this backend patch.

For rollback, restore the backed-up PHP files and rebuild the route cache.
Leave the additive columns in place to preserve submitted data.
