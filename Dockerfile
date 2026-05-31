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

# Install sudo and other necessary packages
RUN apt-get update \
    && apt-get -y install --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    fontconfig \
    git \
    jq \
    locales \
    software-properties-common \
    sudo \
    unzip \
    wget

# Set US English and UTF-8 Locale
RUN sed -i '/^# *en_US.UTF-8 UTF-8/s/^# *//' /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

# Defining non-root User
ARG USERNAME=coder
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Set up User and grant sudo privileges
# apt-get package: sudo
RUN existing_group="$(getent group "$USER_GID" | cut -d: -f1 || true)" \
    && if [ -n "$existing_group" ]; then \
        [ "$existing_group" = "$USERNAME" ] || groupmod --new-name "$USERNAME" "$existing_group"; \
    else \
        groupadd --gid "$USER_GID" "$USERNAME"; \
    fi \
    && existing_user="$(getent passwd "$USER_UID" | cut -d: -f1 || true)" \
    && if [ -n "$existing_user" ]; then \
        if [ "$existing_user" = "$USERNAME" ]; then \
            usermod --gid "$USER_GID" --shell /bin/bash --home "/home/$USERNAME" "$USERNAME"; \
        else \
            usermod --login "$USERNAME" --home "/home/$USERNAME" --move-home --gid "$USER_GID" --shell /bin/bash "$existing_user"; \
        fi; \
    elif id "$USERNAME" &>/dev/null; then \
        usermod --uid "$USER_UID" --gid "$USER_GID" --shell /bin/bash --home "/home/$USERNAME" "$USERNAME"; \
    else \
        useradd --uid "$USER_UID" --gid "$USER_GID" --shell /bin/bash --create-home "$USERNAME"; \
    fi \
    && mkdir -p "/home/$USERNAME" \
    && chown "$USER_UID":"$USER_GID" "/home/$USERNAME" \
    && echo "$USERNAME ALL=\(root\) NOPASSWD:ALL" > "/etc/sudoers.d/$USERNAME" \
    && chmod 0440 "/etc/sudoers.d/$USERNAME"
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

# Install Oh My Posh
RUN curl -s https://ohmyposh.dev/install.sh | bash -s -- -d /usr/local/bin

# Oh My Posh Environment Variables (runtime configuration)
# ENABLE_OHMYPOSH: Set to 'false' or '0' to disable Oh My Posh prompt
# OHMYPOSH_THEME: Theme name (e.g., 'atomic') or URL; empty uses embedded Blue PSL 10K
ENV ENABLE_OHMYPOSH=true
ENV OHMYPOSH_THEME=""

# Switch to non-root user for remainder of build
USER $USERNAME

# Create PowerShell profile directory
RUN mkdir -p /home/$USERNAME/.config/powershell

# Copy PowerShell profile and Oh My Posh configuration
COPY --chown=$USERNAME:$USERNAME config/Microsoft.PowerShell_profile.ps1 /home/$USERNAME/.config/powershell/
COPY --chown=$USERNAME:$USERNAME config/blue-psl-10k.omp.json /home/$USERNAME/.config/powershell/

# Install PowerShell modules during build
# Terminal-Icons: Provides file/folder icons in terminal listings
# PSReadLine: Enhanced command-line editing experience
RUN pwsh -NoProfile -Command " \
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted; \
    Write-Host 'Installing Terminal-Icons module...'; \
    Install-Module -Name Terminal-Icons -Repository PSGallery -Force -Scope CurrentUser -ErrorAction SilentlyContinue; \
    Write-Host 'Installing PSReadLine module...'; \
    Install-Module -Name PSReadLine -Repository PSGallery -Force -Scope CurrentUser -AllowPrerelease -ErrorAction SilentlyContinue; \
    Write-Host 'Module installation completed'; \
    Get-Module -ListAvailable -Name Terminal-Icons,PSReadLine | Select-Object Name,Version | Format-Table -AutoSize \
    "

# Switching back to interactive after container build
ENV DEBIAN_FRONTEND=dialog
# Setting entrypoint to Powershell with no banner
ENTRYPOINT ["pwsh", "-NoLogo"]