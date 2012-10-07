#!/bin/bash
# Crack Monitor :)
# By H.R.
#
# Run it just prior to starting the addicted2hash auto-cracker script to keep an eye on things...and so it gets proper base count :p
#
# I like to run things with the terminator terminal so i can run this in one window and the cracker in the other for easy viewing and status updates. It's more for me, but threw it in case anyone else finds it useful....
#
# USAGE: ./crack-monitor.sh /path/to/source/hash.lst <Interval2Check-inSeconds>
# EX: ./crack-monitor.sh /home/hood3drob1n/fun/hashcat/demo/32.hash 30
#
# Press CTRL+C to stop when you want
#
ARGS=2
HLIST="$1"
CHKTIME="$2"
if [ ! -z "$1" ]; then
	BASE=$(wc -l "$HLIST" | cut -d' ' -f1)
fi
trap bashtrap INT

function bashtrap(){
	echo
	echo
	echo 'CTRL+C has been detected!.....shutting down now' | grep --color '.....shutting down now'
	exit 666;
}

function monitor(){
	echo
	echo "Switching on crack-monitor for: $HLIST" | grep --color -E 'Switching on crack||monitor for'
	echo "Polling every $CHKTIME seconds..." | grep --color "Polling every $CHKTIME seconds"
	while :
	do
		sleep "$CHKTIME"
		wait
		CURRENT=$(wc -l "$HLIST" | cut -d' ' -f1); 
		echo "Cracked Count: $(($BASE-$CURRENT))" | grep --color 'Cracked Count';
		if [ "$count" -gt 18 ]; then
			clear
			count=0
			echo
			echo "Crack-monitor running watching: $HLIST" | grep --color -E 'Crack||monitor running watching'
			echo "Polling every $CHKTIME seconds..." | grep --color "Polling every $CHKTIME seconds"
		fi
		count=$((count +1))
	done
	exit;
}


function usage_info(){
	clear
	echo
	echo "USAGE: $0 /path/to/monitor/hash.lst <Interval2Check-inSeconds>" | grep --color 'USAGE'
	echo "EX: $0 /home/hood3drob1n/fun/hashcat/demo/32.hash 60" | grep --color 'EX'
	echo
	echo "Press CTRL+C to stop when you want...." | grep --color 'Press CTRL+C to stop when you want'
	echo
	exit
}

# Main----------------------------------------------->
# supply usage if not called properly
if [ -z "$1" ] || [ "$1" == "-h" ] ||  [ "$1" == "--help" ] || [ $# -ne "$ARGS" ] ; then
	usage_info
fi
if [ ! -r "$HLIST" ]; then
	echo "WTF? Cant read the provided file! Check the permissions or path and try again....."
	echo
	usage_info
fi
count=0
monitor
#EOF
