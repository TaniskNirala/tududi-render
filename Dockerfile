FROM chrisvel/tududi:latest

# Install rclone and cron on top of the existing Tududi image
USER root
RUN apt-get update && apt-get install -y \
    rclone \
    cron \
    && rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3002
ENTRYPOINT ["/start.sh"]