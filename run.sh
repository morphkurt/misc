#!/bin/bash
for i in `ls *sky*`
do 
for j in `ls *sky*` 
do 
rate1=`echo $i |awk -F"_" '{print $NF}' | sed 's/.mp4//g'`
rate2=`echo $j |awk -F"_" '{print $NF}' | sed 's/.mp4//g'`
title=`echo $j |awk -F"_" '{print $1"_"$2}' | sed 's/.mp4//g'`
if [ "$i" != "$j" ]; then
	echo ./start_flow.sh $i $j $rate1 $rate2 $title 250 
fi
done 
done
