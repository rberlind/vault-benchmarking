#!/usr/bin/env bash

usage(){
    echo "Usage: $0 num_threads num_http_conn test_time"
    exit 1
}

[[ $# -ne 3 ]] && usage

num_threads=$1
num_http_conn=$2
test_time=$3

echo "$num_threads threads, $num_http_conn http connections, $test_time period of time"

# Run read test in background
# Make sure that the secrets already exist in Vault before running this test
# You can use write-secrets.lua (after some modification) to populate them

nohup wrk -t4 -c16 -d"$test_time" -H "X-Vault-Token: $VAULT_TOKEN" -s read-secrets.lua $VAULT_ADDR -- 1000 false > prod-test-read-1000-random-secrets-t4-c16-$test_time.log &

# Run list test in background
# Make sure that the secrets already exist in Vault before running this test
# You can use write-secrets.lua (after some modification) to populate them
nohup wrk -t"$num_threads" -c2 -d"$test_time" -H "X-Vault-Token: $VAULT_TOKEN" -s list-secrets.lua $VAULT_ADDR -- false > prod-test-list-100-secrets-t1-c2-$test_time.log &

# Run authentication/revocation test in background
nohup wrk -t"$num_threads" -c16 -d"$test_time" -H "X-Vault-Token: $VAULT_TOKEN" -s authenticate-and-revoke.lua $VAULT_ADDR > prod-test-authenticate-revoke-t$num_threads-c16-$test_time.log &

# Run write/delete test in background
nohup wrk -t"$num_threads" -c"$num_http_conn" -d"$test_time" -H "X-Vault-Token: $VAULT_TOKEN" -s write-delete-secrets.lua $VAULT_ADDR -- 1 100 > prod-test-write-and-delete-100-secrets-t$num_threads-c$num_http_conn-$test_time-tes$num_threads.log &

# Run write/delete test in background
nohup wrk -t"$num_threads" -c"$num_http_conn" -d"$test_time" -H "X-Vault-Token: $VAULT_TOKEN" -s write-delete-secrets.lua $VAULT_ADDR -- 2 100 > prod-test-write-and-delete-100-secrets-t$num_threads-c$num_http_conn-$test_time-test2.log &

# Run write/delete test in background
nohup wrk -t"$num_threads" -c"$num_http_conn" -d"$test_time" -H "X-Vault-Token: $VAULT_TOKEN" -s write-delete-secrets.lua $VAULT_ADDR -- 3 100 > prod-test-write-and-delete-100-secrets-t$num_threads-c$num_http_conn-$test_time-test3.log &

# Run write/delete test in background
nohup wrk -t"$num_threads" -c"$num_http_conn" -d"$test_time" -H "X-Vault-Token: $VAULT_TOKEN" -s write-delete-secrets.lua $VAULT_ADDR -- 4 100 > prod-test-write-and-delete-100-secrets-t$num_threads-c$num_http_conn-$test_time-test4.log &

# Run write/delete test in background
nohup wrk -t"$num_threads" -c"$num_http_conn" -d"$test_time" -H "X-Vault-Token: $VAULT_TOKEN" -s write-delete-secrets.lua $VAULT_ADDR -- 5 100 > prod-test-write-and-delete-100-secrets-t$num_threads-c$num_http_conn-$test_time-test5.log &

# Run write/delete test in background
nohup wrk -t"$num_threads" -c"$num_http_conn" -d"$test_time" -H "X-Vault-Token: $VAULT_TOKEN" -s write-delete-secrets.lua $VAULT_ADDR -- 6 100 > prod-test-write-and-delete-100-secrets-t$num_threads-c$num_http_conn-$test_time-test6.log &

# Run write/delete test in background
nohup wrk -t"$num_threads" -c"$num_http_conn" -d"$test_time" -H "X-Vault-Token: $VAULT_TOKEN" -s write-delete-secrets.lua $VAULT_ADDR -- 7 100 > prod-test-write-and-delete-100-secrets-t$num_threads-c$num_http_conn-$test_time-test7.log &

# Run write/delete test in background
nohup wrk -t"$num_threads" -c"$num_http_conn" -d"$test_time" -H "X-Vault-Token: $VAULT_TOKEN" -s write-delete-secrets.lua $VAULT_ADDR -- 8 100 > prod-test-write-and-delete-100-secrets-t$num_threads-c$num_http_conn-$test_time-test8.log &

# Run write/delete test in background
nohup wrk -t"$num_threads" -c"$num_http_conn" -d"$test_time" -H "X-Vault-Token: $VAULT_TOKEN" -s write-delete-secrets.lua $VAULT_ADDR -- 9 100 > prod-test-write-and-delete-100-secrets-t$num_threads-c$num_http_conn-$test_time-test9.log &

# Run write/delete test in background
nohup wrk -t"$num_threads" -c"$num_http_conn" -d"$test_time" -H "X-Vault-Token: $VAULT_TOKEN" -s write-delete-secrets.lua $VAULT_ADDR -- 10 100 > prod-test-write-and-delete-100-secrets-t$num_threads-c$num_http_conn-$test_time-test10.log &
