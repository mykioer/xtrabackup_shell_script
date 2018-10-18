#### xtrabackup_shell_script.sh
xtrabackup循环备份脚本，支持全量备份和增量备份。可设置循环备份天数，全量备份自动删除旧的备份。

##### 全量备份
./xtrabackup_shell_script.sh -f

##### 增量备份
./xtrabackup_shell_script.sh -i
