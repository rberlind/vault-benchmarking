# Vault Benchmarking Scripts
Some Lua scripts for running benchmarks against Vault with the [wrk](https://github.com/wg/wrk) tool.

## Scripts
write-secrets.lua: this writes secrets to Vault's K/V engine, with each thread using a dedicated path.
read-secrets.lua: this reads secrets from Vault's K/V engine, with each thread using a dedicated path.

## Configuration of wrk Client Nodes
To ensure adequate resources on the client nodes that run wrk, we suggest using a Linux node with 4 CPUs and 16 GB of RAM. You can run more than 1 node.  We suggest watching CPU and memory consumption of these nodes with top or similar tools to make sure that you are not exceeding the capacity of the clients themselves. Note that before following [wrk Linux installation instructions](https://github.com/wg/wrk/wiki/Installing-wrk-on-Linux) for Ubuntu, you should run `sudo apt-get update`.

## Examples of Running Scripts
Here are some examples of running these scripts.  Descriptions of the wrk command line options are [here](https://github.com/wg/wrk#command-line-options).

```
nohup wrk -t30 -c120 -d60m -H "X-Vault-Token: <vault_token>" -s write-secrets.lua http://<vault_url>:8200 > test-30-120-2-write-1hour.txt &

nohup wrk -t30 -c120 -d60m -H "X-Vault-Token: <vault_token>" -s read-secrets.lua http://<vault_url>:8200 > test-30-120-2-read-1hour.txt &

```

We use "nohup" on these commands to ensure that the scripts continue to run if our ssh sessions to the nodes running the wrk client get disconnected and output the results to files with the names of the files indicating the parameters used and how long they ran for.

The "-t" parameter gives the number of threads.
The "-c" parameter gives the number of HTTP connections used by all threads.
The "-d" parameter gives the number of minutes to run the test.
