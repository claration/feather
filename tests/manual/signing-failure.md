# Manual regression: failed signing must not persist Signed artifacts

This procedure covers GitHub issue #704: a signing failure recorded on `ZsignHandler.hadError` must throw from `SigningHandler.modify()` before `move()` or `addToDatabase()`. Callers (`FR.signPackageFile`, `SigningView`) already skip automatic install and source deletion when the completion reports an error; they do not need code changes.

The project has no unit-test target. Exercise the real signing flow on a provisioned device or simulator with a disposable imported app and certificate. Do not use `make`; its `deps` target downloads certificate assets. Build with the `Feather` Xcode project/scheme after local dependencies are already provisioned.

If a device, credentials, or build dependencies are unavailable, record the check as unexecuted rather than claiming validation. A successful signature, or an explicit failure with no newly persisted Signed artifact, is acceptable for natural reproduction. Do not assert that the original zsign allocator failure still occurs after dependency updates.

## Layout to inspect

| Location | Path |
| --- | --- |
| Signed artifacts | `Documents/Signed/<uuid>/` via `FileManager.signed` |
| Imported source | `Documents/Unsigned/<uuid>/` via `FileManager.unsigned` |
| Temporary work directory | `NSTemporaryDirectory()/FeatherSigning_<uuid>/` |
| Library records | Core Data `Signed` entities shown in Library |

Record a baseline of `Documents/Signed`, `Documents/Unsigned`, and Library contents before every run.

## Debugger-forced failure (deterministic)

If a naturally failing fixture is unavailable, inject `SigningFileHandlerError.signFailed` after the signing-option branch.

1. Import a disposable app and a disposable certificate. Note existing Signed directories and Library rows.
2. Start a Default signing run (certificate selected).
3. **Pre-fix comparison (optional):** stop in `SigningHandler.modify()` immediately before `move()`. In the debugger set `handler.hadError` to `SigningFileHandlerError.signFailed` and continue. Confirm an error alert is shown **and** that a new `Documents/Signed/<uuid>` directory plus a new Library record are incorrectly created.
4. **After the fix:** set the breakpoint immediately before the relocated `handler.hadError` check (still after the signing-option branch, before `move()` / `addToDatabase()`). Set `handler.hadError` to `SigningFileHandlerError.signFailed` and continue.
5. Require all of the following:
   - UI reports `Signing failed.`
   - no new `Documents/Signed/<uuid>` directory
   - no new Core Data / Library `Signed` record
   - the `FeatherSigning_<uuid>` work directory is removed (`FR.signPackageFile` catch path calls `clean()`)
   - the imported source remains under `Documents/Unsigned` and in Library

## Automatic install and delete-source-after-sign must not run on failure

1. Repeat the post-fix debugger-forced failure with **Install After Signing** and **Delete After Signing** enabled.
2. Require: error alert, no new Signed directory or record, imported source retained, install not started, previously signed unrelated apps unchanged.

## Successful Default signing still persists

1. With a valid certificate, sign a small known-good app using Default signing. Do not inject `hadError`.
2. Require: one new `Documents/Signed/<uuid>` directory, one new Library record, success completion (signing sheet dismisses).
3. With **Install After Signing** / **Delete After Signing** enabled, confirm those actions run only on this success path.

## onlyModify vs missing certificate

1. Set **Signing Type** to **Modify** (`onlyModify`) with no certificate selected. The operation must still succeed and persist a Signed artifact and Library record (intentional onlyModify path).
2. Set **Signing Type** to **Default** with no certificate. The UI should refuse to start, or `modify()` should throw `missingCertifcate` before `move()` / `addToDatabase()`. No new Signed artifact or record.

## Optional natural reproduction

If LiveContainer / custom-entitlements inputs from issue #704 are available, run Default signing with those entitlements. Accept either a successful signature or an explicit failure with no newly persisted Signed artifact. Do not require the original buffer-allocation failure after Zsign pin updates.
