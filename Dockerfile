#FROM balenalib/armv7hf-debian:buster
FROM balenalib/raspberry-pi-debian:buster

#dynamic build arguments coming from the /hooks/build file
ARG BUILD_DATE
ARG VCS_REF

#metadata labels
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/schreinerman/rpi-uvcvideo-webcam-docker" \
      org.label-schema.vcs-ref=$VCS_REF

#version
ENV IOEXPERT_UVCVIDEO_WEBCAM_VERSION 1.0.0

#labeling
LABEL maintainer="info@io-expert.com" \
      version=$IOEXPERT_NODERED_UVCVIDEO_WEBCAM_VERSION \
      description="Webserver"

RUN apt-get update && \
    apt-get install -y \
    curl

RUN curl http://www.linux-projects.org/listing/uv4l_repo/lrkey.asc | apt-key add -
RUN echo "deb http://www.linux-projects.org/listing/uv4l_repo/raspbian/ buster main" > /etc/apt/sources.list.d/uv4l-buster.list

RUN apt-get update && \
    apt-get install -y \
    uv4l \
    uv4l-uvc \
    uv4l-server \
    uv4l-renderer \
    uv4l-decoder \
    uv4l-encoder \
    uv4l-mjpegstream \
    fuse

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/uv4l/ssl/ssl.key -out /etc/u4ul/ssl/ssl.crt

RUN apt-get remove -y \
    curl && \
    rm -rf /var/lib/apt/lists/*

ENV LD_PRELOAD /usr/lib/uv4l/uv4lext/armv6l/libuv4lext.so

WORKDIR /

EXPOSE 8080

ENV UV4L_PARAMETERS --help

ENTRYPOINT /usr/bin/uv4l $UV4L_PARAMETERS
