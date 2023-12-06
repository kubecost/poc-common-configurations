# Kubebox
Kubebox is a ubuntu image built with the intention to be run as basic container running on a kubernetes cluster where Kubecost is installed.

The image is built with pre-installed CLIs, libraries and script to be used to help Kubecost users diagnose, troubleshoot and extract information from the Kubecost stack and Cloud Providers.

## What's Included?
### Scripts
The bash image has a /scripts directory where all scripts can be found and run

### Cloud CLIs
The bash image has the AWS, Azure and GCP (gcloud) CLIs included

## Build the image locally and deploy

Pre-requisites:
1. Docker installed locally.
2. A Docker Hub account.  https://hub.docker.com
3. A new repo in your Docker Hub account. https://docs.docker.com/docker-hub/repos/create/ 

Build Instructions:
1. Open a terminal, navigate to the top level of the 'poc-common-configurations' repo
2. Build the image. Example command: ```docker build -t kubebox -f kubebox/Dockerfile .```
3. Push the new image to your repo in Docker Hub. ```docker push <hub-user>/<repo-name>:<tag>```

Deploy the Image:
1. Create a basic manifest.  Included is kubebox.yaml which can be used to deploy kubebox as a single pod on a cluster.
2. Edit kubebox.yaml and change the image repo local to your docker hub image repo
3. Run command to deploy. ```kubectl apply -f kubebox.yaml```

Access the Container:
1. Run command to exec into container to use various scripts, CLIs and tools. ```kubectl exec -it kubebox -- /bin/bash```