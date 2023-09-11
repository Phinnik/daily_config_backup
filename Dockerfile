FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y \
        git \
        cron \
        zenity && \
    service cron start

COPY ./test_data /root/

COPY config_backup.sh /root/config_backup.sh
RUN chmod +x /root/config_backup.sh

WORKDIR /root

ARG GITHUB_USERNAME
ARG GITHUB_EMAIL
RUN git config --global user.email "$GITHUB_EMAIL" && \
    git config --global user.name "$GITHUB_USERNAME"


CMD ["/root/config_backup.sh"]