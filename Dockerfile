FROM debian:stable-slim AS base-gpc

RUN apt-get update
RUN apt-get install curl python3-pil git python3 build-essential pkg-config -y

# Install the C/C++ SDK and compiler
RUN apt install cmake libusb-1.0-0-dev libsdl2-dev libudisks2-dev libglib2.0-dev libpng-dev libncurses5-dev -y
RUN apt install libmpfr-dev libmpc-dev libgmp-dev libppl-dev flex texinfo python-is-python3 clangd openssl -y

# Codespace
ENV USERNAME="dev"

RUN apt install sudo -y

RUN useradd -rm -d /home/$USERNAME -s /bin/bash -g root -G sudo -u 1001 -p "$(openssl passwd -1 ${USERNAME})" $USERNAME
# RUN useradd -m -s /bin/bash -G sudo -u 1001 $USERNAME
RUN echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER $USERNAME
WORKDIR /home/$USERNAME

ENV PATH="/home/$USERNAME/.local/bin:$PATH"
RUN mkdir /home/$USERNAME/.local/
RUN mkdir /home/$USERNAME/.local/bin

RUN mkdir /tmp/giteapc-install
WORKDIR /tmp/giteapc-install

ARG USERNAME=user
ENV GITEAPC_PREFIX=/home/$USERNAME/.local
ENV PATH="${GITEAPC_PREFIX}/bin:${PATH}"

RUN git clone --depth=1 https://git.planet-casio.com/Lephenixnoir/GiteaPC .
RUN giteapc --version

WORKDIR /home/$USERNAME/giteapc
RUN giteapc install Lephenixnoir/GiteaPC -y

# sysroot is part of fxsdk so this is needed first
RUN giteapc install Lephenixnoir/fxsdk@dev -y
RUN giteapc install Lephenixnoir/sh-elf-binutils:clean -y
RUN giteapc install Lephenixnoir/sh-elf-gcc:clean -y
RUN giteapc install Lephenixnoir/sh-elf-gdb -y

RUN giteapc install Lephenixnoir/OpenLibm -y
RUN giteapc install Vhex-Kernel-Core/fxlibc@dev -y
RUN giteapc install Lephenixnoir/sh-elf-gcc -y  # again for any rebuild/update
RUN giteapc install Lephenixnoir/gint@dev -y
RUN giteapc install Lephenixnoir/JustUI@dev -y

# USER $USERNAME
# WORKDIR /home/$USERNAME

# RUN echo "export SDK_DIR=${SDK_DIR}" >> ~/.bashrc
# RUN echo "export OLD_SDK_DIR=${OLD_SDK_DIR}" >> ~/.bashrc

WORKDIR /workspace
# RUN fxsdk new my-addin
# RUN cd my-addin
# RUN fxsdk build-cp
