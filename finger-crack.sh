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
HTMP1=$(mktemp -t fooooocrack1.tmp.XXX)
HTMP2=$(mktemp -t fooooocrack2.tmp.XXX)

#First a simple Bashtrap function to handle interupt (CTRL+C)
trap bashtrap INT

function bashtrap(){
	echo
	echo
	echo 'CTRL+C has been detected!.....shutting down now' | grep --color '.....shutting down now'
	rm -f "$HTMP1" 2> /dev/null
	rm -f "$HTMP2" 2> /dev/null
	exit 666
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

function expander(){
	cat auto.dict | "$EXPANDER" | sort -u >> auto-pattern.lst
}

function looper(){
	clear
	banner
	echo
	echo "Base pattern completed, commencing true attack - will run till you stop it........." | grep --color 'Base pattern completed, commencing true attack - will run till you stop'
	echo "Just hit 'CTRL+C' to safely stop it......."
	echo
	count=0
	if ! [ -e auto-pattern.cracked ]; then
		touch auto-pattern.cracked
	fi
	while [ $count -lt 100 ];
	do
		echo "Cracking Round: $(($count +1))" | grep --color 'Cracking Round' #Start of loop
		BASE1=$(wc -l "$HLIST" | sed 's/^[ ]*//' | cut -d' ' -f1)
		"$HASHCAT" $WORKLOAD --attack-mode 1 --hash-type $method --remove --outfile auto-pattern.cracked "$HLIST" auto-pattern.lst auto-pattern.lst
		CURRENT=$(wc -l "$HLIST" | sed 's/^[ ]*//' | cut -d' ' -f1)
		cat auto-pattern.cracked >> auto.out
		cat auto-pattern.cracked | cut -b "$ccc" >> auto.dict 2> /dev/null
		rm -f auto-pattern.cracked 2> /dev/null
		expander
		echo
		echo "Cracked This Round: $(($BASE1 - $CURRENT))" | grep --color 'Cracked This Round'
		echo "Total Cracked: $(($BASE - $CURRENT))" | grep --color 'Total Cracked'
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
	"$HASHCAT" $WORKLOAD --attack-mode 3 --hash-type $method --custom-charset1 ?l?u?d?s --remove --outfile "$HTMP1" "$BHLIST" ?1?
	"$HASHCAT" $WORKLOAD --attack-mode 3 --hash-type $method --custom-charset1 ?l?u?d?s --remove --outfile "$HTMP1" "$BHLIST" ?1?1
	"$HASHCAT" $WORKLOAD --attack-mode 3 --hash-type $method --custom-charset1 ?l?u?d?s --remove --outfile "$HTMP1" "$BHLIST" ?1?1?1
	"$HASHCAT" $WORKLOAD --attack-mode 3 --hash-type $method --custom-charset1 ?l?u?d?s --remove --outfile "$HTMP1" "$BHLIST" ?1?1?1?1
	"$HASHCAT" $WORKLOAD --attack-mode 3 --hash-type $method --custom-charset1 ?l?u?d?s --remove --outfile "$HTMP1" "$BHLIST" ?1?1?1?1?1
	"$HASHCAT" $WORKLOAD --attack-mode 3 --hash-type $method --custom-charset1 ?l?u?d?s --remove --outfile "$HTMP1" "$BHLIST" ?1?1?1?1?1?1
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
	echo "Skipping mask attack since you provided your own base file, just some quick prep work........." | grep --color 'Skipping mask attack since you provided your own base file, just some quick prep work'
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
BASE=$(wc -l "$HLIST" | sed 's/^[ ]*//' | cut -d ' ' -f1)
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
