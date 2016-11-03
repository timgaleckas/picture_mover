FROM ruby:2.1-onbuild
RUN apt-get update && apt-get install -y exiftool
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
