#!/bin/bash

page=0
nextpage=$1
outputpath=$2

if [ ! -d $outputpath ]; then
	mkdir -p $outputpath
fi

while [ 1 ]; do
	echo "Current page is $nextpage"	
	curl -s "$nextpage" | grep -o "http://cloudfront.\+/pictures.\+.jpg" >.imgs
	nextpage=http://dailybooth.com$(curl -s "$nextpage" | grep Older | grep -o "href=\"[^\"]\+\"" | sed -e "s/href=\"//" | sed -e "s/\"//g")
	for url in `cat .imgs`; do
		echo Grabbing $url
		filename=$(echo $url | grep -o "[^/]\+\.jpg$")
		newurl=`echo $url | sed -e 's/medium/original/'`
		curl -s -o $outputpath$filename $newurl &
	done
	# Wait for the running curl processes to finish so we don't saturate our bandwidth
	while [ 1 ]; do
		dbs=`ps aux | grep "curl -s" | grep -v "grep" | wc -l | awk '{print $1}'`
		if [ "$dbs" -lt "10" ]; then
			break
		fi
		sleep 1		
	done
	if [[ -z $nextpage || $nextpage = 'http://dailybooth.com' ]]; then
		exit
	fi
done

rm .imgs