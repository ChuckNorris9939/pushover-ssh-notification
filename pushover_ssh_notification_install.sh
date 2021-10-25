#!/bin/bash

apt install curl gawk screen -y
cd /opt/
touch pushover-ssh.sh
chmod +x pushover-ssh.sh

read -p "Wie ist der PUSHOVER USER KEY:" PUSHOVER_USER
read -p "Wie ist der PUSHOVER API KEY:" PUSHOVER_API_TOKEN
read -p "Wie ist der PUSHOVER APP Name:" PUSHOVER_NAME

echo Gesetzter Pushover USER KEY: $PUSHOVER_USER
echo Gesetzter Pushover API KEY: $PUSHOVER_API_TOKEN
echo Gesetzter Pushover APP Name: $PUSHOVER_NAME

touch pushover-ssh.sh

FILE="/opt/pushover-ssh.sh"
/bin/cat <<EOM >$FILE
#!/bin/sh

if [ -z $PUSHOVER_USER ]
 then echo "Der Pushover User muss im Script angegeben werden. Einen Wert f  r PUSHOVER_USER setzen."
 return 1
fi
if [ -z $PUSHOVER_API_TOKEN ]
 then echo "Der Pushover Token muss im Script angegeben werden. Einen Wert f  r PUSHOVER_API_TOKEN setzen."
 return 1
fi
echo "SSH Zugriff wird nun ueberwacht"

tail -F /var/log/auth.log | gawk '{if(NR>10 && \$0 ~ /sshd/ && \$0 ~ /Accepted/)\
{ cmd=sprintf("curl -s \
-F \"token='$PUSHOVER_API_TOKEN'\" \
-F \"user='$PUSHOVER_USER'\" \
-F \"message=SSH Zugriff erfolgt durch %s von %s\" \
-F \"title=$PUSHOVER_NAME\" https://api.pushover.net/1/messages.json",\$9,\$11); \
system(cmd)}}'
EOM
echo "script wurde int /opt erstellt"

#write out current crontab
crontab -l > pushover
#echo new cron into cron file
echo "@reboot screen -dmS pushover-ssh sudo ./opt/pushover-ssh.sh" >> pushover
#install new cron file
crontab pushover
rm pushover
echo "crontab wurde erstellt. startet bei jeden reboot"

screen -dmS pushover-ssh sudo ./pushover-ssh.sh
echo "screen wurde gestartet unter namen pushover-ssh"
