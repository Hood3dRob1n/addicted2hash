#!/bin/bash
# Dictionary 2 Hash List Conversion Tool 
# GNU Parallel Edition
# by Hood3dRob1n
#
# Requires Openssl + GNU Parallel to work, otherwise it just takes too damn long!
#
# Reads provided file and creates a new file with each entry being the converted hash value of the original entry in the provided file a.k.a dict=>2=>hash :)

# A few good wordlists worth converting to build your pot files and wordlists: 
# http://www.skullsecurity.org/wiki/index.php/Passwords
# http://g0tmi1k.blogspot.com/2011/06/dictionaries-wordlists.html
# http://www.google.com
#
# USAGE: dict2hash.sh -L </path/to/dictionary.lst> -C <HASH#>
#
# EX: ./dict2hash.sh --help
# EX: ./dict2hash.sh -L dictionary.lst -C 1
#

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

function usage_info(){
	echo
	echo "H.R.'s Dictionary 2 Hash Conversion Tool" | grep --color -E "H.R.'s Dictionary 2 Hash Conversion Tool"
	echo
	echo "USAGE: $0 -L </path/to/dictionary.lst> -C <HASH#>" | grep --color 'USAGE'
	echo 
	echo "EX: $0 -L ~/fun/hashcat/dic/rockyou.txt -C 1" | grep --color 'EX'
	echo
	echo "HASH #'s:" | grep --color "HASH #'s"
	echo " 0 => MD4" | grep --color "=>"
	echo " 1 => MD5" | grep --color "=>"
	echo " 2 => UNIX(MD5)" | grep --color "=>"
	echo " 3 => Apache(MD5)" | grep --color "=>"
	echo " 4 => Apache(MD5+Salt)" | grep --color "=>"
	echo " 5 => UNIX crypt()" | grep --color "=>"
	echo " 6 => SHA1" | grep --color "=>"
	echo " 7 => SHA256" | grep --color "=>"
	echo " 8 => SHA512" | grep --color "=>"
	echo " 9 => NTLM" | grep --color "=>"
	echo
	exit;
}

function convert2md4(){
	NEW="$ORIG.md4"
	echo "Converting provided wordlist to MD4 hash list, hang tight this might take a few...." | grep --color -E 'Converting provided wordlist to MD4 hash list||hang tight this might take a few'
	cat "$ORIG" | parallel -k -j 499 "echo -n {} | openssl md4 -md4 | cut -d' ' -f2  >> $NEW"
}

function convert2md5(){
	NEW="$ORIG.md5"
	echo "Converting provided wordlist to MD5 hash list, hang tight this might take a few...." | grep --color -E 'Converting provided wordlist to MD5 hash list||hang tight this might take a few'
	cat "$ORIG" | parallel -k -j 499 "echo -n {} | openssl md5 -md5 | cut -d' ' -f2  >> $NEW"
}

function convert2unixmd5(){
	NEW="$ORIG.nixmd5"
	echo "Converting provided wordlist to UNIX(MD5) hash list, hang tight this might take a few...." | grep --color -E 'Converting provided wordlist to UNIX(MD5) hash list||hang tight this might take a few'
	cat "$ORIG" | parallel -k -j 499 "echo -n {} | openssl passwd -1 -stdin  >> $NEW"
}

function convert2md5apache_nosalt(){
	NEW="$ORIG.apache_md5"
	echo "Converting provided wordlist to Apache MD5 (w/o Salt) hash list, hang tight this might take a few...." | grep --color -E 'Converting provided wordlist to Apache MD5||w||o Salt||hash list||hang tight this might take a few'
	cat "$ORIG" | parallel -k -j 499 "echo -n {} | openssl passwd -apr1 -stdin >> $NEW"
}

