#!/bin/bash

vault policy write onboarding_main_policy onboarding_main_policy.hcl

vault policy write onboarding_rotator_policy onboarding_rotator_policy.hcl

vault write auth/approle/role/onboarding_main_role token_num_uses=0 secret_id_num_uses=0

vault write auth/approle/role/onboarding_rotator_role token_num_uses=0 secret_id_num_uses=0

curl -X POST -H "X-Vault-Token:$VAULT_TOKEN" -d '{"policies":"default,onboarding_main_policy"}' ${VAULT_ADDR}/v1/auth/approle/role/onboarding_main_role -k

curl -X POST -H "X-Vault-Token:$VAULT_TOKEN" -d '{"policies":"default,onboarding_rotator_policy"}' ${VAULT_ADDR}/v1/auth/approle/role/onboarding_rotator_role -k

MAIN_APPROLE_ID=$(vault read -format=json auth/approle/role/onboarding_main_role/role-id | jq -r '.data.role_id')

MAIN_APPROLE_SECRET_ID=$(vault write -format=json -force auth/approle/role/onboarding_main_role/secret-id | jq -r '.data.secret_id')

echo "The Main Approle ID is : $MAIN_APPROLE_ID"

echo "The Main Approle Secret ID is : $MAIN_APPROLE_SECRET_ID"

MAIN_VAULT_TOKEN=$(curl -s --request POST --data '{"role_id":"'"$MAIN_APPROLE_ID"'","secret_id":"'"$MAIN_APPROLE_SECRET_ID"'"}' "$VAULT_ADDR"/v1/auth/approle/login | jq -r '.auth.client_token')

echo "The Main Token is : $MAIN_VAULT_TOKEN"

ROTATOR_APPROLE_ID=$(vault read -format=json auth/approle/role/onboarding_rotator_role/role-id | jq -r '.data.role_id')

ROTATOR_APPROLE_SECRET_ID=$(vault write -format=json -force auth/approle/role/onboarding_rotator_role/secret-id | jq -r '.data.secret_id')

echo "The Rotator Approle ID is : $ROTATOR_APPROLE_ID"

echo "The Rotator Approle Secret ID is : $ROTATOR_APPROLE_SECRET_ID"

ROTATOR_VAULT_TOKEN=$(curl -s --request POST --data '{"role_id":"'"$ROTATOR_APPROLE_ID"'","secret_id":"'"$ROTATOR_APPROLE_SECRET_ID"'"}' "$VAULT_ADDR"/v1/auth/approle/login | jq -r '.auth.client_token')

echo "The Rotator Token is : $ROTATOR_VAULT_TOKEN"