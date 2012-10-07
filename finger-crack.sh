#!/bin/bash
#
# oclHashcat-plus automated Fingerprint Attack Script (finger-crack.sh)
# Version: 0.01
# By: Hood3dRob1n
#
# Based on idea referenced on Hashcat Wiki page...
# Here is my make shift bash version based on my understanding of the great write up they have
# Run script with no arguments to see help menu (or -h or --help)
#

##########################START-CONFIGURATION#####################################################
#Path to oclHashcat-plus32/64.bin
OCLPLUS="/home/hood3drob1n/fun/hashcat/hashcat-gui-0.5.1/oclHashcat-plus/cudaHashcat-plus32.bin" 

#Path to expander.bin tool from hashcat utils package
EXPANDER="/home/hood3drob1n/fun/hashcat/dic/wordTools/hashcat-utils-0.9/expander.bin" 

#tmp folder
JUNK=/tmp 

# Cut Length for trimming crcaked passes off cracked log file, some examples: 34=MD5(0),40=IPB2/MyBB(2811),
ccc="34-" #MD5 default
############################END-CONFIGURATION#####################################################

#Let the magic start....
HTMP1=$(mktemp -p "$JUNK" -t fooooocrack1.tmp.XXX)
HTMP2=$(mktemp -p "$JUNK" -t fooooocrack2.tmp.XXX)

#First a simple Bashtrap function to handle interupt (CTRL+C)
trap bashtrap INT

function bashtrap(){
	echo
	echo
	echo 'CTRL+C has been detected!.....shutting down now' | grep --color '.....shutting down now'
	rm -f "$HTMP1" 2> /dev/null
	rm -f "$HTMP2" 2> /dev/null
	exit 666;
}
#End bashtrap()


function banner(){
cat <<"EOT"
._____      _________:_______   _____     _________   ______ ___________
|     |_ ___\______  |  ____/__|__   |___|_   ____/___\______\_________/
|     _  \     ___/  ______      /   _     |  \    \     ___/  |     |
|:    |   \    \     |    /    //    |     |        \    \     |    :|
|_____|____\_________|_________/_____|    :|_________\_________|_____|
                                     |_____|      finger-cracker!
EOT
#print message below pic
echo '                                                              v0.01' | grep --color 'v0.01'
#end banner()
}


function usage_info(){
	banner
	echo "USAGE: $0 -H <HashFile> <OPTIONS>" | grep --color 'USAGE'
	echo
	echo "Options:" | grep --color 'Options'
	echo "-H <HashFile>"
	echo "-T <HashType>"
	echo "-B <BypassBaseMaskAttack-UseThisPatternListInstead4Base>"
	echo "-W <PreppedHashList4BaseMaskAttack>"
	echo
	echo "EX: $0 -H /home/HR/hacked/MD5hashlist.lst" | grep --color 'EX'
	echo "EX: $0 -H /home/HR/hacked/joomla_hashes.lst -T 11" | grep --color 'EX'
	echo "EX: $0 -H /home/HR/hacked/MyHashes.lst -T 300" | grep --color 'EX'
	echo "EX: $0 -H /home/HR/hacked/shadow.lst -T 500" | grep --color 'EX'
	echo "EX: $0 -H /home/HR/hacked/MD5hashlist.lst -T 0 -B /home/hood3drob1n/passwords/rockyou-pattern.lst" | grep --color 'EX'
	echo "EX: $0 -H /home/HR/hacked/MD5hashlist.lst -T 0 -W /home/hood3drob1n/passwords/cracked.dict.md5" | grep --color 'EX'
	echo "EX: $0 -H /home/HR/hacked/MD5hashlist.lst -T 100 -W /home/hood3drob1n/passwords/rockyou.txt.sha1" | grep --color 'EX'
	echo
	echo "Available Hash Types:" | grep --color 'Available Hash Types'
	echo "	    0 = MD5 (Default if -T not provided)
	   11 = Joomla
	   21 = osCommerce, xt:Commerce
	  100 = SHA1
	  101 = nsldap, SHA-1(Base64), Netscape LDAP SHA
	  111 = nsldaps, SSHA-1(Base64), Netscape LDAP SSHA
	  112 = Oracle 11g
	  121 = SMF > v1.1
	  122 = OSX v10.4, v10.5, v10.6
	  131 = MSSQL(2000)
	  132 = MSSQL(2005)
	  300 = MySQL > v4.1
	  400 = phpass, MD5(Wordpress), MD5(phpBB3)
	  500 = md5crypt, MD5(Unix), FreeBSD MD5, Cisco-IOS MD5
	  900 = MD4
	 1000 = NTLM
	 1100 = Domain Cached Credentials, mscash
	 1400 = SHA256
	 1500 = descrypt, DES(Unix), Traditional DES
	 1600 = md5apr1, MD5(APR), Apache MD5
	 2100 = Domain Cached Credentials2, mscash2
	 2400 = Cisco-PIX MD5
	 2500 = WPA/WPA2
	 2611 = vBulletin < v3.8.5
	 2711 = vBulletin > v3.8.5
	 2811 = IPB 2.0, MyBB1.2"
	echo
	exit;
}

function expander(){
	cat auto.dict | "$EXPANDER" | sort -u >> auto-pattern.lst
}

