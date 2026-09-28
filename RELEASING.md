# Releasing Circle

This document describes the one-click release pipeline that ships Android
APK + AAB artifacts to GitHub Releases and to the Google Play Console
**internal testing** track. Production promotion remains a manual step in
the Play Console UI.

## How a release happens

1. A conventional-commit PR (e.g. `feat:`, `fix:`) lands on `main`.
   The title carries the conventional-commit signal — release-please
   reads **PR titles**, not commit messages.
2. The `.github/workflows/release-please.yml` workflow opens or updates a
   **release PR**. The PR bumps `pubspec.yaml` and regenerates `CHANGELOG.md`.
   The Android `versionCode` is derived from the tag by the `release.yml`
   workflow at build time (`major*10000 + minor*100 + patch`, e.g. `v1.0.0` → `10000`).
3. You review the release PR (check the changelog draft and the version
   bump), then merge it.
4. The merge pushes a tag (e.g. `v1.0.1`). The
   `.github/workflows/release.yml` workflow fires:
   - Assembles `key.properties` from secrets.
   - Derives the `versionCode` from the tag.
   - Builds a signed AAB and a signed APK with `--build-number=$vc`.
   - Attaches both to the GitHub Release for the tag.
   - Uploads the AAB to the Play Console internal testing track via
     `fastlane play_upload` as a **draft** (testers are not
     auto-notified).
5. **You** open the Play Console, verify the AAB on the internal track,
   and click **Promote release → Production** when ready.

There is no manual version bump, no manual tag, no manual upload.

## PR title conventions (required)

The lint workflow `.github/workflows/pr-title-lint.yml` rejects PRs whose
titles don't match a conventional-commit prefix. Allowed prefixes:

| Prefix            | Effect                                |
| ----------------- | ------------------------------------- |
| `feat:`           | Minor bump; lands under "Features"    |
| `feat!:`          | Major bump; lands under "Features"    |
| `fix:`            | Patch bump; lands under "Bug Fixes"   |
| `perf:`           | Patch bump; lands under "Performance" |
| `refactor:`       | No bump; lands under "Refactoring"    |
| `docs:`, `test:`, `build:`, `ci:`, `chore:`, `revert:` | Hidden from changelog (still allowed) |

`BREAKING CHANGE:` in the PR body footer also triggers a major bump.

## Prerequisites (GitHub Secrets)

The pipeline uses secrets configured under **Settings → Secrets and variables → Actions**:

| Secret                  | Purpose                                                                 |
| ----------------------- | ----------------------------------------------------------------------- |
| `RELEASE_PLEASE_TOKEN`  | PAT with `repo` (or fine-grained `contents:write` & `pull-requests:write`). **Required**: Tags created using GitHub's built-in `GITHUB_TOKEN` are suppressed by GitHub Actions and will never trigger the downstream `release.yml` workflow. A PAT is required for automated deployment. |
| `ANDROID_KEYSTORE_BASE64` | `base64` of the CI **upload** keystore.                                |
| `KEY_ALIAS`             | Alias of the upload key inside the keystore.                            |
| `KEY_PASSWORD`          | Password for the upload key.                                            |
| `STORE_PASSWORD`        | Password for the keystore file itself.                                  |
| `PLAY_SUPPLY_JSON_KEY`  | Contents of the Play Console service-account JSON (release-manager).    |
| `ENV_SECRETS`           | Optional `.env` contents if required by the app.                        |
