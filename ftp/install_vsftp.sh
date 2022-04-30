#server
mkdir /data

yum install vsftpd ftp -y

touch /etc/vsftpd/vsftpd.user_list
touch /etc/vsftpd/vsftpd.chroot_list

echo > /etc/vsftpd/vsftpd.conf
cat << EOF > /etc/vsftpd/vsftpd.conf

EOF

mkdir /etc/vsftpd/userconfig

systemctl enable vsftpd --now

useradd -g root -M -d /data/test -s /sbin/nologin test
passwd test

mkdir /data/test
chown -R test.root /data/test
chmod 750 /data/test

#创建用户
cat << EOF >> /etc/vsftpd/logins.txt
test1
12345678
test2
87654321
EOF

db_load -T -t hash -f /etc/vsftpd/logins.txt /etc/vsftpd/vsftpd_login.db


cat << EOF >> /etc/vsftpd/userconfig/test1
local_root=/data/test/test1
write_enable=YES
anon_world_readable_only=NO
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
EOF

cat << EOF >> /etc/vsftpd/userconfig/test2
local_root=/data/test/test2
write_enable=YES
anon_world_readable_only=NO
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
EOF

mkdir -p /data/test/test1
mkdir -p /data/test/test2

chown -R test.root /data/test/test1
chown -R test.root /data/test/test2

chmod 777 /data/test/test1
chmod 777 /data/test/test2

cat << EOF >> /etc/pam.d/ftp
auth required /lib64/security/pam_userdb.so db=/etc/vsftpd/vsftpd_login
account required /lib64/security/pam_userdb.so db=/etc/vsftpd/vsftpd_login
EOF

systemctl restart vsftpd