function convert2md5apache_salty(){
	NEW="$ORIG.apache_md5_salty"
	echo "Converting provided wordlist to Apache Salted MD5 hash list, hang tight this might take a few...." | grep --color -E 'Converting provided wordlist to Apache Salted MD5||Salt||hash list||hang tight this might take a few'
	cat "$ORIG" | parallel -k -j 499 "echo -n {} | openssl passwd -apr1 -stdin -salt 00000000 >> $NEW"
}

function convert2unix(){
	NEW="$ORIG.nix"
	echo "Converting provided wordlist to UNIX hash list, hang tight this might take a few...." | grep --color -E 'Converting provided wordlist to UNIX hash list||hang tight this might take a few'
	cat "$ORIG" | parallel -k -j 499 "echo -n {} | openssl passwd -stdin  >> $NEW"
}

function convert2sha1(){
	NEW="$ORIG.sha1"
	echo "Converting provided wordlist to SHA1 hash list, hang tight this might take a few...." | grep --color -E 'Converting provided wordlist to SHA1 hash list||hang tight this might take a few'
	cat "$ORIG" | parallel -k -j 499 "echo -n {} | openssl sha1 -sha1 | cut -d' ' -f2  >> $NEW"
}

function convert2sha256(){
	NEW="$ORIG.sha256"
	echo "Converting provided wordlist to SHA256 hash list, hang tight this might take a few...." | grep --color -E 'Converting provided wordlist to SHA256 hash list||hang tight this might take a few'
	cat "$ORIG" | parallel -k -j 499 "echo -n {} | openssl sha1 -sha256 | cut -d' ' -f2  >> $NEW"
}

function convert2sha512(){
	NEW="$ORIG.sha512"
	echo "Converting provided wordlist to SHA512 hash list, hang tight this might take a few...." | grep --color -E 'Converting provided wordlist to SHA512 hash list||hang tight this might take a few'
	cat "$ORIG" | parallel -k -j 499 "echo -n {} | openssl sha1 -sha512 | cut -d' ' -f2  >> $NEW"
}

function convert2NTLM(){
	NEW="$ORIG.ntlm"
	echo "Converting provided wordlist to NTLM hash list, hang tight this might take a few...." | grep --color -E 'Converting provided wordlist to NTLM hash list||hang tight this might take a few'
	cat "$ORIG" | parallel -k -j 499 "printf '%s' {} | iconv -t utf16le | openssl md4 | cut -d' ' -f2 >> $NEW"
}

# Main----------------------------------------------->
clear
# supply usage if not called properly
if [ -z "$1" ] || [ "$1" == "-h" ] ||  [ "$1" == "--help" ]; then
	usage_info
fi
while [ $# -ne 0 ];
do
	case $1 in
		-L) shift; ORIG="$1"; shift;; #Original Dictionary File
		-C) shift; convert="$1"; shift;; #Convert to Hash Type 0=MD5 1=SHA1
		*) echo "Unknown Parameters provided!" | grep --color 'Unknown Parameters provided'; usage_info;; #WTF?
	esac;
done
echo
if [ ! -r "$ORIG" ]; then
	echo
	echo
	echo "Can't read provided file! Please check path or permissions and try again...." | grep --color -E 'Can||t read provided file||Please check path or permissions and try again'
	echo
	exit;
fi
if [ "$convert" == 0 ]; then
	convert2md4
elif [ "$convert" == 1 ]; then
	convert2md5
elif [ "$convert" == 2 ]; then
	convert2unixmd5
elif [ "$convert" == 3 ]; then
	convert2md5apache_nosalt
elif [ "$convert" == 4 ]; then
	convert2md5apache_salty
elif [ "$convert" == 5 ]; then
	convert2unix
elif [ "$convert" == 6 ]; then
	convert2sha1
elif [ "$convert" == 7 ]; then
	convert2sha256
elif [ "$convert" == 8 ]; then
	convert2sha512
elif [ "$convert" == 9 ]; then
	convert2NTLM
else
	echo "WTF?"
	usage_info;
fi
#EOF


