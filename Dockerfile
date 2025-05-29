FROM dart:stable

WORKDIR /app/backend

COPY backend ./

RUN dart pub get

CMD ["dart", "run", "main.dart"]
