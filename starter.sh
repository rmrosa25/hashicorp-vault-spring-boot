docker-compose up -d
sleep 10

docker-compose exec vault sh -c 'export VAULT_ADDR="http://127.0.0.1:8201" && export VAULT_TOKEN="00000000-0000-0000-0000-000000000000" && vault secrets enable -path=config-server kv-v2'
docker-compose exec vault sh -c 'export VAULT_ADDR="http://127.0.0.1:8201" && export VAULT_TOKEN="00000000-0000-0000-0000-000000000000" && vault kv put -mount=config-server javatodev_core_api spring.datasource.database=javatodev_application_db spring.datasource.password=mauFJcuf5dhRMQrjj spring.datasource.username=root app.config.auth.token=5bd8b84a-7b9a-11ed-a1eb-0242ac120002 app.config.auth.username=actuator'
docker-compose exec vault sh -c 'export VAULT_ADDR="http://127.0.0.1:8201" && export VAULT_TOKEN="00000000-0000-0000-0000-000000000000" && vault kv put -mount=config-server javatodev_core_api/dev spring.datasource.database=javatodev_application_db spring.datasource.password=mauFJcuf5dhRMQrjj spring.datasource.username=root app.config.auth.token=34ef65f0-7b9d-11ed-a1eb-0242ac120002 app.config.auth.username=dev_user'

# docker-compose exec vault sh -c 'export VAULT_ADDR="http://127.0.0.1:8201" && export VAULT_TOKEN="00000000-0000-0000-0000-000000000000" && vault kv put secret/javatodev_core_api spring.datasource.database=javatodev_application_db spring.datasource.password=mauFJcuf5dhRMQrjj spring.datasource.username=root app.config.auth.token=5bd8b84a-7b9a-11ed-a1eb-0242ac120002 app.config.auth.username=actuator'
# docker-compose exec vault sh -c 'export VAULT_ADDR="http://127.0.0.1:8201" && export VAULT_TOKEN="00000000-0000-0000-0000-000000000000" && vault kv put secret/javatodev_core_api/dev spring.datasource.database=javatodev_application_db spring.datasource.password=mauFJcuf5dhRMQrjj spring.datasource.username=root app.config.auth.token=34ef65f0-7b9d-11ed-a1eb-0242ac120002 app.config.auth.username=dev_user'



docker-compose exec vault sh -c 'export VAULT_ADDR="http://127.0.0.1:8201" && export VAULT_TOKEN="00000000-0000-0000-0000-000000000000" && vault read /sys/mounts/config-server'
docker-compose exec vault sh -c 'export VAULT_ADDR="http://127.0.0.1:8201" && export VAULT_TOKEN="00000000-0000-0000-0000-000000000000" && vault read /sys/mounts/secret'

docker-compose exec vault sh -c 'export VAULT_ADDR="http://127.0.0.1:8201" && export VAULT_TOKEN="00000000-0000-0000-0000-000000000000" && vault kv metadata get -mount=config-server javatodev_core_api'

docker-compose exec vault sh -c 'export VAULT_ADDR="http://127.0.0.1:8201" && export VAULT_TOKEN="00000000-0000-0000-0000-000000000000" && vault kv list -mount=config-server'
docker-compose exec vault sh -c 'export VAULT_ADDR="http://127.0.0.1:8201" && export VAULT_TOKEN="00000000-0000-0000-0000-000000000000" && vault kv get -mount=config-server javatodev_core_api'


docker-compose exec vault sh -c 'export VAULT_ADDR="http://127.0.0.1:8201" && export VAULT_TOKEN="00000000-0000-0000-0000-000000000000" && vault auth enable ldap'
docker-compose exec vault sh -c 'export VAULT_ADDR="http://127.0.0.1:8201" && export VAULT_TOKEN="00000000-0000-0000-0000-000000000000" && vault policy write my-policy - << EOF
# Dev servers have version 2 of KV secrets engine mounted by default, so will
# need these paths to grant permissions:
path "config-server/*" {
  capabilities = ["create", "update", "read", "list"]
}
EOF'

docker-compose exec vault sh -c 'export VAULT_ADDR="http://127.0.0.1:8201" && export VAULT_TOKEN="00000000-0000-0000-0000-000000000000" && vault write auth/ldap/config \
    url="ldap://openldap" \
    userattr=uid \
    userdn="ou=people,dc=example,dc=org" \
    groupdn="ou=groups,dc=example,dc=org" \
    groupfilter="(|(memberUid={{.Username}})(member={{.UserDN}}))" \
    groupattr="cn" \
    binddn="cn=admin,dc=example,dc=org" \
    bindpass="admin"
