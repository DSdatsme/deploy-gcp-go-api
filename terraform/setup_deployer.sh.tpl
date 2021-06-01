#!bin/bash

# install terraform version v0.14.6
# build binary


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
  "db_connstring": "postgresql://postgres:${database_password}@${database_server_ip}"
}
EOF
echo "d" >> /tmp/a.log

/opt/consul/bin/run-consul --client --cluster-tag-name "cluster-tag"

./api --config-file config.json
