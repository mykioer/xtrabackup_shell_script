#!/bin/sh
 
# MySQL配置文件
CONF='/etc/my.cnf'
 
# 备份用户名密码
USER=''
PAWD=''
 
Time=`date +%Y%m%d_%H%M%S`
 
# 备份路径
BASEDIR='/data/backup'

# 备份保留天数
BACKUP_SAVE_DAYS='180'


#创建备份目录
[[ -d $BASEDIR ]] || mkdir $BASEDIR
[[ -d "$BASEDIR/full" ]] || mkdir "$BASEDIR/full"
[[ -d "$BASEDIR/incr" ]] || mkdir "$BASEDIR/incr"
[[ -d "$BASEDIR/full/logs" ]] || mkdir "$BASEDIR/full/logs"
[[ -d "$BASEDIR/incr/logs" ]] || mkdir "$BASEDIR/incr/logs"


#开始备份
StartTime=`date +%Y%m%d_%H%M%S`

#全量备份
if [ "$1" = '-f' ];then
	FULLLOGFILE="$BASEDIR/full/logs/${Time}.log"
	touch ${FULLLOGFILE}
	echo "Start-Time ：${StartTime}" |tee -a ${FULLLOGFILE}
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" |tee -a ${FULLLOGFILE}
	innobackupex --defaults-file=${CONF} --user=${USER} --password=${PAWD} --stream=tar ${BASEDIR}/full 2>> ${FULLLOGFILE}|gzip >${BASEDIR}/full/${Time}.tar.gz
	StopTime=`date +%Y%m%d_%H%M%S`
	echo "Stop-Time ：${StopTime}" |tee -a ${FULLLOGFILE}
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" |tee -a ${FULLLOGFILE}
	# 清除N天之前的备份
	cd ${BASEDIR}/full
	/usr/bin/find -name "*.tar.gz" -mtime +${BACKUP_SAVE_DAYS} -exec rm {} \;
	/usr/bin/find -name "*info.log" -mtime +${BACKUP_SAVE_DAYS} -exec rm {} \;
#增量备份
elif [ "$1" = '-i' ];then
	INCRLOGFILE="$BASEDIR/incr/logs/${Time}.log"
	#LASTBAKNAME="$BASEDIR/incr/last_backup_filename.temp"
	
	touch ${INCRLOGFILE}
	echo "Start-Time ：${StartTime}" |tee -a ${INCRLOGFILE}
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" |tee -a ${INCRLOGFILE}
	
	#查找最近的增量备份目录
	LATEST_INCR=`find $BASEDIR/incr -mindepth 1 -maxdepth 1 -type d ! -name logs | sort -nr | head -1`
	if [ ! $LATEST_INCR ];then
		#进行全备
		echo "未发现增量备份文件，进行全备" |tee -a ${INCRLOGFILE}
		innobackupex --defaults-file=${CONF} --user=${USER} --password=${PAWD} ${BASEDIR}/incr 2>> ${INCRLOGFILE}
	else
		#进行增备
		innobackupex --defaults-file=${CONF} --user=${USER} --password=${PAWD} --incremental ${BASEDIR}/incr --incremental-basedir $LATEST_INCR 2>> ${INCRLOGFILE}
		if [ -z "`tail -1 $INCRLOGFILE | grep 'completed OK!'`" ];then
			echo "ERROR!incremental backup failed!" |tee -a ${INCRLOGFILE}
			exit 1
		fi
		THISBACKUP=`awk -- "/Backup created in directory/ { split( \\\$0, p, \"'\" ) ; print p[2] }" $INCRLOGFILE`
		echo "incremental backup success to $THISBACKUP" |tee -a ${INCRLOGFILE}
	fi

	StopTime=`date +%Y%m%d_%H%M%S`
	echo "Stop-Time ：${StopTime}" |tee -a ${INCRLOGFILE}
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" |tee -a ${INCRLOGFILE}
else
	echo "error"
fi
exit 0;
