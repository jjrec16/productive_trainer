# Pobierz oficjalny obraz Dart z Docker Hub
FROM dart:stable

# Ustaw katalog roboczy w kontenerze na /app
WORKDIR /app

# Skopiuj wszystkie pliki projektu do kontenera
COPY . .

# Zainstaluj zależności Dart
RUN dart pub get

# Uruchom backend Dart (dopasuj ścieżkę, jeśli masz inny plik main.dart)
CMD ["dart", "run", "backend/main.dart"]