'
docker-compose exec vault sh -c 'export VAULT_ADDR="http://127.0.0.1:8201" && export VAULT_TOKEN="00000000-0000-0000-0000-000000000000" && vault write auth/ldap/groups/configserver policies=my-policy'


#######TRANSIT###########

docker-compose exec vault sh -c 'export VAULT_ADDR="http://127.0.0.1:8201" && export VAULT_TOKEN="00000000-0000-0000-0000-000000000000" && vault secrets enable transit'
docker-compose exec vault sh -c 'export VAULT_ADDR="http://127.0.0.1:8201" && export VAULT_TOKEN="00000000-0000-0000-0000-000000000000" && vault write -f transit/keys/orders'

docker-compose exec vault sh -c 'export VAULT_ADDR="http://127.0.0.1:8201" && export VAULT_TOKEN="00000000-0000-0000-0000-000000000000" && vault policy write app-orders -<<EOF
path "transit/encrypt/orders" {
   capabilities = [ "update" ]
}
path "transit/decrypt/orders" {
   capabilities = [ "update" ]
}
EOF
'

docker-compose exec vault sh -c 'export VAULT_ADDR="http://127.0.0.1:8201" && export VAULT_TOKEN="00000000-0000-0000-0000-000000000000" && vault token create -policy=app-orders'

docker-compose exec vault sh -c 'apk add jq && export VAULT_ADDR="http://127.0.0.1:8201" && export APP_ORDER_TOKEN=$(vault token create -policy=app-orders -format=json | jq -r ".auth | .client_token") && export CIPHERTEXT=$(VAULT_TOKEN=$APP_ORDER_TOKEN vault write transit/encrypt/orders plaintext=$(echo "4111 1111 1111 1111"| base64) -format=json | jq -r ".data | .ciphertext") && VAULT_TOKEN=$APP_ORDER_TOKEN vault write transit/decrypt/orders ciphertext=$CIPHERTEXT -format=json | jq -r ".data | .plaintext" | base64 -d'


#docker-compose exec vault sh -c 'export VAULT_ADDR="http://127.0.0.1:8201" && vault login -method=ldap username=user'

# docker-compose exec vault sh -c 'export VAULT_ADDR="http://127.0.0.1:8201" && export VAULT_TOKEN="00000000-0000-0000-0000-000000000000" && vault auth enable userpass'

# docker-compose exec vault sh -c 'export VAULT_ADDR="http://127.0.0.1:8201" && export VAULT_TOKEN="00000000-0000-0000-0000-000000000000" && vault write auth/userpass/users/user policies=my-policy password=user123'

# docker-compose exec vault sh -c 'export VAULT_ADDR="http://127.0.0.1:8201" && vault login -method=userpass username=user password=user123'



docker-compose exec openldap sh -c 'ldapmodify -x -D "cn=admin,dc=example,dc=org" -w admin <<EOF
dn: ou=groups,dc=example,dc=org
changetype: add
objectClass: organizationalUnit
ou: groups

dn: ou=people,dc=example,dc=org
changetype: add
objectClass: organizationalUnit
ou: people

dn: cn=configserver,ou=groups,dc=example,dc=org
changetype: add
objectClass: top
objectClass: posixGroup
cn: configserver
gidNumber: 1001

dn: uid=user,ou=people,dc=example,dc=org
changetype: add
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson
cn: User Full Name
sn: User
uid: user
userPassword: user123

dn: cn=configserver,ou=groups,dc=example,dc=org
changetype: modify
add: memberUid
memberUid: user

EOF
'
echo -n "user123" > ~/password.txt

cat <<EOF > ~/vault-proxy.hcl
pid_file = "./pidfile"

vault {
  address = "http://127.0.0.1:8201"
  retry {
    num_retries = 5
  }
}

auto_auth {
  method "ldap" {
    config = {
      username = "user"
      password_file_path = "/home/gitpod/password.txt"
      remove_password_after_reading = false
    }
 }
}

cache {
  // An empty cache stanza still enables caching
}

api_proxy {
  use_auto_auth_token = "force"
  enforce_consistency = "always"
}

listener "tcp" {
  address = "127.0.0.1:8101"
  tls_disable = true
}
EOF

cd ~/
vault proxy -config=vault-proxy.hcl &
cd -
