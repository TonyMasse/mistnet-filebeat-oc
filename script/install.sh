#!/usr/bin/env bash

for i in {16..21} {21..16} ; do echo -en "\e[38;5;${i}m######\e[0m" ; done ; echo
echo -e "\e[94m# Mistnet - Syslog - FileBeat - OpenCollector"
echo -e "\e[94m# install.sh"
echo -e "\e[94m# -----------"
echo -e "\e[94m# (c) 2021 LogRhythm"
echo -e "\e[94m# Tony Massé - tony.masse@logrhythm.com\e[39m"
for i in {16..21} {21..16} ; do echo -en "\e[38;5;${i}m------\e[0m" ; done ; echo
for i in {22,28,34,40} ; do echo -en "\e[38;5;${i}m#\e[0m" ; done
echo -e "\e[92m# Check presense of \e[1mlrctl\e[25m and \e[1mOpen Collector\e[25m, check Status and import Pipeline\e[39m"

echo -e "\e[92m #--> Checking \e[1mlrctl\e[25m presence...\e[39m"
# First establish if "lrctl" is present and running
lrctl_present=1
./lrctl --help >/dev/null 2>/dev/null || lrctl_present=-1

if [ $lrctl_present -ge 1 ]; then
echo -e "\e[92m #--> \e[1mlrctl\e[25m is present\e[39m"
else
echo -e "\e[38;5;160m #--> \e[1mlrctl\e[25m is NOT present!\e[39m"
echo -e "\e[92m #--> Please install it first, and make sure you are running this from the same folder as where \e[1mlrctl\e[25m is.\e[39m"
echo -e "\e[92m #--> Exiting now.\e[39m"
for i in {16..21} {21..16} ; do echo -en "\e[38;5;${i}m------\e[0m" ; done ; echo
for i in {52,88,124,160} ; do echo -en "\e[38;5;${i}m#\e[0m" ; done
echo -e "\e[38;5;160m### Install script ### Failed\e[39m"
echo " "
exit 1
fi

echo -e "\e[92m #--> Checking \e[1mOpen Collector\e[25m presence...\e[39m"
if [ $lrctl_present -eq 1 ]; then
# "lrctl"is present. Now check if the OC is installed too.
oc_present=$(./lrctl status | grep -c -i open_collector 2>/dev/null) || oc_present=-1
else
# No "lrctl", we stop here and claim OC is not present.
oc_present=0
fi

if [ $oc_present -ge 1 ]; then
echo -e "\e[92m #--> \e[1mOpen Collector\e[25m is present\e[39m"
else
echo -e "\e[38;5;160m #--> \e[1mOpen Collector\e[25m is NOT present!\e[39m"
echo -e "\e[92m #--> Please install, configure and get running it first.\e[39m"
echo -e "\e[92m #--> Exiting now.\e[39m"
for i in {16..21} {21..16} ; do echo -en "\e[38;5;${i}m------\e[0m" ; done ; echo
for i in {52,88,124,160} ; do echo -en "\e[38;5;${i}m#\e[0m" ; done
echo -e "\e[38;5;160m### Install script ### Failed\e[39m"
echo " "
exit 1
fi

echo -e "\e[92m #--> Downloading Pipeline\e[39m"
curl -L -O https://raw.githubusercontent.com/TonyMasse/mistnet-filebeat-oc/main/config/mistnet-via-FileBeat-Syslog.pipe

echo -e "\e[92m #--> Importing Pipeline\e[39m"
cat mistnet-via-FileBeat-Syslog.pipe | ./lrctl oc pipe import

echo -e "\e[92m #--> List Pipelines\e[39m"
./lrctl oc -- pipe status

for i in {22,28,34,40} ; do echo -en "\e[38;5;${i}m#\e[0m" ; done
echo -e "\e[92m# Install, configure and start \e[1mFile Beat\e[25m\e[39m"

echo -e "\e[92m #--> Downloading \e[1mFile Beat\e[25m...\e[39m"
cd /tmp
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.12.0-x86_64.rpm -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.12.0-x86_64.rpm.sha512

echo -e "\e[92m #--> Checking \e[1mFile Beat\e[25m checksum...\e[39m"
checksum_ok=$(sha512sum -c filebeat-7.12.0-x86_64.rpm.sha512 | grep -c -i ": OK" 2>/dev/null) || checksum_ok=-1

if [ $checksum_ok -ge 1 ]; then
echo -e "\e[92m #--> Checksum for \e[1mFile Beat\e[25m is valid\e[39m"
else
echo -e "\e[38;5;160m #--> Checksum for \e[1mFile Beat\e[25m is NOT valid!\e[39m"
echo -e "\e[92m #--> Exiting now.\e[39m"
for i in {16..21} {21..16} ; do echo -en "\e[38;5;${i}m------\e[0m" ; done ; echo
for i in {52,88,124,160} ; do echo -en "\e[38;5;${i}m#\e[0m" ; done
echo -e "\e[38;5;160m### Install script ### Failed\e[39m"
echo " "
exit 1
fi

echo -e "\e[92m #--> Installing \e[1mFile Beat\e[25m...\e[39m"
sudo -E rpm -vi filebeat-7.12.0-x86_64.rpm
echo -e "\e[92m #--> Cleaning up install files...\e[39m"
rm /tmp/filebeat-7.12.0-x86_64.rpm /tmp/filebeat-7.12.0-x86_64.rpm.sha512
cd

echo -e "\e[92m #--> Backing up \e[1mFile Beat\e[25m configuration files...\e[39m"
sudo -E cp --force /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.bck

echo -e "\e[92m #--> Downloading \e[1mFile Beat\e[25m custom configuration file...\e[39m"
sudo -E curl -sL https://raw.githubusercontent.com/TonyMasse/mistnet-filebeat-oc/main/config/filebeat-syslog.yml -o /etc/filebeat/filebeat.yml

echo -e "\e[92m #--> Starting \e[1mFile Beat\e[25m service...\e[39m"
sudo -E service filebeat start

for i in {16..21} {21..16} ; do echo -en "\e[38;5;${i}m------\e[0m" ; done ; echo
for i in {22,28,34,40} ; do echo -en "\e[38;5;${i}m#\e[0m" ; done
echo -e "\e[92m### Install script ### Done\e[39m"
