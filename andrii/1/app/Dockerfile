FROM node:18-slim as builder
WORKDIR /builder
COPY . .
RUN npm ci; \
    npm run build; \
    npm prune --omit-dev


FROM web-server:0.0.2 as runtime
COPY --from=builder /builder/build /usr/share/nginx/html
