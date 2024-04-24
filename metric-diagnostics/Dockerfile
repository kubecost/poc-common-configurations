FROM ubuntu:latest
RUN apt-get update \
  && apt-get install -y --no-install-recommends software-properties-common \
  && apt-get update \
  && apt-get install -y --no-install-recommends --fix-missing \
  curl wget apt-transport-https vim less jq

WORKDIR /scripts
COPY kubecost-prometheus-healthcheck.sh  /scripts/kubecost-prometheus-healthcheck.sh
RUN chmod +x /scripts/kubecost-prometheus-healthcheck.sh

CMD ["/scripts/kubecost-prometheus-healthcheck.sh"]