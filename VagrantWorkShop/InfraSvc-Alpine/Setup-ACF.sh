sudo setup-acf
sudo sed -i 's/^port=.*/port=9443/' /etc/mini_httpd/mini_httpd.conf
sudo /etc/init.d/mini_httpd restart