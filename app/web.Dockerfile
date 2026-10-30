# The Flutter web app inside Caddy (used by infra/docker-compose.prod.yml).
# Build the app first: flutter build web --release --pwa-strategy=none
FROM caddy:2-alpine
COPY build/web /srv
