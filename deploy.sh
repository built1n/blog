#!/bin/bash

if [ $(ssh-add -l | grep SHA | wc -l) -lt 1 ]
then
    ssh-add
else
    echo "Key already added"
fi

echo "Copying to staging..."
tar -czf blog.tar.gz blog-staging
scp blog.tar.gz root@fwei.tk:
ssh root@fwei.tk rm -rf /var/www/html/blog-staging
ssh root@fwei.tk tar -xzvf blog.tar.gz -C /var/www/html
rm -f blog.tar.gz

if [[ $# -ge 1 ]] && [[ $1 == "-p" ]]
then
    echo "Going gold..."
    ssh root@fwei.tk rm -rf /var/www/html/blog
    ssh root@fwei.tk mv /var/www/html/blog-staging /var/www/html/blog
    echo "Moved to production."
else
    echo "Files copied to staging site."
fi