function looper(){
	clear
	banner
	echo 
	echo "Base pattern completed, commencing true attack - will run till you stop it........." | grep --color -E 'Base pattern completed||commencing true attack||will run till you stop'
	echo "Just hit 'CTRL+C' to safely stop it......."
	echo
	count=0
	while [ $count -lt 100 ]; 
	do
		echo "Cracking Round: $(($count +1))" | grep --color 'Cracking Round' #Start of loop
		BASE1=$(wc -l "$HLIST" | cut -d' ' -f1);
		"$OCLPLUS" -n 80 --attack-mode 1 --hash-type $method --remove --outfile auto-pattern.cracked "$HLIST" auto-pattern.lst auto-pattern.lst
		CURRENT=$(wc -l "$HLIST" | cut -d' ' -f1);
		cat auto-pattern.cracked >> auto.out	
		cat auto-pattern.cracked | cut -b "$ccc" >> auto.dict 2> /dev/null
		rm -f auto-pattern.cracked 2> /dev/null
		expander
		echo
		echo "Cracked This Round: $(($BASE1-$CURRENT))" | grep --color 'Cracked This Round'
		echo "Total Cracked: $(($BASE-$CURRENT))" | grep --color 'Total Cracked';
		echo "On to the next round...." | grep --color 'On to the next round'
		echo
		sleep 2
		wait
		count=$((count +1)) 
	done
}

function base_mask(){
	banner
	echo
	echo "Making first passes to build base pattern list, hang tight........." | grep --color -E 'Making first passes to build base pattern list||hang tight'
	echo
	"$OCLPLUS" -n 80 --attack-mode 3 --hash-type $method --custom-charset1 ?l?u?d?s --remove --outfile "$HTMP1" "$BHLIST" ?1?
	"$OCLPLUS" -n 80 --attack-mode 3 --hash-type $method --custom-charset1 ?l?u?d?s --remove --outfile "$HTMP1" "$BHLIST" ?1?1
	"$OCLPLUS" -n 80 --attack-mode 3 --hash-type $method --custom-charset1 ?l?u?d?s --remove --outfile "$HTMP1" "$BHLIST" ?1?1?1
	"$OCLPLUS" -n 80 --attack-mode 3 --hash-type $method --custom-charset1 ?l?u?d?s --remove --outfile "$HTMP1" "$BHLIST" ?1?1?1?1
	"$OCLPLUS" -n 80 --attack-mode 3 --hash-type $method --custom-charset1 ?l?u?d?s --remove --outfile "$HTMP1" "$BHLIST" ?1?1?1?1?1
	"$OCLPLUS" -n 80 --attack-mode 3 --hash-type $method --custom-charset1 ?l?u?d?s --remove --outfile "$HTMP1" "$BHLIST" ?1?1?1?1?1?1
	cat "$HTMP1" | cut -b "$ccc" >> "$HTMP2" 2> /dev/null
	if [ -e auto-pattern.lst ]; then
		mv auto-pattern.lst auto-pattern_`date +%Y%m%d%H`.lst.bk
	fi
	cat "$HTMP2" | "$EXPANDER" | sort -u > auto-pattern.lst
	echo "" >  "$HTMP1" 2> /dev/null & echo "" >  "$HTMP2" 2> /dev/null
	looper
}


function skip_mask(){
	banner
	echo
	if [ -e auto-pattern.lst ]; then
		mv auto-pattern.lst auto-pattern_`date +%Y%m%d%H`.lst.bk
	fi
	echo "Skipping mask attack since you provided your own base file, just some quick prep work........." | grep --color -E 'Skipping mask attack since you provided your own base file||just some quick prep work'
	echo
	cat "$base_list" | "$EXPANDER" | sort -u > auto-pattern.lst
	echo "" >  "$HTMP1" 2> /dev/null & echo "" >  "$HTMP2" 2> /dev/null
	looper
}


# Main----------------------------------------------->
clear
# supply usage if not called properly
if [ -z "$1" ] || [ "$1" == "-h" ] ||  [ "$1" == "--help" ]; then
	usage_info
fi
method=0
option=1
while [ $# -ne 0 ];
do
	case $1 in
		-H) shift; HLIST="$1"; if [ ! -r "$HLIST" ]; then echo "WTF? Cant read provided lists! Check permissions or path and try again....."; echo; usage_info; fi; shift;; #Hash File
		-W) shift; option=1; BHLIST="$1"; if [ ! -r "$BHLIST" ]; then echo "WTF? Cant read provided lists! Check permissions or path and try again....."; echo; usage_info; fi; shift;; #Prepped Hash List for Mask Attack => use dict2hash.sh to convert dict to prepped hash
		-B) shift; option=2; base_list="$1"; shift;; #Mask Supplement
		-T) shift; method="$1"; shift ;; #Hash Type
		*) echo "Unknown Parameters provided!" | grep --color 'Unknown Parameters provided'; usage_info;; #WTF?
	esac;
done
BASE=$(wc -l "$HLIST" | cut -d' ' -f1)
if [ -e pattern.lst ]; then
	cp pattern.lst pattern_`date +%Y%m%d%H`.lst.bk
fi
if [ $option == 2 ]; then
	skip_mask
else
	base_mask
fi

rm -f "$HTMP1" 2> /dev/null
rm -f "$HTMP2" 2> /dev/null
#EOF
