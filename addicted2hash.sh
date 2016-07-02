#!/bin/bash
# oclHashcat-plus Automated Hash Cracker Script v0.01
# by Hood3dRob1n
#
# Based on ideas referenced on Hashcat Wiki pages all kind of smashed together in one script for better
# handling of bulk hash files in a more automated fashion...
#
# Run script with no arguments to see help menu, or the -h or --help arguments
#

# Modified by Albert Veli 2016 to run with new hashcat
# instead of oclHashcat-plus and to work on OS X

##########################################=>CONFIGURATION<=############################################
# Cut Length For Cleaning cracked.out files => 34=MD5(0),40=IPB2/MyBB(2811),
ccc="34-" #MD5

#Path to the appropriate 32/64 oclHashcat-plus bin file
HASHCAT="/usr/local/bin/hashcat.app"

#Path to the Expander.bin tool
EXPANDER="$HOME/autocrack/hashcat-utils/src/expander.bin"

# hashcat workload profile.
#   | Performance | Runtime | Power Consumption | Desktop Impact
# ==+=============+=========+===================+=================
# 1 | Low         |   2 ms  | Low               | Minimal
# 2 | Default     |  12 ms  | Economic          | Noticeable
# 3 | High        |  96 ms  | High              | Unresponsive
# 4 | Nightmare   | 480 ms  | Insane            | Headless
WORKLOAD="-w 2"
##########################################=>CONFIGURATION<=############################################

#Let the magic start....
ARGS=6
HTMP1=$(mktemp -t fooooocrack1.tmp.XXX)
HTMP2=$(mktemp -t fooooocrack2.tmp.XXX)
MASKS="
?d?d?d?d
?d?d?d?d?d?d
?d?d?d?d?d?d?d
?d?d?d?d?d?d?d?d
?d?d?d?d?d?d?d?d?d
?d?d?d?d?d?d?d?d?d?d
?d?d?d?d?l?l?l?l
?d?d?d?l?l?l?l
?d?d?d?l?l?l?l?l
?d?d?d?l?l?l?l?l?l
?d?d?l?l?l?l
?d?d?l?l?l?l?l
?d?d?l?l?l?l?l?l
?d?d?l?l?l?l?l?l?l
?d?l?l?l?l
?d?l?l?l?l?l
?d?l?l?l?l?l?l
?d?l?l?l?l?l?l?l
?d?l?l?l?l?l?l?l?l
?l?l?l?l
?l?l?l?l?d
?l?l?l?l?d?d
?l?l?l?l?d?d?d
?l?l?l?l?d?d?d?d
?l?l?l?l?d?s
?l?l?l?l?l
?l?l?l?l?l?d
?l?l?l?l?l?d?d
?l?l?l?l?l?d?d?d
?l?l?l?l?l?l
?l?l?l?l?l?l?d
?l?l?l?l?l?l?d?d
?l?l?l?l?l?l?d?d?d
?l?l?l?l?l?l?l
?l?l?l?l?l?l?l?d
?l?l?l?l?l?l?l?d?d
?l?l?l?l?l?l?l?l
?l?l?l?l?l?l?l?l?l
?l?l?l?l?l?l?l?l?d
?l?l?l?l?l?l?l?l?s
?l?l?l?l?l?l?l?s
?l?l?l?l?l?l?s
?l?l?l?l?l?s
?l?l?l?l?s
?s?l?l?l?l
?s?l?l?l?l?l
?s?l?l?l?l?l?l
?s?l?l?l?l?l?l?l
?s?S?l?l?l?l
?u?d?d?d?d?d?d
?u?d?d?d?d?d?d?d?d
?u?l?d?d?d?d?d
?u?l?d?d?d?d?d?d
?u?l?d?d?d?d?d?d?d
?u?l?l?d?d?d?d
?u?l?l?d?d?d?d?d
?u?l?l?d?d?d?d?d?d
?u?l?l?l?l
?u?l?l?l?l?d
?u?l?l?l?l?d?d
?u?l?l?l?l?d?d?d
?u?l?l?l?l?d?d?d?d
?u?l?l?l?l?d?s
?u?l?l?l?l?l
?u?l?l?l?l?l?d
?u?l?l?l?l?l?d?d
?u?l?l?l?l?l?d?d?d
?u?l?l?l?l?l?d?d?d?d
?u?l?l?l?l?l?d?s
?u?l?l?l?l?l?l
?u?l?l?l?l?l?l?d
?u?l?l?l?l?l?l?d?d
?u?l?l?l?l?l?l?d?s
?u?l?l?l?l?l?l?s
?u?l?l?l?l?l?l?s?s
?u?l?l?l?l?l?s
?u?l?l?l?l?l?s?s
?u?l?l?l?l?s
?u?l?l?l?l?s?s";

