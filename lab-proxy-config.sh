# add proxy to yum
echo proxy=http://172.16.14.250:3128 >> /etc/yum.conf

# update system
yum -y update

# configure proxy 
echo 'MY_PROXY_URL="http://172.16.14.250:3128/"' >> /etc/profile
echo 'HTTP_PROXY=$MY_PROXY_URL' >> /etc/profile
echo 'HTTPS_PROXY=$MY_PROXY_URL' >> /etc/profile
echo 'FTP_PROXY=$MY_PROXY_URL' >> /etc/profile
echo 'http_proxy=$MY_PROXY_URL' >> /etc/profile
echo 'https_proxy=$MY_PROXY_URL' >> /etc/profile
echo 'ftp_proxy=$MY_PROXY_URL' >> /etc/profile
echo 'export HTTP_PROXY HTTPS_PROXY FTP_PROXY http_proxy https_proxy ftp_proxy' >> /etc/profile
source /etc/profile