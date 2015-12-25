FROM nginx:1.9

MAINTAINER Gabor Szathmari "gszathmari@gmail.com"

ENV APPLICATION_NAME sritest-frontend

COPY configs/nginx.conf /etc/nginx/conf.d/default.conf
COPY dist /usr/share/nginx/html

EXPOSE 80
