FROM node:dubnium

RUN apt-get update \
    && apt-get install -y \
      build-essential \
      python

RUN yarn config set cache-folder /var/cache/yarn

WORKDIR /app/sage

COPY docker/bin/sage-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["yarn", "start"]
