FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

# Install all necessary packages
RUN apt-get update && apt-get install -y \
    supervisor x11vnc xvfb fluxbox wget curl unzip gnupg \
    python3-pip websockify procps xfonts-base \
    libglib2.0-0 libx11-6 libxext6 libxrender1 libsm6 libxrandr2 \
    libfreetype6 libfontconfig1 libstdc++6 zlib1g libgtk-3-0 \
    libnss3 libxss1 libasound2 libatk1.0-0 libcups2 libgbm1 \
    chromium \
    && rm -rf /var/lib/apt/lists/*

# Set up ResellKit (AppImage already extracted)
COPY resellkit-extracted /opt/resellkit/
WORKDIR /opt/resellkit
RUN chmod +x /opt/resellkit/resellkit

# Set up noVNC
RUN wget https://github.com/novnc/noVNC/archive/refs/heads/master.zip -O /tmp/novnc.zip && \
    unzip /tmp/novnc.zip -d /opt && \
    mv /opt/noVNC-master /opt/novnc && \
    ln -sf /opt/novnc/vnc.html /opt/novnc/index.html

# Supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add ResellKit and Chromium to the Fluxbox menu
RUN sed -i "/\[end\]/i \
  [exec] (Open Chromium) {/usr/bin/chromium --no-sandbox --disable-gpu}\
\n  [exec] (Start ResellKit) {/opt/resellkit/resellkit --no-sandbox}\
\n  [separator]" /etc/X11/fluxbox/fluxbox-menu


EXPOSE 8080
CMD ["/usr/bin/supervisord", "-n"]