#Add these to above array if you have capable system or enough time to spare as they greatly increase the overall time factor:
# ?u?l?l?l?l?l?l?d?d?d
# ?u?l?l?l?l?l?l?d?d?d?d
# ?s?l?l?l?l?l?l?l?l
# ?d?d?l?l?l?l?l?l?l?l
# ?l?l?l?l?l?l?l?l?d?d
# ?l?l?l?l?l?l?l?l?l?d
# ?l?l?l?l?l?l?l?l?l?l
# ?l?l?l?l?l?l?l?l?l?l?d
# ?l?l?l?l?l?l?l?l?l?l?l
# ?l?l?l?l?l?l?l?l?l?l?l?d
# ?l?l?l?l?l?l?l?l?l?l?l?l
# ?l?l?l?l?l?l?l?l?l?l?l?l?d
# ?l?l?l?l?l?l?l?l?l?l?l?l?s
# ?l?l?l?l?l?l?l?l?l?l?l?s
# ?l?l?l?l?l?l?l?l?l?l?s
# ?l?l?l?l?l?l?l?l?l?s

#First a simple Bashtrap function to handle interupt (CTRL+C)
trap bashtrap INT

function bashtrap(){
	echo
	echo
	echo 'CTRL+C has been detected!.....shutting down now' | grep --color '.....shutting down now'
	cat "$HTMP1" > cracked_`date +%Y%m%d%H`.crash.dump 2> /dev/null
	rm -f "$HTMP1" 2> /dev/null
	rm -f "$HTMP2" 2> /dev/null
	exit 666
}
#End bashtrap()


function banner(){
function ascii(){
cat <<"EOT"
._____      _________:_______   _____     _________   ______ ___________
|     |_ ___\______  |  ____/__|__   |___|_   ____/___\______\_________/
|     _  \     ___/  ______      /   _     |  \    \     ___/  |     |
|:    |   \    \     |    /    //    |     |        \    \     |    :|
|_____|____\_________|_________/_____|    :|_________\_________|_____|
	                             |_____|    addicted2hash
EOT
}
#print banner by calling ascii() function
ascii
echo '                                                              v0.1' | grep --color 'v0.1'

echo
}

function stage_right(){
	clear
	banner
	echo
	echo "Hash addiction has been cured!......for now"  | grep --color -E 'Hash addiction has been cured!||for now'
	echo
	CURRENT=$(wc -l "$HLIST" | sed 's/^[ ]*//' | cut -d' ' -f1)
	echo "Total Cracked hashes: $(($BASE - $CURRENT))" | grep --color 'Total Cracked Hashes'
	if [ -e cracked.clean ]; then
		mv cracked.clean cracked_`date +%Y%m%d%H`.clean.bk
	fi
	if [ -e cracked.out ]; then
		mv cracked.out cracked_`date +%Y%m%d%H`.out.bk
	fi
	cat wordz.cracked mask.cracked hydrid.cracked combo.cracked brute.cracked > cracked.clean 2> /dev/null
	cat wordz.out mask.out hydrid.out combo.out brute.out > cracked.out 2> /dev/null
	echo "You can check cracked.clean for the full list with cracked passes and cracked.out for the raw output in hash:cracked format." | grep --color -E 'You can check cracked||clean for the full list with cracked passes and cracked||out for the raw output in hash||cracked format'
	echo
	echo "Hope you cracked enough to cure the addiction :p" | grep --color 'Hope you cracked enough to cure the addiction'
	echo
	echo "Until next time, Enjoy!" | grep --color -E 'Until next time||Enjoy'
	echo
	exit 0
}

