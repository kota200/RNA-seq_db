#crontab -e
#00 08 30 * * cd ~/PM_DB; ./scp_send.sh
#Change BACKUP_DIR when needed.
#!/bin/sh

HOST=webpark2116.sakura.ne.jp
USER=webpark2116
PASS=tsugame8sakura

TARGET_FILE=/home/ws/PM_DB/PM_TPM_matrix.tsv
BACKUP_DIR=/home/webpark2116/www/rlgpr/data

/usr/bin/expect -c "
set timeout 30
spawn /usr/bin/scp -r ${TARGET_FILE} ${USER}@${HOST}:${BACKUP_DIR}
expect {
\"password: \" {
send \"${PASS}\r\"
}
}
expect {
eof { exit 0}
}
"

