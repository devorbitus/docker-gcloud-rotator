#!/bin/bash

die() { echo "$*" 1>&2 ; exit 1; }

if [ -z "$SA_EMAIL" ]; then
    die "service account email address of account to be rotated SA_EMAIL needed to continue"
fi

if [ -z "$APPROLE_ID" ]; then
    die "vault approle ID APPROLE_ID needed to continue"
fi

if [ -z "$APPROLE_SECRET_ID" ]; then
    die "vault approle secret ID APPROLE_SECRET_ID needed to continue"
fi

if [ -z "$VAULT_ADDR" ]; then
    die "vault address VAULT_ADDR needed to continue"
fi

if [ -z "$VAULT_ONBOARDING_LOCATION" ]; then
    die "vault onboarding location VAULT_ONBOARDING_LOCATION needed to continue"
fi

if [ -z "$VAULT_ONBOARDING_KEY" ]; then
    die "vault onboarding key VAULT_ONBOARDING_KEY needed to continue"
fi

if [ -z "$VAULT_ONBOARDING_ROTATOR_KEY" ]; then
    die "vault onboarding rotator key VAULT_ONBOARDING_ROTATOR_KEY needed to continue"
fi

CURRENT_DATE_TIME=$(date)

VAULT_TOKEN=$(curl -s --request POST --data '{"role_id":"'"$APPROLE_ID"'","secret_id":"'"$APPROLE_SECRET_ID"'"}' "$VAULT_ADDR"/v1/auth/approle/login | jq -r '.auth.client_token')

if [ -z "$VAULT_TOKEN" ]; then
    die "Unable to get vault token with the provided approle ID and approle secret ID"
fi

./vault login "$VAULT_TOKEN"

./vault read -field "$VAULT_ONBOARDING_ROTATOR_KEY" secret/"$VAULT_ONBOARDING_LOCATION/$VAULT_ONBOARDING_ROTATOR_KEY" | gcloud auth activate-service-account --key-file=-

if [ "$?" -ne 0 ]; then
    die "Unable to login to GCP using key rotator service account key"
fi

gcloud iam service-accounts keys create --iam-account "$SA_EMAIL" key.json

if [ "$?" -ne 0 ]; then
    die "Unable to generate new service account key for the onboarder account using the key rotator service account"
fi

./vault write secret/"$VAULT_ONBOARDING_LOCATION/$VAULT_ONBOARDING_KEY" "$VAULT_ONBOARDING_KEY"=@key.json

if [ "$?" -ne 0 ]; then
    die "Unable to store new key into vault"
fi

while [[ $(gcloud iam service-accounts keys list --iam-account "$SA_EMAIL" --managed-by=user --format=json --created-before="$CURRENT_DATE_TIME") != "[]" ]]; do
    for key in $(gcloud iam service-accounts keys list --iam-account="$SA_EMAIL" --managed-by=user --format=json --created-before="$CURRENT_DATE_TIME" | jq -r '.[].name')
    do
        echo "y" | gcloud iam service-accounts keys delete --iam-account="$SA_EMAIL" "$key"
    done
    echo "removed all previous keys"
done