function usage_info(){
	banner
	echo
	echo "USAGE: $0 -H <HashFile> <OPTIONS>" | grep --color 'USAGE'
	echo
	echo "Options:" | grep --color 'Options'
	echo "-H <HashFile>"
	echo "-T <HashType> (default is 0 => MD5)"
	echo "-D </path/to/dict/dir/>"
	echo
	echo "EX: $0 -H /home/HR/hacked/MD5hashlist.lst -T 0 -D /home/hood3drob1n/fun/hashcat/dict/" | grep --color 'EX'
	echo "EX: $0 -H /home/HR/hacked/joomla_hashes.lst -T 11 -D /pentest/wordlists/" | grep --color 'EX'
	echo "EX: $0 -H /home/HR/hacked/shadow.lst -T 500 -D /home/hood3drob1n/passwords/unix/" | grep --color 'EX'
	echo
	echo "Available Hash Types:" | grep --color 'Available Hash Types'
	echo '	    0 = MD5 (Default if -T not provided)
	   11 = Joomla < 2.5.18
	   12 = PostgreSQL
	   21 = osCommerce, xt:Commerce
	   23 = Skype
	   21 = osCommerce, xt:Commerce
	  100 = SHA1
	  101 = nsldap, SHA-1(Base64), Netscape LDAP SHA
	  111 = nsldaps, SSHA-1(Base64), Netscape LDAP SSHA
	  112 = Oracle 11g
	  121 = SMF > v1.1
	  122 = OSX v10.4, v10.5, v10.6
	  124 = Django (SHA-1)
	  125 = ArubaOS
	  131 = MSSQL(2000)
	  132 = MSSQL(2005)
	  133 = PeopleSoft
	  141 = EPiServer 6.x < v4
	  200 = MySQL323
	  300 = MySQL > v4.1
	  400 = phpass, MD5(Wordpress), MD5(phpBB3), Joomla > 2.5.18
	  500 = md5crypt $1$, MD5(Unix), FreeBSD MD5, Cisco-IOS $1$
	  501 = Juniper IVE
	  900 = MD4
	 1000 = NTLM
	 1100 = Domain Cached Credentials, mscash
	 1400 = SHA256
	 1421 = hMailServer
	 1441 = EPiServer 6.x > v4
	 1500 = descrypt, DES(Unix), Traditional DES
	 1600 = md5apr1, MD5(APR), Apache $apr1$
	 1700 = SHA512
	 1722 = OSX v10.7
	 1731 = MSSQL(2012), MSSQL(2014)
	 1800 = sha512crypt $6$, SHA512(Unix)
	 2100 = Domain Cached Credentials2, mscash2
	 2400 = Cisco-PIX MD5
	 2410 = Cisco-ASA
	 2500 = WPA/WPA2
	 2611 = vBulletin < v3.8.5
	 2612 = PHPS
	 2711 = vBulletin > v3.8.5
	 2811 = IPB 2.0, MyBB1.2
	 3000 = LM
	 3100 = Oracle H: Type (Oracle 7+)
	 3200 = bcrypt $2*$, Blowfish(Unix)
	 3711 = Mediawiki B type
	 4300 = md5(strtoupper(md5($pass)))
	 4400 = md5(sha1($pass))
	 4500 = sha1(sha1($pass))
	 4700 = sha1(md5($pass))
	 4800 = iSCSI CHAP authentication, MD5(Chap)
	 5000 = SHA-3(Keccak)
	 5100 = Half MD5
	 5200 = Password Safe v3
	 5300 = IKE-PSK MD5
	 5400 = IKE-PSK SHA1
	 5500 = NetNTLMv1
	 5600 = NetNTLMv2
	 5700 = Cisco-IOS $4$
	 5800 = Android PIN
	 6000 = RipeMD160
	 6100 = Whirlpool
	 6300 = AIX {smd5}
	 6400 = AIX {ssha256}
	 6500 = AIX {ssha512}
	 6600 = 1Password, agilekeychain
	 6700 = AIX {ssha1}
	 6800 = Lastpass + Lastpass sniffed
	 6900 = GOST R 34.11-94
	 7100 = OSX v10.8, OSX v10.9, OSX v10.10
	 7200 = GRUB 2
	 7300 = IPMI2 RAKP HMAC-SHA1
	 7400 = sha256crypt $5$, SHA256(Unix)
	 7500 = Kerberos 5 AS-REQ Pre-Auth etype 23
	 7600 = Redmine
	 7700 = SAP CODVN B (BCODE)
	 7800 = SAP CODVN F/G (PASSCODE)
	 7900 = Drupal7
	 8000 = Sybase ASE
	 8100 = Citrix Netscaler
	 8200 = 1Password, cloudkeychain
	 8300 = DNSSEC (NSEC3)
	 8400 = WBB3 (Woltlab Burning Board)
	 8500 = RACF
	 8600 = Lotus Notes/Domino 5
	 8700 = Lotus Notes/Domino 6
	 8800 = Android FDE < v4.3
	 8900 = scrypt
	 9000 = Password Safe v2
	 9100 = Lotus Notes/Domino 8
	 9200 = Cisco-IOS $8$
	 9300 = Cisco-IOS $9$
	 9400 = MS Office 2007
	 9500 = MS Office 2010
	 9600 = MS Office 2013
	 9900 = Radmin2
	10000 = Django (PBKDF2-SHA256)
	10100 = SipHash
	10200 = Cram MD5
	10400 = PDF 1.1 - 1.3 (Acrobat 2 - 4)
	10500 = PDF 1.4 - 1.6 (Acrobat 5 - 8)
	10600 = PDF 1.7 Level 3 (Acrobat 9)
	10700 = PDF 1.7 Level 8 (Acrobat 10 - 11)
	10800 = SHA-384
	10900 = PBKDF2-HMAC-SHA256
	11000 = PrestaShop
	11100 = PostgreSQL CRAM (MD5)
	11200 = MySQL CRAM (SHA1)
	11300 = Bitcoin/Litecoin wallet.dat
	11400 = SIP digest authentication (MD5)
	11500 = CRC32
	11600 = 7-Zip
	11700 = GOST R 34.11-2012 (Streebog) 256-bit
	11800 = GOST R 34.11-2012 (Streebog) 512-bit
	11900 = PBKDF2-HMAC-MD5
	12000 = PBKDF2-HMAC-SHA1
	12100 = PBKDF2-HMAC-SHA512
	12200 = eCryptfs
	12300 = Oracle T: Type (Oracle 12+)
	12400 = BSDiCrypt, Extended DES
	12500 = RAR3-hp
	12600 = ColdFusion 10+
	12700 = Blockchain, My Wallet
	12800 = MS-AzureSync PBKDF2-HMAC-SHA256
	12900 = Android FDE (Samsung DEK)
	13000 = RAR5
	13100 = Kerberos 5 TGS-REP etype 23
	13200 = AxCrypt
	13300 = AxCrypt in memory SHA1
	13400 = Keepass 1 (AES/Twofish), Keepass 2 (AES)
	13500 = PeopleSoft Token
	13600 = WinZip
	13800 = Windows 8+ phone PIN/Password'
	echo
	exit
}

