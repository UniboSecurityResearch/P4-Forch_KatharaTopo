#!/bin/sh

if [ "$1" != "" ]
then
	filename=$1
else 
	echo "usage: ./test_edge.sh [filename.txt]"
	exit
fi

timestamps=$(cat $filename | awk -F ' ' '{print $1}' | egrep -Eo "[0-9]+\.[0-9]+" | awk -F '.' '{print $2}')
#echo $timestamps

c=0
tin=0
tout=0

echo '' > delay_$filename

for t in $timestamps
do
	if [ $(( c % 2 )) -eq 0 ]
	then
		tin=$t
	fi
	if [ $(( c % 2 )) -eq 1 ]
	then
		tout=$t
		delay=$( expr $tout - $tin)
		if [ $delay -gt 0 ]
		then
			echo "$delay" >> delay_$filename
	
		fi
	fi
	c=$(( c + 1 ))
	printf "\r   Remaining $((200000-${c})) samples. "
done

awk '{for(i=1;i<=NF;i++) {sum[i] += $i; sumsq[i] += ($i)^2}}
          END {for (i=1;i<=NF;i++) {
	  printf "%f %f \n", sum[i]/NR, sqrt((sumsq[i]-sum[i]^2/(NR-1))/(NR-1))}
         }' delay_$filename >> aver-std_$filename
