FROM chrisvel/tududi:latest

USER root
RUN apk add --no-cache rclone dcron

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3002
ENTRYPOINT ["/start.sh"]
