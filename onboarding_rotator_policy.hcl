# For K/V v1 secrets engine
path "secret/onboarding/accounts/onboarding_account" {
    capabilities = ["create", "update"]
}
# For K/V v2 secrets engine
path "secret/data/onboarding/accounts/onboarding_account/*" {
    capabilities = ["create", "update"]
}

# For K/V v1 secrets engine
path "secret/onboarding/accounts/rotator_account" {
    capabilities = ["read"]
}
# For K/V v2 secrets engine
path "secret/data/onboarding/accounts/rotator_account/*" {
    capabilities = ["read"]
}