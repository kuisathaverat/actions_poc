# Container image that runs your code
FROM curlimages/curl:7.84.0

USER root
# add a package to the alpine image
RUN apk add --no-cache jq

USER curl_user
# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]