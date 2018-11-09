#### xtrabackup_shell_script.sh
xtrabackup循环备份脚本，支持全量备份和增量备份。可设置循环备份天数，全量备份自动删除旧的备份。

##### 目录结构
/data
   |_ backup
        |_ full #全量备份文件保存目录 *.tar.gz
        |   |_ logs #全量备份日志文件 *.log
        |_ incr #增量备份文件保存目录
        |    |_ logs #增量备份日志 *.log
        |_ error.log #错误日志

##### 全量备份
./xtrabackup_shell_script.sh -f

##### 增量备份
./xtrabackup_shell_script.sh -i
