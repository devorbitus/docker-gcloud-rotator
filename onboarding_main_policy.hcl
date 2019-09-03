# For K/V v1 secrets engine
path "secret/onboarding/accounts/onboarding_account" {
    capabilities = ["read"]
}
# For K/V v2 secrets engine
path "secret/data/onboarding/accounts/onboarding_account/*" {
    capabilities = ["read"]
}
# For K/V v1 secrets engine
path "secret/onboarding/projects/*" {
    capabilities = ["create", "update", "read"]
}
# For K/V v2 secrets engine
path "secret/data/onboarding/projects/*" {
    capabilities = ["create", "update", "read"]
}

# For Terraformer vault permissions
path "auth/token/create" {
	capabilities = ["update"]
}