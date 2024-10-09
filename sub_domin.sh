	#!/bin/bash

	if [ -z "$1" ]; then
	  echo "Usage: $0 <URL>"
	  exit 1
	fi
	show_loading() {
	  duration=$1
	  end=$((SECONDS + duration))
	  while [ $SECONDS -lt $end ]; do
	    for s in '/' '-' '\' '|'; do
	      echo -ne "\rLoading $s"
	      sleep 0.2
	    done
	  done
	  echo -ne "\r"  # محو السطر بعد انتهاء التحميل
	}
	echo "Download Start"
	html_file=$(curl -s $1)
	echo "Finish Download"

	show_loading 4

	echo "Extract Domain"
	site=$(echo $1 | cut -d "." -f 2)  
	echo "Finish Extract Domain: $site"

	show_loading 5

	echo "Extract Sub Domains"
	subdomains=$(echo "$html_file" | grep "href" | cut -d "/" -f 3 | grep "$site" | cut -d '"' -f 1 | uniq)

	if [ -z "$subdomains" ]; then
	  echo "No subdomains found."
	  exit 1
	fi

	for subdomain in $subdomains; do
		if [[ $(ping -c 1 $subdomain && 2>/dev/null) ]]; then
			echo "$subdomain<++++++++++>Good"
			ip=$(host $subdomain|cut -d " " -f 4)
			echo "$subdomain,$ip" >> subdomains.txt
		else
			echo "$subdomain is Error"
		fi
	done

	echo "Subdomains saved to subdomains.txt"

