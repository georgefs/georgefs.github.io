#!/bin/bash
#
# docker.sh
# Copyright (C) 2015 george
#
# Distributed under terms of the MIT license.
#
## get docker hosting ip
if [ $DOCKER_HOST ];
then
    ip=`echo $DOCKER_HOST|sed 's/tcp:\/\///'|sed 's/:.*//'`
else
    ip="127.0.0.1"
fi

## get free port
for port in $(seq 8000 65000); do echo -ne "\035" | telnet $ip $port > /dev/null 2>&1; [ $? -eq 1 ]  && break; done;echo $port


source_dir=`grep source_dir _config.yml|sed 's/.*:[ \t]*//'`
ipython_dir=`grep ipython_dir _config.yml|sed 's/.*:[ \t]*//'`
public_dir=`grep public_dir _config.yml|sed 's/.*:[ \t]*//'`
container=blog
work_dir="/tmp/work"

case $1 in
    "edit" )
        echo "run editor server at http://$ip:$port"
        docker run -i -t -d --name=$container -v `pwd`:$work_dir -w $work_dir -p $port:8888 ipython/notebook bin/editserver.sh $ipython_dir
        sleep 1
        open http://$ip:$port
        docker attach $container
        docker rm -f $container
        ;;
    "build" )
        echo "start build"
        docker run -i --rm -t -v `pwd`:$work_dir -w $work_dir/$source_dir/_posts -p $port:8888 ipython/notebook ipython nbconvert --to markdown $work_dir/$ipython_dir/*
        docker run -i --rm -t -v `pwd`:$work_dir -w $work_dir bourvill/hexo-docker hexo generate
        
        ;;
    "install" )
        docker run -i -t --rm -v `pwd`:$work_dir -w $work_dir bourvill/hexo-docker npm install
        ;;
    "runserver" )
        echo "run server at http://$ip:$port"
        docker run -i -d -t --name=$container -v `pwd`:$work_dir -w $work_dir/$public_dir -p $port:8000 ipython/notebook python -m SimpleHTTPServer
        sleep 1
        open http://$ip:$port
        docker attach $container
        docker rm -f $container
        ;;
    "deploy" )
        docker run -i --rm -t -v `pwd`:$work_dir -w $work_dir bourvill/hexo-docker hexo deploy
        ;;
esac



