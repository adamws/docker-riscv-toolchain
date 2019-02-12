FROM ubuntu:16.04

RUN apt-get update -y --fix-missing && \
    apt-get install -y wget make git gawk libncurses5-dev vim \
        libftdi1-dev usbutils udev screen && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ARG USER=risc
ARG HOME=/home/${USER}

RUN groupadd -g 1000 ${USER} && \
    mkdir ${HOME} && \
    useradd -d ${HOME} -r -u 1000 -g ${USER} ${USER} && \
    chown -R ${USER}:${USER} ${HOME}

USER ${USER}

ARG RISCV64_UNKNOWN_ELF_GCC=riscv64-unknown-elf-gcc
ARG RISCV64_UNKNOWN_ELF_GCC_VERSION=8.1.0-2019.01.0

ARG OPENOCD=riscv-openocd
ARG OPENOCD_VERSION=0.10.0-2018.12.0

ARG PLATFORM=x86_64-linux-ubuntu14

RUN cd $HOME && \
    wget https://static.dev.sifive.com/dev-tools/${RISCV64_UNKNOWN_ELF_GCC}-${RISCV64_UNKNOWN_ELF_GCC_VERSION}-${PLATFORM}.tar.gz && \
    tar -xvf ${RISCV64_UNKNOWN_ELF_GCC}-${RISCV64_UNKNOWN_ELF_GCC_VERSION}-${PLATFORM}.tar.gz && \
    wget https://static.dev.sifive.com/dev-tools/${OPENOCD}-${OPENOCD_VERSION}-${PLATFORM}.tar.gz && \
    tar -xvf ${OPENOCD}-${OPENOCD_VERSION}-${PLATFORM}.tar.gz && \
    rm -rf *.tar.gz && \
    mv ${RISCV64_UNKNOWN_ELF_GCC}-${RISCV64_UNKNOWN_ELF_GCC_VERSION}-${PLATFORM} ${RISCV64_UNKNOWN_ELF_GCC} && \
    mv ${OPENOCD}-${OPENOCD_VERSION}-${PLATFORM} ${OPENOCD}

# why older revision needed: https://github.com/sifive/freedom-e-sdk/issues/134
RUN cd $HOME && \
    git clone https://github.com/sifive/freedom-e-sdk.git && \
    cd freedom-e-sdk && \
    git reset --hard baeeb8fd497a99b3c141d7494309ec2e64f19bdf && \
    git submodule update --init --recursive

ENV RISCV_OPENOCD_PATH=${HOME}/${OPENOCD}
ENV RISCV_PATH=${HOME}/${RISCV64_UNKNOWN_ELF_GCC}

RUN cd $HOME/freedom-e-sdk && \
    wget https://static.dev.sifive.com/dev-tools/flash_bootloader.sh && \
    chmod +x flash_bootloader.sh

# this modified openocd.cfg has matching ftdi_device_desc set
COPY openocd.cfg ${HOME}/freedom-e-sdk/bsp/env/freedom-e300-hifive1/

USER root
RUN wget https://raw.githubusercontent.com/riscv/riscv-openocd/riscv/contrib/60-openocd.rules && \
    cp 60-openocd.rules /etc/udev/rules.d && \
    adduser root plugdev
    
USER root

WORKDIR /home/risc
