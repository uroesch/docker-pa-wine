ARG BASE_IMAGE="ubuntu"
ARG TAG="18.04"
FROM ${BASE_IMAGE}:${TAG}

# Install prerequisites
ARG WINE_BRANCH="stable"
#        hub \
RUN \
  apt-get update \
  && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    gosu \
    jq \
    liblttng-ust0 \
    p7zip-full \
    tzdata \
    unzip \
    xvfb \
  && apt-get -y autoclean \
  && rm -rf /var/lib/apt/lists/*

# install wine
RUN \
  dpkg --add-architecture i386 \
  && apt-get update \
  && apt-get -y install wine32 \
  && apt-get -y autoclean \
  && rm -rf /var/lib/apt/lists/*

# install the powershell dependencies not provided in 20.04
RUN \
  base_url="http://archive.ubuntu.com/ubuntu/pool/main"; \
  for path in \
    "/o/openssl1.0/libssl1.0.0_1.0.2n-1ubuntu5.4_amd64.deb" \
    "/i/icu/libicu60_60.2-3ubuntu3.1_amd64.deb"; do \
    curl --silent --location --remote-name "${base_url}${path}" \
    && echo "$(basename ${path})" \
    && dpkg -i "$(basename ${path})" \
    && rm "$(basename ${path})"; \
  done

# install powershell
RUN \
  curl --silent "https://api.github.com/repos/PowerShell/PowerShell/releases/latest" | \
  jq '.assets[] | select(.name|match("ubuntu.18.04")) | .browser_download_url' | \
    sed -r 's/(^"|"$)//g' | \
    while read url; do \
      echo url: ${url}; \
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

COPY entrypoint.sh /usr/bin/entrypoint
ENTRYPOINT ["/usr/bin/entrypoint"]
