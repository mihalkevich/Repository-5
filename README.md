# LeafLens (SwiftUI, iOS 16+)

Minimal scaffold for a SwiftUI-based leaf identification app.

## Structure

- Sources/
  - App/
  - Features/ (Capture, Identify, Results, History)
  - Services/ (MLService, StorageService, SpeciesDB)
  - Shared/ (Models, UI, Utils)
- Models/ (compiled Core ML model `PlantClassifier.mlmodelc` will be placed here)
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

- `MLService` is ready for a Core ML model. It will try to load a compiled model from the app bundle if present, otherwise it falls back to a mock classification with built-in species.
- `SpeciesDB` loads from `Sources/Services/SpeciesDB/species.json`.

## Как заменить модель (CoreML)

1. Получите файл модели `PlantClassifier.mlmodel` (мультиклассовая классификация листьев).
2. Скомпилируйте модель в формат `.mlmodelc` (папка-артефакт):

   ```sh
   xcrun coremlc compile PlantClassifier.mlmodel ./Models
   ```

   В результате появится каталог `./Models/PlantClassifier.mlmodelc`.
3. Сгенерируйте проект (`xcodegen generate`) и соберите. Каталог `Models/PlantClassifier.mlmodelc` автоматически встраивается в бандл приложения.
4. `MLService` найдёт модель в бандле и начнёт использовать её. Если каталога нет, сервис продолжит работать в mock-режиме (без падений).