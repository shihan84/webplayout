FROM alpine:latest

ARG FFPLAYOUT_VERSION=1.1.0

ENV DB=/db

# Install dependencies
RUN apk update && \
    apk upgrade && \
    apk add --no-cache ffmpeg sqlite font-dejavu curl && \
    mkdir ${DB}

# Download ffplayout release
RUN wget -q "https://github.com/ffplayout/ffplayout/releases/download/v${FFPLAYOUT_VERSION}/ffplayout-v${FFPLAYOUT_VERSION}_x86_64-unknown-linux-musl.tar.gz" -P /tmp/ && \
    cd /tmp && \
    tar xf "ffplayout-v${FFPLAYOUT_VERSION}_x86_64-unknown-linux-musl.tar.gz" && \
    cp ffplayout /usr/bin/ && \
    mkdir -p /usr/share/ffplayout/ && \
    cp assets/dummy.vtt assets/logo.png assets/DejaVuSans.ttf assets/FONT_LICENSE.txt /usr/share/ffplayout/ 2>/dev/null || true && \
    rm -rf /tmp/*

# Copy entrypoint script
COPY entrypoint.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 8787

CMD ["/run.sh"]
