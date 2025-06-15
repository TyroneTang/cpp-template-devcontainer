FROM ubuntu:24.04 AS base

ENV DEBIAN_FRONTEND=noninteractive

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

SHELL ["/bin/bash", "-c"]

RUN mkdir -p /root/workspace
RUN mkdir -p /root/Documents/oh_my_posh

ENV HOME=/root

# ---------- DEV UTILS --------------- #
RUN --mount=target=/var/lib/apt/lists/cpp_base,type=cache,sharing=locked \
    --mount=target=/var/cache/apt/cpp_base,type=cache,sharing=locked \
    apt update -y && \
    apt install -y \
    git \
    bash-completion \
    iproute2 \
    wget \
    nano \
    iputils-ping \
    openssh-client \
    curl \
    rsync \
    vim \
    build-essential \
    locales \
    software-properties-common \
    gnupg \
    unzip \
    zip \
    pkg-config


RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor > /etc/apt/trusted.gpg.d/llvm-archive-keyring.gpg
RUN echo "deb [signed-by=/etc/apt/trusted.gpg.d/llvm-archive-keyring.gpg] http://apt.llvm.org/noble/ llvm-toolchain-noble-19 main" > /etc/apt/sources.list.d/llvm.list

RUN apt-get update

# gcc compiler
RUN --mount=target=/var/lib/apt/lists/cpp_base,type=cache,sharing=locked \
    --mount=target=/var/cache/apt/cpp_base,type=cache,sharing=locked \
    apt update -y && \
    apt install -y \
    clang-19 \
    clangd-19 \
    lldb-19 \
    lld-19 \
    clang-tidy-19 \
    libx11-dev \
    libxrandr-dev 

RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-19 100
RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-19 100
RUN update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-19 100
RUN update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb-19 100
RUN update-alternatives --install /usr/bin/lld lld /usr/bin/lld-19 100
RUN update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-19 100

ENV PATH="/usr/bin/clangd:${PATH}"

# cmake
RUN wget -O /root/cmake-install.sh https://github.com/Kitware/CMake/releases/download/v4.0.3/cmake-4.0.3-linux-x86_64.sh
RUN chmod +x /root/cmake-install.sh
RUN mkdir -p /opt/cmake-4.0.3
RUN cd /root && ./cmake-install.sh --prefix=/opt/cmake-4.0.3 --skip-license

RUN update-alternatives --install /usr/bin/cmake cmake /opt/cmake-4.0.3/bin/cmake 100
RUN update-alternatives --install /usr/bin/ctest ctest /opt/cmake-4.0.3/bin/ctest 100
RUN update-alternatives --install /usr/bin/cpack cpack /opt/cmake-4.0.3/bin/cpack 100

ENV PATH="/opt/cmake-4.0.3/bin:${PATH}"

# ninja
RUN wget -O /root/ninja-linux.zip https://github.com/ninja-build/ninja/releases/download/v1.12.1/ninja-linux.zip
RUN cd /root && unzip ninja-linux.zip
RUN mv /root/ninja /usr/bin/ninja
RUN chmod +x /usr/bin/ninja

ENV PATH="/usr/bin/ninja:${PATH}"

# vcpkg
RUN mkdir -p /root/vcpkg
RUN git clone https://github.com/microsoft/vcpkg.git /root/vcpkg
RUN ./root/vcpkg/bootstrap-vcpkg.sh

# # setup
# to make extensions be detectable and work.
ENV VCPKG_ROOT=/root/vcpkg
ENV PATH="$VCPKG_ROOT:$PATH"

# RUN echo 'export PATH=/usr/bin/ninja:"$PATH"' >> ~/.bashrc
# RUN echo 'export PATH=/usr/bin/clangd:"$PATH"' >> ~/.bashrc