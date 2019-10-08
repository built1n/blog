#!/bin/bash

ssh-add
ssh root@fwei.tk rm -rf /var/www/html/blog
ssh root@fwei.tk mkdir -p /var/www/html/blog
scp out/* root@fwei.tk:/var/www/html/blog
