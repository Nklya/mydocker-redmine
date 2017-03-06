FROM nginx:stable-alpine
MAINTAINER Nklya <nklya@hotmail.com>

LABEL   Name="proxy nginx"\
        Version="latest"

COPY redmine.conf /etc/nginx/conf.d/default.conf
