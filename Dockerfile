ARG BASE_IMAGE="ubuntu"
ARG TAG="latest"
FROM ${BASE_IMAGE}:${TAG}

# Install prerequisites
RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        cabextract \
        git \
        gosu \
        gpg-agent \
        p7zip-full \
        pulseaudio \
        pulseaudio-utils \
        software-properties-common \
        tzdata \
        unzip \
        wget \
        winbind \
        xvfb \
        zenity \
        curl \
        jq \
        hub \
        liblttng-ust0 \
    && rm -rf /var/lib/apt/lists/*

# Install wine
ARG WINE_BRANCH="stable"
RUN wget -nv -O- https://dl.winehq.org/wine-builds/winehq.key | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add - \
    && apt-add-repository "deb https://dl.winehq.org/wine-builds/ubuntu/ $(grep VERSION_CODENAME= /etc/os-release | cut -d= -f2) main" \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --install-recommends winehq-${WINE_BRANCH} \
    && rm -rf /var/lib/apt/lists/*

# Download gecko and mono installers
COPY download_gecko_and_mono.sh /root/download_gecko_and_mono.sh
RUN chmod +x /root/download_gecko_and_mono.sh \
    && /root/download_gecko_and_mono.sh "$(dpkg -s wine-${WINE_BRANCH} | grep "^Version:\s" | awk '{print $2}' | sed -E 's/~.*$//')"

# install powershell
RUN \
  curl --silent "https://api.github.com/repos/PowerShell/PowerShell/releases/latest" | \
  jq '.assets[] | select(.name|match("ubuntu.20.04")) | .browser_download_url' | \
    sed -r 's/(^"|"$)//g' | \
    while read url; do \
      curl --silent --location --remote-name "${url}"; \
      apt-get install -y ./"$(basename "${url}")"; \
      rm "$(basename "${url}")"; \
    done

RUN \
  url="https://raw.githubusercontent.com/uroesch/PortableApps/master/scripts/download-pa-dev-pkgs.ps1"; \
  mkdir -p /pa-build/scripts \
  && cd /pa-build/scripts \
  && curl --location --remote-name "${url}" \
  && pwsh -ExecutionPolicy ByPass -File "$(basename ${url})" \
  && rm /pa-build/*exe

COPY pulse-client.conf /root/pulse/client.conf
COPY entrypoint.sh /usr/bin/entrypoint
ENTRYPOINT ["/usr/bin/entrypoint"]