function wordz(){
	clear
	banner
	count=0
	x=$(ls -l "$DICTDIR" | awk 'NR!=1 && !/^d/ {print $NF}')
	y=(`echo ${x[0]}`)
	z=${#y[@]}
	while [ $count -lt $z ];
	do
		BASE1=$(wc -l "$HLIST" | sed 's/^[ ]*//' | cut -d' ' -f1)
		"$HASHCAT" $WORKLOAD --attack-mode 0 --hash-type $method "$HLIST" `echo "$DICTDIR"${y[$count]}` --remove --outfile "$HTMP1"
		CURRENT=$(wc -l "$HLIST" | sed 's/^[ ]*//' | cut -d' ' -f1)
		echo
		echo "Cracked This Round: $(($BASE1 - $CURRENT))" | grep --color 'Cracked This Round'
		echo "Total Cracked: $(($BASE - $CURRENT))" | grep --color 'Total Cracked'
		echo
		sleep 2
		wait
		count=$((count +1))
	done
	if [ -e wordz.out ]; then
		mv wordz.out wordz_`date +%Y%m%d%H`.out.bk
	fi
	if [ -e wordz.cracked ]; then
		mv wordz.cracked wordz_`date +%Y%m%d%H`.cracked.bk
	fi
	cat "$HTMP1" > wordz.out 2> /dev/null
	cat "$HTMP1" | cut -b "$ccc" > wordz.cracked 2> /dev/null
	echo > "$HTMP1"
}

function mask(){
	#Mask Attack
	echo
	echo "Starting Mask Attack to clear the way...." | grep --color 'Starting Mask Attack to clear the way'
	echo
	a=(`echo $MASKS`)
	b=${#a[@]}
	c=$(($b -1))
	i=0
	while [ $i -le $c ];
	do
		clear
		banner
		echo "Running Mask Attack using:" ${a[$i]} | grep --color 'Running Mask Attack using'
		BASE1=$(wc -l "$HLIST" | sed 's/^[ ]*//' | cut -d' ' -f1)
		$HASHCAT $WORKLOAD --attack-mode 3 --hash-type $method --remove --outfile $HTMP1 $HLIST ${a[$i]}
		CURRENT=$(wc -l "$HLIST" | sed 's/^[ ]*//' | cut -d' ' -f1)
		echo
		echo "Cracked This Round: $(($BASE1 - $CURRENT))" | grep --color 'Cracked This Round'
		echo "Total Cracked: $(($BASE - $CURRENT))" | grep --color 'Total Cracked'
		echo
		sleep 2
		wait
		i=$((i +1))
	done
	if [ -e mask.out ]; then
		mv mask.out mask_`date +%Y%m%d%H`.out.bk
	fi
	if [ -e mask.cracked ]; then
		mv mask.cracked mask_`date +%Y%m%d%H`.cracked.bk
	fi
	cat "$HTMP1" > mask.out 2> /dev/null
	cat "$HTMP1" | cut -b "$ccc" > mask.cracked 2> /dev/null
	echo > "$HTMP1"
	echo
	echo
	echo "Mask Attack complete!" | grep --color 'Mask Attack complete'
}

function hybrid_prepend_attack(){
	clear
	banner
	count=0
	x=$(ls -l "$DICTDIR" | awk 'NR!=1 && !/^d/ {print $NF}') #Grab list of wordlists from provided dir
	y=(`echo ${x[0]}`) #Set Array to value of wordlists found in provided dir
	z=${#y[@]} #Grab Array Count
	# Use Array count to drive loop for running hybrid attack per wordlist found => complicated enough :p
	while [ $count -lt $z ];
	do
		BASE1=$(wc -l "$HLIST" | sed 's/^[ ]*//' | cut -d' ' -f1)
		"$HASHCAT" $WORKLOAD --attack-mode 7 --hash-type $method "$CSET" "$HLIST" "$MASK" `echo "$DICTDIR"${y[$count]}` --remove --outfile "$HTMP1"
		CURRENT=$(wc -l "$HLIST" | sed 's/^[ ]*//' | cut -d' ' -f1)
		echo
		echo "Cracked This Round: $(($BASE1 - $CURRENT))" | grep --color 'Cracked This Round'
		echo "Total Cracked: $(($BASE - $CURRENT))" | grep --color 'Total Cracked'
		echo
		sleep 2
		wait
		count=$((count +1))
	done
}

function hybrid_append_attack(){
	clear
	banner
	count=0
	x=$(ls -l "$DICTDIR" | awk 'NR!=1 && !/^d/ {print $NF}') #Grab list of wordlists from provided dir
	y=(`echo ${x[0]}`) #Set Array to value of wordlists found in provided dir
	z=${#y[@]} #Grab Array Count
	# Use Array count to drive loop for running hybrid attack per wordlist found => complicated enough :p
	while [ $count -lt $z ];
	do
		BASE1=$(wc -l "$HLIST" | sed 's/^[ ]*//' | cut -d' ' -f1)
		"$HASHCAT" $WORKLOAD --attack-mode 6 --hash-type $method "$CSET" "$HLIST" `echo "$DICTDIR"${y[$count]}` "$MASK" --remove --outfile "$HTMP1"
		CURRENT=$(wc -l "$HLIST" | sed 's/^[ ]*//' | cut -d' ' -f1)
		echo
		echo "Cracked This Round: $(($BASE1 - $CURRENT))" | grep --color 'Cracked This Round'
		echo "Total Cracked: $(($BASE - $CURRENT))" | grep --color 'Total Cracked'
		echo
		sleep 2
		wait
		count=$((count +1))
	done
	#Don't forget to use the list of passwords we have already cracked with the mask attack in addition to those in the dict dir ;)
	BASE1=$(wc -l "$HLIST" | sed 's/^[ ]*//' | cut -d' ' -f1)
	"$HASHCAT" $WORKLOAD --attack-mode 6 --hash-type $method "$CSET" "$HLIST" `echo "$(PWD)/mask.cracked"` "$MASK" --remove --outfile "$HTMP1"
	CURRENT=$(wc -l "$HLIST" | sed 's/^[ ]*//' | cut -d' ' -f1)
	echo
	echo "Cracked This Round: $(($BASE1 - $CURRENT))" | grep --color 'Cracked This Round'
	echo "Total Cracked: $(($BASE - $CURRENT))" | grep --color 'Total Cracked'
	echo
	sleep 2
	wait
}

function hybrid(){
	clear
	banner
	echo "Running Hybrid Attacks now.........." | grep --color 'Running Hybrid Attacks now'
	# Start by Appending to wordlists in dictionary file => DICT+MASK
	CSET="-1 ?l?u?d?s"
	MASK="?1"
	hybrid_append_attack
	hybrid_prepend_attack
	MASK="?1?1"
	hybrid_append_attack
	hybrid_prepend_attack
	CSET="-1 ?d?s"
	MASK="?1?1?1"
	hybrid_append_attack
	hybrid_prepend_attack
#	CSET="-1 ?l?u?d?s"
#	MASK="?1?1?1"
#	hybrid_append_attack
#	hybrid_prepend_attack
#	MASK="?1?1?1?1"
#	hybrid_append_attack
#	hybrid_prepend_attack
#	MASK="?1?1?1?1?1"
#	hybrid_append_attack
#	hybrid_prepend_attack
	if [ -e hybrid.out ]; then
		mv hybrid.out hybrid_`date +%Y%m%d%H`.out.bk
	fi
	if [ -e hybrid.cracked ]; then
		mv hybrid.cracked hybrid_`date +%Y%m%d%H`.cracked.bk
	fi
	cat "$HTMP1" > hybrid.out 2> /dev/null
	cat "$HTMP1" | cut -b "$ccc" > hybrid.cracked 2> /dev/null
	echo > "$HTMP1"
	echo
	echo
	echo "Hybrid Attacks Complete!" | grep --color 'Hybrid Attacks Complete'
}

function combo_attack(){
	clear
	banner
	echo
	BASE1=$(wc -l "$HLIST" | sed 's/^[ ]*//' | cut -d' ' -f1)
	"$HASHCAT" $WORKLOAD --attack-mode 1 --hash-type $method --remove --outfile pattern.cracked "$HLIST" pattern.lst pattern.lst
	CURRENT=$(wc -l "$HLIST" | sed 's/^[ ]*//' | cut -d' ' -f1)
	cat pattern.cracked >> combo.out
	cat pattern.cracked | cut -b "$ccc" > pattern.clean 2> /dev/null
	echo
	echo "Cracked This Round: $(($BASE1 - $CURRENT))" | grep --color 'Cracked This Round'
	echo "Total Cracked: $(($BASE - $CURRENT))" | grep --color 'Total Cracked'
	echo
	sleep 2
	wait
}

function combo(){
	clear
	banner
	echo
	echo "Prepping pattern list, one sec..." | grep --color -E 'Prepping pattern list||one sec'
	#Prep what we have found so far and use it break shit down....over & over again!
	if [ -e pattern.lst ]; then
		mv pattern.lst pattern_`date +%Y%m%d%H`.lst.bk
	fi
	if [ -e combo.out ]; then
		mv combo.out combo_`date +%Y%m%d%H`.out.bk
	fi
	cat hybrid.cracked | "$EXPANDER" | sort -u > pattern.lst 2> /dev/null
	echo
	echo "Starting Combo Attack, this will take a while......." | grep --color -E 'Starting Combo Attack||this will take a while'
	combo_attack
	echo "Prepping for second pass.........." | grep --color 'Prepping for second pass'
	cat pattern.clean | "$EXPANDER" | sort -u >> pattern.lst 2> /dev/null
	rm -f pattern.cracked 2> /dev/null
	rm -f pattern.clean 2> /dev/null
	echo
	echo "Starting Combo Attack, Round 2......." | grep --color -E 'Starting Combo Attack||Round 2'
	combo_attack
	echo "Prepping for one more pass.........." | grep --color 'Prepping for one more pass'
	cat pattern.clean | "$EXPANDER" | sort -u >> pattern.lst 2> /dev/null
	rm -f pattern.cracked 2> /dev/null
	rm -f pattern.clean 2> /dev/null
	echo "Starting Combo Attack, Round 3......." | grep --color -E 'Starting Combo Attack||Round 2'
	combo_attack
	if [ -e combo.cracked ]; then
		mv combo.cracked combo_`date +%Y%m%d%H`.out.bk
	fi
	cat pattern.lst pattern.clean > combo.cracked 2> /dev/null
		rm -f pattern.lst 2> /dev/null
		rm -f pattern.cracked 2> /dev/null
		rm -f pattern.clean 2> /dev/null
	echo
	echo
	echo "Combo Attacks Completed!" | grep --color 'Hybrid Attacks Completed'
}

function theForce(){
	clear
	banner
	echo "Running Bruteforce Attack using: $MASK" | grep --color 'Running Bruteforce Attack using'
	BASE1=$(wc -l "$HLIST" | sed 's/^[ ]*//' | cut -d' ' -f1)
	"$HASHCAT" $WORKLOAD --attack-mode 3 --hash-type $method "$CSET" "$HLIST" "$MASK" --remove --outfile "$HTMP1"
	CURRENT=$(wc -l "$HLIST" | sed 's/^[ ]*//' | cut -d' ' -f1)
	echo
	echo "Cracked This Round: $(($BASE1 - $CURRENT))" | grep --color 'Cracked This Round'
	echo "Total Cracked: $(($BASE - $CURRENT))" | grep --color 'Total Cracked'
	echo
	sleep 2
	wait
}

function bruteforce(){
	clear
	banner
	echo > "$HTMP1"
	# One last pass to pick off any straglers we may have some how missed along the way :p
	# ?D, ?F and ?R not supported in new hashcat, use ?b instead which test all ascii 1-255
	CSET="-1 ?b"
	MASK="?1?1?1?1" #All 4
	theForce
	CSET="-1 ?b"
	MASK="?1?1?1?1?1" #All 5
	theForce
	CSET="-1 ?l?u?d?s"
	MASK="?1?1?1?1?1?1" #All 6
	theForce
	CSET="-1 ?l?u?d?s"
	MASK="?1?1?1?1?1?1?1" #All 7
	theForce
	CSET="-1 ?l?u?d?s"
	MASK="?1?1?1?1?1?1?1?1" #All 8
	theForce
	CSET="-1 ?l?u?d?s"
	MASK="?1?1?1?1?1?1?1?1?1" #All 9
	theForce

	if [ -e brute.cracked ]; then
		mv brute.cracked brute_`date +%Y%m%d%H`.cracked.bk
	fi
	if [ -e brute.out ]; then
		mv brute.out brute_`date +%Y%m%d%H`.out.bk
	fi
	cat "$HTMP1" > brute.out
	cat brute.out | cut -b "$ccc" > brute.cracked 2> /dev/null
}

function core(){
	banner
	echo
	echo "Starting with the provided word lists....." | grep --color 'Starting with the provided word lists'
	echo
	wordz
	echo
	echo "Moving to Hybrid Attack Phase....." | grep --color 'Moving to Hybrid Attack Phase'
	echo
	hybrid
	echo
	echo "Moving to Mask Attacks....." | grep --color 'Moving to Mask Attacks'
	echo
	mask
	echo
	echo "Moving to Combo Attack Phase....." | grep --color 'Moving to Combo Attack Phase'
	echo
	combo
	echo
	echo "Moving to Final Bruteforce Attack Phase....." | grep --color 'Moving to Final Bruteforce Attack Phase'
	echo
	bruteforce
	stage_right
}

# Main----------------------------------------------->
clear
# supply usage if not called properly
if [ -z "$1" ] || [ "$1" == "-h" ] ||  [ "$1" == "--help" ] || [ $# -ne $ARGS ]; then
	usage_info
fi
method=0
while [ $# -ne 0 ];
do
	case $1 in
		-H) shift; HLIST="$1"; if [ ! -r "$HLIST" ]; then echo "WTF? Cant read provided lists! Check permissions or path and try again....."; echo; usage_info; fi; shift;; #Hash File
		-T) shift; method="$1"; shift ;; #Hash Type
		-D) shift; DICTDIR="$1"; if [ ! -d "$DICTDIR" ]; then echo "WTF? Cant find provided dict dir! Check permissions or path and try again....."; echo; usage_info; fi; shift;; #Path to Dictionary Directory full of wordlists
		*) echo "Unknown Parameters provided!" | grep --color 'Unknown Parameters provided'; usage_info;; #WTF?
	esac;
done
BASE=$(wc -l "$HLIST" | sed 's/^[ ]*//' | cut -d' ' -f1)
core
rm -f "$HTMP1" 2> /dev/null
rm -f "$HTMP2" 2> /dev/null
# Greetz & Shouts to my friends on Team INTRA!
#EOF
