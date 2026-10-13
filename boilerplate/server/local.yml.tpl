services:
  postgres:
    image: postgres:18
    container_name: ${APP_NAME}-postgres
    ports:
      - "${DB_PORT:-5432}:5432"
    volumes:
      - ${PWD}/storage/postgres:/var/lib/postgresql
    environment:
      POSTGRES_USER: ${DB_USERNAME}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: ${DB_DATABASE}

  redis:
    image: redis:8-alpine
    container_name: ${APP_NAME}-redis
    ports:
      - "${REDIS_PORT:-6379}:6379"
    volumes:
      - ${PWD}/storage/redis:/data
    environment:
      REDIS_PASSWORD: ${REDIS_PASSWORD}
    command: redis-server --requirepass ${REDIS_PASSWORD} --appendonly yes
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
      interval: 5s
      timeout: 5s
      retries: 5

  minio:
    image: minio/minio:latest
    container_name: ${APP_NAME}-minio
    command: minio server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: ${AWS_ACCESS_KEY_ID}
      MINIO_ROOT_PASSWORD: ${AWS_SECRET_ACCESS_KEY}
    ports:
      - "${MINIO_PORT_FORWARD:-9000}:9000"
      - "${MINIO_CONSOLE_PORT_FORWARD:-9001}:9001"
    volumes:
      - ${PWD}/storage/minio:/data
    healthcheck:
      test: ["CMD", "mc", "ready", "local"]
      interval: 5s
      timeout: 5s
      retries: 5

  minio-init:
    image: minio/mc:latest
    container_name: ${APP_NAME}-minio-init
    depends_on:
      minio:
        condition: service_healthy
    environment:
      MINIO_ROOT_USER: ${AWS_ACCESS_KEY_ID}
      MINIO_ROOT_PASSWORD: ${AWS_SECRET_ACCESS_KEY}
    entrypoint:
      - /bin/sh
      - -c
      - |
        until mc alias set minio http://minio:9000 $$MINIO_ROOT_USER $$MINIO_ROOT_PASSWORD; do
          echo 'Waiting for MinIO...'
          sleep 1
        done
        mc mb minio/${AWS_BUCKET} --ignore-existing
        echo 'Media bucket created successfully'
    restart: "no"

networks:
  default:
    name: ${APP_NAME}
    driver: bridge
