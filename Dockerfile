# !!! Don't try to build this Dockerfile directly, run it through bin/build-docker.sh script !!!
FROM node:16.19.1-alpine

# Create app directory
WORKDIR /usr/src/app

# Bundle app source
COPY . .

COPY server-package.json package.json

RUN set -eux && sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

# Install app dependencies
RUN set -x \
    && apk add --no-cache --virtual .build-dependencies \
    autoconf \
    automake \
    g++ \
    gcc \
    libtool \
    make \
    nasm \
    libpng-dev \
    python3 


#ENV HTTP_PROXY=http://172.17.0.1:10809
#ENV HTTPS_PROXY=http://172.17.0.1:10809
# ENV HTTP_PROXY=http://172.0.0.1:10809
# ENV HTTPS_PROXY=http://172.0.0.1:10809


RUN set -x \
    && npm config set proxy http://127.0.0.1:10809\
    && npm config set https-proxy http://127.0.0.1:10809\
    && npm install --verbose\
    && apk del .build-dependencies \
    && npm run webpack --verbose\
    && npm prune --omit=dev \
    && cp src/public/app/share.js src/public/app-dist/. \
    && cp -r src/public/app/doc_notes src/public/app-dist/. \
    && rm -rf src/public/app

# Some setup tools need to be kept
RUN apk add --no-cache su-exec shadow

# Add application user and setup proper volume permissions
RUN adduser -s /bin/false node; exit 0

# Start the application
EXPOSE 8080
CMD [ "./start-docker.sh" ]

HEALTHCHECK --start-period=10s CMD exec su-exec node node docker_healthcheck.js
