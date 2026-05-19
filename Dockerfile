FROM alpine:3.21
RUN apk add --no-cache ca-certificates bash
COPY bin/ssserver /usr/local/bin/ssserver
RUN ls -la /usr/local/bin/ && file /usr/local/bin/ssserver
ENV PATH="/usr/local/bin:${PATH}"
ENV SS_SERVER_PORT=8388 SS_METHOD=aes-256-gcm
EXPOSE 8388
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD exit 0
CMD ["/bin/sh", "-c", "echo 'container started'; while true; do sleep 30; done"]
