# Criar pastas
New-Item -ItemType Directory -Force -Path "lib/core/interfaces"
New-Item -ItemType Directory -Force -Path "lib/core/device_manager"
New-Item -ItemType Directory -Force -Path "lib/core/constants"
New-Item -ItemType Directory -Force -Path "lib/features/terminal"
New-Item -ItemType Directory -Force -Path ".github/workflows"
New-Item -ItemType Directory -Force -Path "android/app/src/main/kotlin/com/example/terminal_universal"
New-Item -ItemType Directory -Force -Path "test"
New-Item -ItemType Directory -Force -Path "assets"

# Criar arquivos
@(
    "pubspec.yaml",
    ".gitignore", 
    "README.md",
    "lib/main.dart",
    "lib/core/interfaces/device_interface.dart",
    "lib/core/device_manager/terminal_manager.dart", 
    "lib/core/device_manager/real_bluetooth_device.dart",
    "lib/core/device_manager/simulated_device.dart",
    "lib/core/constants/device_constants.dart",
    "lib/features/terminal/terminal_screen.dart",
    "test/widget_test.dart",
    "android/app/src/main/AndroidManifest.xml",
    "android/app/src/main/kotlin/com/example/terminal_universal/MainActivity.kt", 
    "android/app/build.gradle",
    ".github/workflows/build-apk.yml",
    "assets/.gitkeep"
) | ForEach-Object { New-Item -ItemType File -Path $_ }

Write-Host "✅ Estrutura completa criada com sucesso!"