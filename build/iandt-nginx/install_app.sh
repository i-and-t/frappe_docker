#!/bin/bash

set -e

APP_NAME=${1}
APP_REPO=${2}
APP_BRANCH=${3}
FRAPPE_BRANCH=${4}

[ "${APP_BRANCH}" ] && BRANCH="-b ${APP_BRANCH}"

mkdir -p /home/frappe/frappe-bench
cd /home/frappe/frappe-bench

mkdir -p apps "sites/assets/${APP_NAME}"
mkdir -p apps "sites/assets/chat"
mkdir -p apps "sites/assets/twilio_integration"

echo -ne "frappe\n${APP_NAME}\nchat\ntwilio_integration" >sites/apps.txt

git clone --depth 1 -b "${FRAPPE_BRANCH}" https://github.com/frappe/frappe apps/frappe
# shellcheck disable=SC2086
git clone --depth 1 ${BRANCH} ${APP_REPO} apps/${APP_NAME}
git clone --depth 1 -b main https://github.com/frappe/chat apps/chat
git clone --depth 1 -b master https://github.com/i-and-t/twilio_integration apps/twilio_integration

echo "Install frappe NodeJS dependencies . . ."
cd apps/frappe
yarn --pure-lockfile

echo "Install ${APP_NAME} NodeJS dependencies . . ."
yarn --pure-lockfile --cwd "../${APP_NAME}"

echo "Build ${APP_NAME} assets . . ."
yarn production --app "${APP_NAME}"

echo "Install chat NodeJS dependencies . . ."
yarn --pure-lockfile --cwd "../chat"

echo "Build chat assets . . ."
yarn production --app "chat"

echo "Install twilio_integration NodeJS dependencies . . ."
yarn --pure-lockfile --cwd "../twilio_integration"

echo "Build twilio_integration assets . . ."
yarn production --app "twilio_integration"

cd /home/frappe/frappe-bench
# shellcheck disable=SC2086
cp -R apps/${APP_NAME}/${APP_NAME}/public/* sites/assets/${APP_NAME}
cp -R apps/chat/chat/public/* sites/assets/chat
cp -R apps/twilio_integration/twilio_integration/public/* sites/assets/twilio_integration

# Add frappe and all the apps available under in frappe-bench here
echo "rsync -a --delete /var/www/html/assets/frappe /assets" >/rsync
echo "rsync -a --delete /var/www/html/assets/${APP_NAME} /assets" >>/rsync
echo "rsync -a --delete /var/www/html/assets/chat /assets" >>/rsync
echo "rsync -a --delete /var/www/html/assets/twilio_integration /assets" >>/rsync

chmod +x /rsync

rm sites/apps.txt
