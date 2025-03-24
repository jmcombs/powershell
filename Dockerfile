FROM ubuntu:latest AS base

# Define build arguments
ARG TARGETARCH
ARG NET_RUNTIME_LTS_VERSION
ARG NET_RUNTIME_URL_arm
ARG NET_RUNTIME_PACKAGE_NAME_arm
ARG NET_RUNTIME_URL_arm64
ARG NET_RUNTIME_PACKAGE_NAME_arm64
ARG NET_RUNTIME_URL_x64
ARG NET_RUNTIME_PACKAGE_NAME_x64
ARG PWSH_LTS_URL_arm32
ARG PWSH_LTS_PACKAGE_NAME_arm32
ARG PWSH_LTS_URL_arm64
ARG PWSH_LTS_PACKAGE_NAME_arm64
ARG PWSH_LTS_URL_x64
ARG PWSH_LTS_PACKAGE_NAME_x64
ARG PWSH_LTS_VERSION
ARG PWSH_LTS_MAJOR_VERSION

# Set environment variables based on build arguments
ENV DOTNET_VERSION=${NET_RUNTIME_LTS_VERSION}
ENV DOTNET_ROOT=/opt/microsoft/dotnet/${DOTNET_VERSION}
ENV PS_VERSION=${PWSH_LTS_VERSION}
ENV PS_MAJOR_VERSION=${PWSH_LTS_MAJOR_VERSION}
ENV PS_INSTALL_FOLDER=/opt/microsoft/powershell/${PS_MAJOR_VERSION}

# If exists, remove 'ubuntu' user
RUN	if id "ubuntu" &>/dev/null; then \
		echo "Deleting user 'ubuntu'" && userdel -f -r ubuntu || echo "Failed to delete ubuntu user"; \  
	else \
		echo "User 'ubuntu' does not exist"; \ 
	fi;

# Install sudo and other necessary packages
RUN apt-get update \
    && apt-get -y install --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    jq \
    locales \
    software-properties-common \
    sudo

# Set US English and UTF-8 Locale
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG=en_US.utf8

# Defining non-root User
ARG USERNAME=coder
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Set up User and grant sudo privileges 
# apt-get package: sudo
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID --shell /bin/zsh --create-home $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
WORKDIR /home/$USERNAME

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM base AS linux-amd64
ENV DOTNET_PACKAGE_URL=${NET_RUNTIME_URL_x64}
ENV DOTNET_PACKAGE=${NET_RUNTIME_PACKAGE_NAME_x64}
ENV PS_PACKAGE_URL=${PWSH_LTS_URL_x64}
ENV PS_PACKAGE=${PWSH_LTS_PACKAGE_NAME_x64}

FROM base AS linux-arm64
ENV DOTNET_PACKAGE_URL=${NET_RUNTIME_URL_arm64}
ENV DOTNET_PACKAGE=${NET_RUNTIME_PACKAGE_NAME_arm64}
ENV PS_PACKAGE_URL=${PWSH_LTS_URL_arm64}
ENV PS_PACKAGE=${PWSH_LTS_PACKAGE_NAME_arm64}

FROM base AS linux-arm
ENV DOTNET_PACKAGE_URL=${NET_RUNTIME_URL_arm}
ENV DOTNET_PACKAGE=${NET_RUNTIME_PACKAGE_NAME_arm}
ENV PS_PACKAGE_URL=${PWSH_LTS_URL_arm32}
ENV PS_PACKAGE=${PWSH_LTS_PACKAGE_NAME_arm32}

FROM linux-${TARGETARCH} AS msft-install

RUN export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools \
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