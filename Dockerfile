ARG BASE_IMAGE="ubuntu"
ARG TAG="22.04"
FROM ${BASE_IMAGE}:${TAG}

ENV DEBIAN_FRONTEND="noninteractive"

# Install prerequisites
ARG WINE_BRANCH="stable"
RUN \
  apt update \
  && apt install -y --no-install-recommends \
     ca-certificates \
     curl \
     git \
     gosu \
     jq \
     liblttng-ust1 \
     p7zip-full \
     tzdata \
     unzip \
     x11-apps \
     x11-utils \
     xvfb \
  && apt -y autoclean \
  && apt -y autoremove \
  && find /var/cache/apt/archives -type f -delete \
  && rm -rf /var/lib/apt/lists/*

# install wine
RUN \
  dpkg --add-architecture i386 \
  && apt update \
  && apt -y install libgcc-s1:i386 || : \
  && apt -y install wine32 \
  && apt -y autoclean \
  && apt -y autoremove \
  && find /var/cache/apt/archives -type f -delete \
  && rm -rf /var/lib/apt/lists/*

# install powershell
RUN \
  curl --silent "https://api.github.com/repos/PowerShell/PowerShell/releases/latest" | \
  jq -r '.assets[] | select(.name|match("(lts)?.*deb")) | .browser_download_url' | \
    while read url; do \
      echo url: ${url}; \
      curl --silent --location --remote-name "${url}"; \
      apt install -y ./"$(basename "${url}")"; \
      rm "$(basename "${url}")"; \
    done

# download and install innounp
RUN \
  rar=/var/tmp/innounp.rar; \
  curl --location --silent --output ${rar} \
   "https://sourceforge.net/projects/innounp/files/latest/download"; \
  7z x -o/usr/local/bin ${rar} innounp.exe; \
  chmod 755 /usr/local/bin/innounp.exe; \
  rm ${rar}

RUN \
  pa_dir=/pa-build; \
  mkdir -p ${pa_dir} \
  && cd ${pa_dir} \
  && git clone https://github.com/uroesch/PortableApps.comInstaller.git \
  && git clone -b patched https://github.com/uroesch/PortableApps.comLauncher.git \
  && find ${pa_dir} -type f | while IFS=$'\n' read file; do chmod go+r "${file}"; done \
  && find ${pa_dir} -type d -o -name ".exe" | while IFS=$'\n' read file; do chmod go+rx "${file}"; done
  # neither -exec or xargs did the job so I simply loop through files :(

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
