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
