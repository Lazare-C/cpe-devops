FROM node:12.16.3-stretch-slim AS build

WORKDIR /opt/front

COPY src/ src/
COPY public/ public/
COPY package.json .
COPY yarn.lock .
COPY default.conf .
COPY .env.production .

RUN npm install
RUN npm run build

FROM nginx:1.15.7-alpine

ENV VUE_APP_API_URL=/api
EXPOSE 80


COPY --from=build /opt/front/dist /usr/share/nginx/html/
COPY --from=build /opt/front/default.conf /etc/nginx/conf.d/default.conf