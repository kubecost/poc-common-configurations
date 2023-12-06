# Pull base image.
# Use this for ARM (M1/M2) based Macs
FROM --platform=linux/amd64 ubuntu:latest

# Use this for x86
#FROM ubuntu:latest

# apt Package Install.
RUN \
  apt-get update \
  && apt-get install -y curl sudo zip unzip python3 python3-pip apt-transport-https ca-certificates gnupg

# gcloud CLI install.
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

RUN apt-get update && apt-get install -y google-cloud-sdk

# AWS CLI install.
RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
  && unzip awscliv2.zip \
  && ./aws/install \
  && rm -rf aws awscliv2.zip

# Azure CLI install.
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# boto3 install.
RUN python3 -m pip install boto3

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Make scripts directory.
RUN mkdir -p /scripts/aws/

# Add files.
COPY scripts/aws /root/scripts/aws

# Define default command.
CMD ["bash"]