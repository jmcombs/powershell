# powershell

LTS versions of PowerShell Core and .NET Core in Linux. Published for 64-bit `x86` and `ARM` architectures.

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/jmcombs/powershell/ci.yml?logo=github)
[![Docker Pulls](https://img.shields.io/docker/pulls/jmcombs/powershell)](https://hub.docker.com/r/jmcombs/powershell "Click to view the image on Docker Hub")
[![Docker Stars](https://img.shields.io/docker/stars/jmcombs/powershell)](https://hub.docker.com/r/jmcombs/powershell "Click to view the image on Docker Hub")
[![Github Issues](https://img.shields.io/github/issues/jmcombs/powershell)](https://github.com/jmcombs/powershell/issues "Click to view or open issues")

## About

This container is based on the the latest Long Term Support (LTS) [Ubuntu (Docker Official Image)](https://hub.docker.com/_/ubuntu) image along with the latest LTS releases of .NET Core Runtime and PowerShell Core.

## Versions

This repository does automated weekly builds with the latest published LTS versions of .NET Core and PowerShell Core. Below are the current versions included in the latest build.

| Component         | Version |
| ----------------- | ------- |
| .NET Core Runtime | 8.0.14  |
| PowerShell Core   | 7.4.7   |

## How to Use

### **Requirements**

- Container's non-root and default user is `coder`
- Container's default shell is `pwsh`
- Container's default working directory is `/home/coder`

### **Running Container**

```shell
docker run -it jmcombs/powershell
```
