# Vault Benchmarking Scripts
This repository contains some Lua scripts for running benchmarks against Vault with the [wrk](https://github.com/wg/wrk) tool. They are all designed to be used with Vault's KV (Key/Value) v1 secrets engine.

## Scripts
We have the following test scripts:
1. [read-secrets.lua](./read-secrets.lua): This script randomly reads secrets from a set of N secrets under the path secret/read-test. It can also print the secrets if you add "-- true" after the URL. The default value of N is 1,000. Use the write-secrets.lua script to populate the secrets read by this script before running it and check that you write all secrets you expect to read
1. [write-random-secrets.lua](./write-random-secrets.lua): This script randomly writes secrets to a set of N secrets under the path secret/write-test. The default vaue of N is 1,000. By default, this writes the same secrets as the write-secrets.lua script. It just reads writes them randomly over and over until the script finishes. There is no need to pre-populate Vault with any data for this test.
1. [write-delete-secrets.lua](./write-delete-secrets.lua): This script sequentially writes and deletes secrets on an even number of threads.  The odd-numbered threads write the secrets while the even-numbered threads delete them in the same order after an initial delay designed to ensure that Vault has finished writing the secrets before the script tries to delete them. Note that some secrets will not be deleted at the end of any test with this script since the deletion threads are always behind the write threads. By default, this writes the same secrets as write-secrets.lua, but writes them to the path secret/write-delete-test. This allows the read-secrets.lua script to be run at the same time as this script without having this script delete any secrets read by that script. It starts with the write, so there is no need to pre-populate Vault with any data for this test.
1. [one-thread-write-delete-secrets.lua](./one-thread-write-delete-secrets.lua): This script alternates writes and deletes against 1,000 secrets sequentially on one thread. It starts with the write, so there is no need to pre-populate Vault with any data for this test. It uses the same secrets as the write-delete-secrets.lua script.
1. [list-secrets.lua](./list-secerts.lua): This script repeatedly lists all secrets on the path secret/list-test. Use the write-list.lua script to populate that path with secrets. By default, that script writes 100 secrets to that path with each secret having one key with 10 bytes.
1. [run_tests.sh](./run_tests.sh): This bash script runs the read-secrets.lua, write-delete-secrets.lua, and list-secerts.lua scripts simultaneously.

We also have the following utility scripts used to populate or delete secrets used by the test scripts:
1. [write-secrets.lua](./write-secrets.lua): This script writes secrets meant to be read by the read-secrets.lua script. It writes a fixed number of secrets (default 1,000) and then stops. Each secret has one key with 10-20 bytes and a second key with 100 bytes.  The number and size of the keys could be changed.
1. [write-list.lua](./write-list.lua): This script writes a list of 100 secrets each having one key with 10 bytes to the path secret/list-test. These secrets are read by the list-secrets.lua script.
1. [delete-secrets.lua](./delete-secrets.lua): This deletes a sequence of secrets from Vault's K/V engine. You will need to edit the path and the stop condition in the response method.

Finally, [json.lua](./json.lua) is used by some of the other scripts to decode the JSON responses from the Vault HTTP API.

## Configuration of wrk Client Nodes

To ensure adequate resources on the client nodes that run wrk, we suggest using a Linux node with 4 CPUs and 8 GB of RAM. You can run more than 1 node. While it is important to not exhaust the resources on your wrk clients, wrk is so efficient that this probably will not happen. Note that before following [wrk Linux installation instructions](https://github.com/wg/wrk/wiki/Installing-wrk-on-Linux) for Ubuntu, you should run `sudo apt-get update`.

## Examples of Running the Test Scripts
We include the commands from the run_tests.sh script here to provide examples of running these scripts.  Note that you should export a Vault token with permission to read the secrets used by the tests to the VAULT_TOKEN environment variable with the command `export VAULT_TOKEN=<your_token>`. Descriptions of the wrk command line options are [here](https://github.com/wg/wrk#command-line-options).

```
nohup wrk -t4 -c16 -d1h -H "X-Vault-Token: $VAULT_TOKEN" -s read-secrets.lua http://<vault_url>:8200 > prod-test-read-1000-random-secrets-t4-c16-1hour.log &

nohup wrk -t2 -c8 -d1h -H "X-Vault-Token: $VAULT_TOKEN" -s write-delete-secrets.lua http://<vault_url>:8200 > prod-test-write-and-delete-1000-random-secrets-t2-c8-1hour.log &

nohup wrk -t1 -c2 -d1h -H "X-Vault-Token: $VAULT_TOKEN" -s list-secrets.lua http://<vault_url>:8200 > prod-test-list-100-secrets-t1-c2-1hour.log &
```

If you want the read-secrets.lua and list-secrets.lua scripts to print the secrets they retrieve, add `-- true` after the Vault URL. We use "nohup" on the test scripts to ensure that the scripts continue to run if our ssh session to the node running the wrk client gets disconnected and output the results to files with the names of the files indicating the parameters used and how long they ran for.

Notes on the parameters:
1. The "-t" parameter gives the number of threads.
1. The "-c" parameter gives the number of HTTP connections used by all threads.
1. The "-d" parameter gives the number of seconds (s), minutes (m) or hours (h) to run the test.

## Examples of Running the Utility Scripts
Here are example of running the utility scripts to populate and delete secrets needed by the test scripts:

```
# Command to write secrets needed by the read-secrets.lua script:
wrk -t1 -c1 -d1m -H "X-Vault-Token: $VAULT_TOKEN" -s write-secrets.lua http://<vault_url>:8200

# Command to write secrets needed by the list-secrets.lua script:
wrk -t1 -c1 -d1m -H "X-Vault-Token: $VAULT_TOKEN" -s write-list.lua http://<vault_url>:8200

# Command to delete secrets
wrk -t1 -c1 -d1m -H "X-Vault-Token: $VAULT_TOKEN" -s delete-secrets.lua http://<vault_url>:8200
```
