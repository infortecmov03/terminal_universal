# Criar estrutura de pastas
mkdir -p lib/core/interfaces
mkdir -p lib/core/device_manager
mkdir -p lib/core/constants
mkdir -p lib/features/terminal
mkdir -p .github/workflows
mkdir -p android/app/src/main/kotlin/com/example/terminal_universal
mkdir -p test

# Criar todos os arquivos vazios
touch pubspec.yaml
touch .gitignore
touch README.md

# Lib core
touch lib/main.dart
touch lib/core/interfaces/device_interface.dart
touch lib/core/device_manager/terminal_manager.dart
touch lib/core/device_manager/real_bluetooth_device.dart
touch lib/core/device_manager/simulated_device.dart
touch lib/core/constants/device_constants.dart
touch lib/features/terminal/terminal_screen.dart

# Test
touch test/widget_test.dart

# Android
touch android/app/src/main/AndroidManifest.xml
touch android/app/src/main/kotlin/com/example/terminal_universal/MainActivity.kt
touch android/app/build.gradle

# GitHub Actions
touch .github/workflows/build-apk.yml

# Arquivo para assets (opcional)
mkdir -p assets
touch assets/.gitkeep

echo "✅ Estrutura completa criada com sucesso!"
echo "📁 Total de arquivos criados: $(find . -name "*.dart" -o -name "*.yaml" -o -name "*.yml" -o -name "*.xml" -o -name "*.kt" -o -name "*.gradle" -o -name "*.md" | wc -l)"