FROM ubuntu:latest AS base

# Set US English and UTF-8 Locale
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG=en_US.utf8

# If exists, remove 'ubuntu' user
RUN	if id "ubuntu" &>/dev/null; then \
		echo "Deleting user 'ubuntu'" && userdel -f -r ubuntu || echo "Failed to delete ubuntu user"; \  
	else \
		echo "User 'ubuntu' does not exist"; \ 
	fi;

# Switching to non-interactive for cotainer build
ENV DEBIAN_FRONTEND=noninteractive

# Dockerfile ARG variables set automatically to aid in software installation
ARG TARGETARCH
ARG DOTNET_PACKAGE_URL
ARG DOTNET_VERSION
ENV DOTNET_VERSION=${NET_RUNTIME_LTS_VERSION}
ARG PS_PACKAGE_URL
ARG PS_PACKAGE
ARG PS_VERSION
ENV PS_VERSION=${PWSH_LTS_VERSION}
ARG PS_MAJOR_VERSION
ENV PS_MAJOR_VERSION=${PWSH_LTS_MAJOR_VERSION}
ARG PS_INSTALL_FOLDER
ENV PS_INSTALL_FOLDER=/opt/microsoft/powershell/${PS_MAJOR_VERSION}

# Configure apt and install packages
RUN apt-get update \
    && apt-get -y install software-properties-common \
    && apt-get -y install --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        jq \
        locales

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM base AS linux-amd64
ENV DOTNET_PACKAGE_URL=${NET_RUNTIME_URL_x64}
ENV PS_PACKAGE_URL=${PWSH_LTS_URL_x64}
ENV PS_PACKAGE=${PWSH_LTS_PACKAGE_x64}

FROM base AS linux-arm64
ENV DOTNET_PACKAGE_URL=${NET_RUNTIME_URL_arm64}
ENV PS_PACKAGE_URL=${PWSH_LTS_URL_arm64}
ENV PS_PACKAGE=${PWSH_LTS_PACKAGE_arm64}

FROM base AS linux-arm
ENV DOTNET_PACKAGE_URL=${NET_RUNTIME_URL_arm}
ENV PS_PACKAGE_URL=${PWSH_LTS_URL_arm32}
ENV PS_PACKAGE=${PWSH_LTS_PACKAGE_arm32}

FROM linux-${TARGETARCH} AS msft-install

RUN DOTNET_PACKAGE=$(basename ${DOTNET_PACKAGE_URL}) \
    && ENV DOTNET_ROOT=/opt/microsoft/dotnet/${DOTNET_VERSION} \
    && ENV PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools \
    && curl -o /tmp/${DOTNET_PACKAGE} ${DOTNET_PACKAGE_URL} \
    && mkdir -p ${DOTNET_ROOT} \
    && tar zxf /tmp/${DOTNET_PACKAGE} -C ${DOTNET_ROOT} \
    && rm /tmp/${DOTNET_PACKAGE}

# PowerShell Core LTS
RUN curl -LO ${PS_PACKAGE_URL} \
    && mkdir -p ${PS_INSTALL_FOLDER} \
    && tar zxf ${PS_PACKAGE} -C ${PS_INSTALL_FOLDER} \
    && chmod a+x,o-w ${PS_INSTALL_FOLDER}/pwsh \
    && ln -s ${PS_INSTALL_FOLDER}/pwsh /usr/bin/pwsh \
    && rm ${PS_PACKAGE} \
    && echo /usr/bin/pwsh >> /etc/shells

# Switch to non-root user for remainder of build
USER $USERNAME

# Switching back to interactive after container build
ENV DEBIAN_FRONTEND=dialog
# Setting entrypoint to Powershell
ENTRYPOINT ["pwsh"]