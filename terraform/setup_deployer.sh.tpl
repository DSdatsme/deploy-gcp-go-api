#!bin/bash

# install terraform version v0.14.6
# build binary
# cd /tmp
# wget https://golang.org/dl/go1.16.4.linux-amd64.tar.gz
# rm -rf /usr/local/go && tar -C /usr/local -xzf go1.16.4.linux-amd64.tar.gz
# export PATH=$PATH:/usr/local/go/bin
# /tmp/deploy-gcp-go-api/api/src/api
# go build deploy-gcp-go-api/api/bin/


echo "a" >> /tmp/a.log
cd /tmp
git clone https://dsdatsme:${github_token}@github.com/DSdatsme/deploy-gcp-go-api.git
echo "b" >> /tmp/a.log
cp /tmp/deploy-gcp-go-api/api/bin/ubuntu_api /opt/api
chmod +x /opt/api
cd /opt
echo "c" >> /tmp/a.log
cat <<EOF > config.json
{
  "http_port": 80,
  "db_connstring": "postgresql://postgres:sudopasswd@${database_server_ip}"
}
EOF
echo "d" >> /tmp/a.log

./api --config-file config.json
