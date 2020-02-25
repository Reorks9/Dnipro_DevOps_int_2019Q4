https://www.techrepublic.com/article/how-to-set-up-mysql-for-remote-access-on-ubuntu-server-16-04/
/etc/mysql/mysql.conf.d/mysqld.cnf
bind-address = 0.0.0.0

sudo mysql -u root
CREATE USER 'appUser'@'%' IDENTIFIED BY 'appPasswd!';
GRANT ALL ON *.* TO 'appUser'@'%';


















