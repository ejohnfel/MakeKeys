#/bin/bash

# Make SSH RSA Key (Replaces Current One)
# MakeSSHKey [username] [home folder] [bitsize]
function MakeSSHKey()
{
	if [ "$3" = "" ]; then
		KEYSIZE=4096
	else
		KEYSIZE=$3
	fi

	if [ ! -d $2/.ssh ]; then
		sudo -u $1 mkdir $2/.ssh
		sudo -u $1 chmod u+rwx,go-rwx $2/.ssh
	fi

	[ -f $2/.ssh/id_rsa ] && rm $2/.ssh/id_rsa* > /dev/null

	echo -e "Making $1's RSA Key..."
	if [ "${PHRASE}" = "None" -o "${PHRASE}" = "" ]; then
		MATCHES=False
		while [ "${MATCHES}" = "False" ]; do
			read -s -p "Pass Phrase : " PHRASE
			echo -e "\t"
			read -s -p "Again : "
			echo -e "\t"

			if [ "${REPLY}" = "${PHRASE}" ]; then
				MATCHES=True
			else
				echo -e "Didn't match, retype"
			fi
		done
	fi

	echo -e "\t"
	# In the event the hostname was changed in this script, don't use the ${HOSTNAME} variable,
	# use `hostname` instead because it will pull the name from /etc/hostname, which should
	# reflect any recent changes.
	currentHostname=$(hostname)
	COMMENT="$1 on ${currentHostname}"
	sudo -u $1 ssh-keygen -b ${KEYSIZE} -t rsa -N "${PHRASE}" -C "${COMMENT}" -f $2/.ssh/id_rsa
}

#
# Code Seperator
#

# Usage
function Usage()
{
	echo -e "MakeKeys : Make RSA SSH Key For User"
	echo -e "-u [user]\tUser to generate key for"
	echo -e "-h [home]\tHome folder for user"
	echo -e "-s [bitsize]\tBit size of key (consider 2048 to be minimum)"
}

#
# Main Loop
#

KEYSIZE=4096
USERNAME=${LOGNAME}
HOMEDIR=${HOME}

while [ ! "$1" = "" ]; do
	case "$1" in
	"-h")	Usage
		exit 0 ;;
	"-u")
		USERNAME="$2"
		shift 1 ;;
	"-h")	HOMEDIR="$2"
		shift 1 ;;
	"-s")	KEYSIZE="$2"
		shift 1 ;;
	esac

	shift 1
done

MakeSSHKey ${USERNAME} ${HOMEDIR} ${KEYSIZE}
