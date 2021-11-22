ARG NODE_IMAGE_TAG=14-bullseye-slim
ARG DOCKER_REGISTRY_PREFIX=frappe
ARG IMAGE_TAG=version-13

FROM node:${NODE_IMAGE_TAG} as builder

ARG GIT_REPO=https://github.com/frappe/erpnext
ARG GIT_BRANCH=version-13

ARG FRAPPE_BRANCH=${GIT_BRANCH}

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    python2 \
    git \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY install_app.sh /install_app
RUN chmod +x /install_app \
    && /install_app erpnext ${GIT_REPO} ${GIT_BRANCH} ${FRAPPE_BRANCH}


FROM ${DOCKER_REGISTRY_PREFIX}/frappe-nginx:${IMAGE_TAG}

COPY --from=builder /home/frappe/frappe-bench/sites/ /var/www/html/
COPY --from=builder /rsync /rsync
COPY nginx-default.conf.template /etc/nginx/conf.d/default.conf.template

RUN echo "erpnext" >> /var/www/html/apps.txt
RUN echo "chat" >> /var/www/html/apps.txt
RUN echo "twilio_integration" >> /var/www/html/apps.txt

VOLUME [ "/assets" ]

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
