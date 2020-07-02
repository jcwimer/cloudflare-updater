FROM debian:10
RUN apt-get update \
  && apt-get install -y \
  curl \
  jq \
  dnsutils

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]