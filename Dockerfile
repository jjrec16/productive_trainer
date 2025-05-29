FROM dart:stable

WORKDIR /app/backend  # <-- zmieniamy katalog roboczy na backend

COPY backend ./  # kopiujemy zawartość folderu backend do katalogu roboczego w kontenerze

RUN dart pub get

CMD ["dart", "run", "main.dart"]
