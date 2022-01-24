ARG BASE_IMAGE="ubuntu"
ARG TAG="21.10"
FROM ${BASE_IMAGE}:${TAG}

ENV DEBIAN_FRONTEND="noninteractive"

# Install prerequisites
ARG WINE_BRANCH="stable"
#        hub \
RUN \
  apt update \
  && apt install -y --no-install-recommends \
     ca-certificates \
     curl \
     git \
     gosu \
     jq \
     liblttng-ust0 \
     p7zip-full \
     tzdata \
     unzip \
     x11-apps \
     x11-utils \
     xvfb \
  && apt -y autoclean \
  && apt -y autoremove \
  && rm -rf /var/lib/apt/lists/*

# install wine
RUN \
  dpkg --add-architecture i386 \
  && apt update \
  && apt -y install libgcc-s1:i386 || : \
  && apt -y install wine32 \
  && apt -y autoclean \
  && apt -y autoremove \
  && rm -rf /var/lib/apt/lists/*

# install powershell
RUN \
  curl --verbose "https://api.github.com/repos/PowerShell/PowerShell/releases/latest" | \
  jq '.assets[] | select(.name|match("lts.*deb")) | .browser_download_url' | \
    sed -r 's/(^"|"$)//g' | \
    while read url; do \
      echo url: ${url}; \
      curl --verbose --silent --location --remote-name "${url}"; \
      apt install -y ./"$(basename "${url}")"; \
      rm "$(basename "${url}")"; \
    done

RUN \
  pa_dir=/pa-build; \
  mkdir -p ${pa_dir} \
  && cd ${pa_dir} \
  && git clone https://github.com/uroesch/PortableApps.comInstaller.git \
  && git clone -b patched https://github.com/uroesch/PortableApps.comLauncher.git \
  && find ${pa_dir} -type f | while IFS=$'\n' read file; do chmod go+r "${file}"; done \
  && find ${pa_dir} -type d -o -name ".exe" | while IFS=$'\n' read file; do chmod go+rx "${file}"; done
  # neither -exec or xargs did the job so I simply loop through files :(

COPY entrypoint.sh /usr/bin/entrypoint
ENTRYPOINT ["/usr/bin/entrypoint"]
