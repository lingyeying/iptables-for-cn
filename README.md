# iptables-for-cn
利用iptables 和 ipset 限制服务器访问国外IP

# yum 国内源 (CentOS 7)
## Base
```
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget https://mirrors.163.com/.help/CentOS7-Base-163.repo -O /etc/yum.repos.d/CentOS7-Base-163.repo
yum clean all
yum makecache
```
## Percona
```
cp /etc/yum.repos.d/percona-original-release.repo /etc/yum.repos.d/percona-original-release.repo.bak
cp /etc/yum.repos.d/percona-prel-release.repo /etc/yum.repos.d/percona-prel-release.repo.bak
sed -i 's#http://repo.percona.com/#https://mirrors.tuna.tsinghua.edu.cn/#g' /etc/yum.repos.d/percona-original-release.repo
sed -i 's#http://repo.percona.com/#https://mirrors.tuna.tsinghua.edu.cn/percona/#g' /etc/yum.repos.d/percona-prel-release.repo
```
## epel
```
mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.bak
wget -O /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo
```
## MySQL 5.7
```
sed -i 's#http://repo.mysql.com/yum/mysql-5.7-community/el/7/#https://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql-5.7-community-el7-#g' /etc/yum.repos.d/mysql-community.repo
sed -i 's#http://repo.mysql.com/yum/mysql-connectors-community/el/7/#https://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql-connectors-community-el7-#g' /etc/yum.repos.d/mysql-community.repo
sed -i 's#http://repo.mysql.com/yum/mysql-tools-community/el/7/#https://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql-tools-community-el7-#g' /etc/yum.repos.d/mysql-community.repo
```
