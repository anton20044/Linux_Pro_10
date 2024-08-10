#!/bin/bash

##1
echo "WORD=\"ALERT\"" >> /etc/default/watchlog
echo "LOG=/var/log/watchlog.log" >> /etc/default/watchlog

echo "#!/bin/bash" >> /opt/watchlog.sh
echo "WORD=\$1" >> /opt/watchlog.sh
echo "LOG=\$2" >> /opt/watchlog.sh
echo "DATE=\`date\`" >> /opt/watchlog.sh
echo "if grep \$WORD \$LOG &> /dev/null" >> /opt/watchlog.sh
echo "then" >> /opt/watchlog.sh
echo "logger \"\$DATE: I found word, Master!\"" >> /opt/watchlog.sh
echo "else" >> /opt/watchlog.sh
echo "exit 0" >> /opt/watchlog.sh
echo "fi" >> /opt/watchlog.sh

chmod +x /opt/watchlog.sh

echo "[Unit]" >> /etc/systemd/system/watchlog.service
echo "Description=My watchlog service" >> /etc/systemd/system/watchlog.service
echo "[Service]" >> /etc/systemd/system/watchlog.service
echo "Type=oneshot" >> /etc/systemd/system/watchlog.service
echo "EnvironmentFile=/etc/default/watchlog" >> /etc/systemd/system/watchlog.service
echo "ExecStart=/opt/watchlog.sh \$WORD \$LOG" >> /etc/systemd/system/watchlog.service

echo "[Unit]" >> /etc/systemd/system/watchlog.timer
echo "Description=Run watchlog script every 30 second" >> /etc/systemd/system/watchlog.timer
echo "[Timer]" >> /etc/systemd/system/watchlog.timer
echo "OnBootSec=30" >> /etc/systemd/system/watchlog.timer
echo "OnUnitActiveSec=30" >> /etc/systemd/system/watchlog.timer
echo "Unit=watchlog.service" >> /etc/systemd/system/watchlog.timer
echo "[Install]" >> /etc/systemd/system/watchlog.timer
echo "WantedBy=multi-user.target" >> /etc/systemd/system/watchlog.timer


echo "first line" >> /var/log/watchlog.log
echo "second line" >> /var/log/watchlog.log
echo "every line" >> /var/log/watchlog.log
echo "ALERT" >> /var/log/watchlog.log

systemctl daemon-reload
systemctl restart watchlog.timer




##2
mkdir /etc/spawn-fcgi
echo "SOCKET=/var/run/php-fcgi.sock" > /etc/spawn-fcgi/fcgi.conf
echo "OPTIONS=\"-u www-data -g www-data -s \$SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi\"" >> /etc/spawn-fcgi/fcgi.conf

echo "[Unit]" > /etc/systemd/system/spawn-fcgi.service
echo "Description=Spawn-fcgi startup service by Otus" >> /etc/systemd/system/spawn-fcgi.service
echo "After=network.target" >> /etc/systemd/system/spawn-fcgi.service
echo "[Service]" >> /etc/systemd/system/spawn-fcgi.service
echo "Type=simple" >> /etc/systemd/system/spawn-fcgi.service
echo "PIDFile=/var/run/spawn-fcgi.pid" >> /etc/systemd/system/spawn-fcgi.service
echo "EnvironmentFile=/etc/spawn-fcgi/fcgi.conf" >> /etc/systemd/system/spawn-fcgi.service
echo "ExecStart=/usr/bin/spawn-fcgi -n \$OPTIONS" >> /etc/systemd/system/spawn-fcgi.service
echo "KillMode=process" >> /etc/systemd/system/spawn-fcgi.service
echo "[Install]" >> /etc/systemd/system/spawn-fcgi.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/spawn-fcgi.service

systemctl start spawn-fcgi

##3
echo "[Unit]" >> /etc/systemd/system/nginx@.service
echo "Description=A high performance web server and a reverse proxy server" >> /etc/systemd/system/nginx@.service
echo "Documentation=man:nginx(8)" >> /etc/systemd/system/nginx@.service
echo "After=network.target nss-lookup.target" >> /etc/systemd/system/nginx@.service
echo "[Service]" >> /etc/systemd/system/nginx@.service
echo "Type=forking" >> /etc/systemd/system/nginx@.service
echo "PIDFile=/run/nginx-%I.pid" >> /etc/systemd/system/nginx@.service
echo "ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx-%I.conf -q -g 'daemon on; master_process on;'" >> /etc/systemd/system/nginx@.service
echo "ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;'" >> /etc/systemd/system/nginx@.service
echo "ExecReload=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;' -s reload" >> /etc/systemd/system/nginx@.service
echo "ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx-%I.pid" >> /etc/systemd/system/nginx@.service
echo "TimeoutStopSec=5" >> /etc/systemd/system/nginx@.service
echo "KillMode=mixed" >> /etc/systemd/system/nginx@.service
echo "[Install]" >> /etc/systemd/system/nginx@.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/nginx@.service


cp /etc/nginx/nginx.conf /etc/nginx/nginx-first.conf
cp /etc/nginx/nginx.conf /etc/nginx/nginx-second.conf
sed -i 's/pid \/run\/nginx.pid/pid \/run\/nginx-first.pid/g' /etc/nginx/nginx-first.conf
sed -i 's/http {/http { server { listen 9001; }/g' /etc/nginx/nginx-first.conf
sed -i 's/include \/etc\/nginx\/sites-enabled\/*/#include \/etc\/nginx\/sites-enabled\/*/g' /etc/nginx/nginx-first.conf

sed -i 's/pid \/run\/nginx.pid/pid \/run\/nginx-second.pid/g' /etc/nginx/nginx-second.conf
sed -i 's/http {/http { server { listen 9002; }/g' /etc/nginx/nginx-second.conf
sed -i 's/include \/etc\/nginx\/sites-enabled\/*/#include \/etc\/nginx\/sites-enabled\/*/g' /etc/nginx/nginx-second.conf

systemctl start nginx@first
systemctl start nginx@second
