# LeafLens (SwiftUI, iOS 16+)

Minimal scaffold for a SwiftUI-based leaf identification app.

## Structure

- Sources/
  - App/
  - Features/ (Capture, Identify, Results, History)
  - Services/ (MLService, StorageService, SpeciesDB)
  - Shared/ (Models, UI, Utils)
- Tests/LeafLensTests

## Requirements

- iOS 16+
- Xcode 15+

## Generate Xcode project (recommended)

This repo includes an XcodeGen `project.yml` to link system frameworks and set the deployment target.

1. Install XcodeGen: `brew install xcodegen`
2. Run: `xcodegen generate`
3. Open `LeafLens.xcodeproj` in Xcode and run on device/simulator.

## Permissions

Added in `Sources/App/Info.plist`:
- `NSCameraUsageDescription`
- `NSPhotoLibraryAddUsageDescription`

## Notes

- `MLService` is ready for a Core ML model. Inject your compiled `MLModel` when initializing the service.
- `SpeciesDB` loads from `Sources/Services/SpeciesDB/species.json`.