#!/usr/bin/env bash

# Run read test in background
# Make sure that the secrets already exist in Vault before running this test
# You can use write-secrets.lua (after some modification) to populate them
nohup wrk -t4 -c16 -d1h -H "X-Vault-Token: $VAULT_TOKEN" -s read-secrets.lua http://benchmark-vault-elb-373243349.us-east-1.elb.amazonaws.com:8200 > prod-test-read-1000-random-secrets-t4-c16-1hour.log &

# Run write/delete test in background
# Make sure that the secrets already exist in Vault before running this test
# You can use write-secrets.lua (after some modification) to populate them
nohup wrk -t2 -c8 -d1h -H "X-Vault-Token: $VAULT_TOKEN" -s write-delete-secrets.lua http://benchmark-vault-elb-373243349.us-east-1.elb.amazonaws.com:8200 > prod-test-write-and-delete-1000-random-secrets-t2-c8-1hour.log &

# Run list test in background
# Make sure that the secrets already exist in Vault before running this test
# You can use write-secrets.lua (after some modification) to populate them
nohup wrk -t1 -c2 -d1h -H "X-Vault-Token: $VAULT_TOKEN" -s list-secrets.lua http://benchmark-vault-elb-373243349.us-east-1.elb.amazonaws.com:8200 > prod-test-list-100-secrets-t1-c2-1hour.log &
