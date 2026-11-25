FROM alpine:3.20
RUN apk add --no-cache bash coreutils
COPY scripts/ /opt/scripts/
CMD ["/opt/scripts/disk_check.sh"]
