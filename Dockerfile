FROM chrisvel/tududi:latest

USER root
RUN apk add --no-cache rclone dcron || \
    apt-get update && apt-get install -y rclone cron && \
    rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3002
ENTRYPOINT ["/start.sh"]
