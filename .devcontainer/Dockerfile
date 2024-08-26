FROM --platform=linux/x86_64 mcr.microsoft.com/devcontainers/miniconda:1-3

ARG PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=cpp
ENV PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=cpp

# Copy environment.yml (if found) to a temp location so we update the environment. Also
# copy "noop.txt" so the COPY instruction does not fail if no environment.yml exists.
COPY environment.yml* .devcontainer/noop.txt /tmp/conda-tmp/
RUN if [ -f "/tmp/conda-tmp/environment.yml" ]; then umask 0002 && /opt/conda/bin/conda env update -n base -f /tmp/conda-tmp/environment.yml; fi \
    && rm -rf /tmp/conda-tmp

# [Optional] Uncomment this section to install additional OS packages.
# Install build tools from apt
RUN apt-get update
# git fot checking out
# wget for conda install
# cmake build-essential autoconf libtool pkg-config to build postman and dipcc
# libgoogle-glog-dev for dipcc

RUN apt-get install --yes git wget cmake build-essential autoconf libtool pkg-config libgoogle-glog-dev
