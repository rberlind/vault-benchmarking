# Vault Benchmarking Scripts
This repository contains some Lua scripts for running benchmarks against Vault with the [wrk](https://github.com/wg/wrk) tool. They are all designed to be used with Vault's KV (Key/Value) v1 secrets engine.

## Scripts
The following are the main test scripts:
1. [read-secrets.lua](./read-secrets.lua): This script randomly reads secrets from a set of N secrets under the path secret/read-test. It can also print the secrets if you add "-- true" after the URL. The default value of N is 1,000. Use the write-secrets.lua script to populate the secrets read by this script before running it and check that you write all secrets you expect to read. The script reads them randomly over and over until it finishes.
1. [write-random-secrets.lua](./write-random-secrets.lua): This script randomly writes secrets to a set of N secrets under the path secret/write-random-test. The default vaue of N is 1,000. By default, each secret has one key with 10-20 bytes and a second key with 100 bytes.  The number and size of the keys can be changed. The script writes them randomly over and over until it finishes. There is no need to pre-populate Vault with any data for this test.
1. [write-delete-secrets.lua](./write-delete-secrets.lua): This script sequentially writes and deletes secrets. It must be run with one thread (`-t1`) and one connection (`-c1`) to ensure deletes do not reach the Vault server before the corresponding writes. However, multiple instances of this script can be run at the same time by passing an extra argument `-- <n>` after the URL, being sure to use a different value of \<n\> for each instance. Secrets for instance \<n\> of the script will be written in a sequential loop to the secret/write-delete-test path and will be named "test\<n\>-secret-\<x\>" where \<x\> is between 1 and N (default 1,000). This naming convention allows multiple instances of this script as well as other scripts to be run at the same time without conflict. By default, each secret has one key with 10-20 bytes and a second key with 100 bytes.  The number and size of the keys can be changed.  There is no need to pre-populate Vault with any data for this test. The last secret written might not be deleted if the final request is a write.  
1. [list-secrets.lua](./list-secerts.lua): This script repeatedly lists all secrets on the path secret/list-test. Use the write-list.lua script to populate that path with secrets. By default, that script writes 100 secrets to that path with each secret having one key with 10 bytes.
1. [authenticate.lua](.authenticate.lua): This script repeatedly authenticates a user ("loadtester") against Vault's [userpass](https://www.vaultproject.io/docs/auth/userpass.html) authentication method. (See below for instructions to enable it.)

We also have the following utility scripts used to populate or delete secrets used by the test scripts:
1. [write-secrets.lua](./write-secrets.lua): This script writes secrets meant to be read by the read-secrets.lua script. It writes a fixed number of secrets (default 1,000) and then stops. Each secret has one key with 10-20 bytes and a second key with 100 bytes.  The number and size of the keys can be changed.
1. [write-list.lua](./write-list.lua): This script writes a list of 100 secrets each having one key with 10 bytes to the path secret/list-test. These secrets are read by the list-secrets.lua script.
1. [delete-secrets.lua](./delete-secrets.lua): This deletes a sequence of secrets from under a specified path. Pass the path from which you want to delete secrets by adding something like "-- secret/read-test" after the Vault URL. Do not start your path with "/v1/" or add a final "/" at the end of it since the script does this for you. The default path is "secret/test".

Finally, [json.lua](./json.lua) is used by some of the other scripts to decode the JSON responses from the Vault HTTP API.

## Running the Scripts together
The [run_tests.sh](./run_tests.sh) bash script runs the read-secrets.lua, list-secerts.lua, authenticate.lua, and 10 instances of the write-delete-secrets.lua script simultaneously. The number of instances of the last script can be changed to alter the mixture of reads, writes, and deletes. It can be run from multiple clients simultaneously as long as no instances of the write-delete-secrets.lua across these clients use the same identifier argument (\<n\>). Instances of any of the scripts can be commented out by prefacing them with a "#".

In its default configuration, the run_tests script is designed to run a mixture of reads, lists, writes, deletes, and authentications consisting of about 84% reads, 5% lists, 5% writes, 5% deletes, and 1% authentications. Of course, these ratios will vary somewhat depending on your cluster's configuration even if you run the script without altering it.  Making changes to the tests run in the script including removing or adding tests or changing the thread and count parameters passed to them will obviously change the mixture as well as the total throughput of your combined test.

In general, you will want to edit the run_tests.sh script or create modified versions of it before running it so you can change the duration of the tests (with the `-d` parameter) and change the names of the log files.

## Setting up userpass Auth Method
In order to run the authenticate-user.lua script, you need to set up the Vault [userpass](https://www.vaultproject.io/docs/auth/userpass.html) authentication method on your Vault cluster and add a user called loadtester with password benchmark.  Use these commands to do this:

```
vault auth enable userpass
vault write auth/userpass/users/loadtester password=benchmark policies=default
```

## Configuration of wrk Client Nodes

To ensure adequate resources on the client nodes that run wrk, we suggest using a Linux node with 4 CPUs and 8 GB of RAM. You can run more than 1 node. While it is important to not exhaust the resources on your wrk clients, wrk is so efficient that this probably will not happen. Note that before following [wrk Linux installation instructions](https://github.com/wg/wrk/wiki/Installing-wrk-on-Linux) for Ubuntu, you should run `sudo apt-get update`.

## Examples of Running the Test Scripts
See the [run_tests.sh](./run_tests.sh) script for examples of running most of the test scripts.  Note that you should export a Vault token with permission to read, list, write, and delete the secrets used by the tests to the VAULT_TOKEN environment variable with the command `export VAULT_TOKEN=<your_token>`.

The only test script not included in run_tests.sh is write-random-secrets.lua. That can be run with a command like:
```
nohup wrk -t4 -c16 -d1h -H "X-Vault-Token: $VAULT_TOKEN" -s write-random-secrets.lua http://<vault_url>:8200 > prod-test-write-1000-random-secrets-t4-c16-1hour.log &
```

We use "nohup" on the test scripts to ensure that the scripts continue to run if our ssh session to the node running the wrk client gets disconnected and output the results to files with the names of the files indicating the parameters used and how long they ran for.

If you want the read-secrets.lua and list-secrets.lua scripts to print the secrets they retrieve, add `-- true` after the Vault URL.

When running multiple instances of the write-delete-secrets.lua script simultaneously, be sure to add an extra argument `-- <n>` after the URL and to use a different value of \<n\> for each instance. Please also always run this script with one thread (`-t1`) and one connection (`-c1`) to ensure deletes do not reach the Vault server before the corresponding writes.

Descriptions of the wrk command line options are [here](https://github.com/wg/wrk#command-line-options).

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

# Command to delete secrets (from secret/read-test)
wrk -t1 -c1 -d1m -H "X-Vault-Token: $VAULT_TOKEN" -s delete-secrets.lua http://<vault_url>:8200 -- secret/read-test
```
Note that you should specify the path from which you want to delete secrets when running the delete-secrets.lua script. The default value is "secret/test".
