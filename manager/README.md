# wazuh-manager (Makejail)

The hard part of deploying wazuh-manager is finding a way to preserve data in order to honor the ephemeral concept, much like Docker does. The good news is that the Wazuh team maintains a list of files that are already categorized as follows:

1. [Permanent data](https://github.com/wazuh/wazuh-docker/blob/main/build-docker-images/wazuh-manager/config/permanent_data.env#L3).
2. [Data in the permanent volume that should be updated](https://github.com/wazuh/wazuh-docker/blob/main/build-docker-images/wazuh-manager/config/permanent_data.env#L15) each time wazuh-manager is deployed.
3. [Data in the permanent volume that should be deleted](https://github.com/wazuh/wazuh-docker/blob/main/build-docker-images/wazuh-manager/config/permanent_data.env#L79).
4. [Data that should be renamed](https://github.com/wazuh/wazuh-docker/blob/main/build-docker-images/wazuh-manager/config/permanent_data.env#L83).

At the time of writing, the third type only has one file that should be related to [this issue](https://github.com/wazuh/wazuh/issues/2050). And in the case of the fourth type, it is not necessary to implement it, as it appears to be related to a legacy part of OSSEC, specifically in migrations, although it may be used when we have [Wazuh v5](https://github.com/wazuh/wazuh/issues/22888).

At least, with this crucial list we can know what should persist in recreations, but how to implement it? In Wazuh, they move the data to [/var/ossec/data_tmp](https://github.com/wazuh/wazuh-docker/blob/main/build-docker-images/wazuh-manager/config/etc/cont-init.d/0-wazuh-init#L40), and this is done when creating the container image. In AppJail, we can do this using AppJail images, but the size will be ~4 GiB, which makes distribution unfeasible, so I chose to [cache](https://github.com/DtxdF/wazuh-makejail/blob/main/manager/appjail-director.yml#L30) the `pkg(8)` dependencies so that, even in recreations, this does not take long, unless `pkg(8)` detects changes in the FreeBSD mirrors. However, the problem with this approach is that we cannot use the logic implemented in Wazuh, since the volume is already present even at the time the jail is created and customized (e.g.: at the time Makejail is run). With `<pseudofs>` this can be achieved, but the data will be moved to the volume, and the "permanent data that should be updated" cannot be updated, since we do not have that copy, only the original file and, worse still, in the permanent data.

My first attempt was to use symlinks, [as OSSEC does](https://github.com/ossec/ossec-docker/blob/master/init.sh#L11), but this proves problematic with `wazuh-analysisd`, [which appears to chroot to /var/ossec](https://groups.google.com/g/wazuh/c/0HDde9QcOgI/m/343jMvT7AQAJ), so a symlink pointing to a location that does not exist in that environment generates an error. The second attempt, which solved this problem, was to use `nullfs(4)`inside the jail, so the `rc(8)` script [wazuh-manager-mount](files/wazuh-manager-mount.in) was created to mounts a list of files enumerated in `/wazuh-manager-mount.lst`. This list is created dynamically by [scripts/permanent_data.sh](scripts/permanent_data.sh). The side effect of this is that you should not update Wazuh using `pkg(8)`, although anyone coming from Docker or deploying jails using AppJail with the ephemeral concept should have no problems, and if you use Director, it should be as easy as `appjail-director down -d && appjail-director up`.

It is worth noting the initialization script, which is a combination of all the scripts in the [initialization directory](https://github.com/wazuh/wazuh-docker/tree/main/build-docker-images/wazuh-manager/config/etc/cont-init.d), respecting their order. Of course, functions that do not make sense for this particular implementation are not implemented.

1. `HOSTNAME` is an environment variable that can be set, but if it is not set, the script will use the value returned by `hostname(1)`.
2. `/etc/localtime` is copied to `/var/ossec/etc/localtime`, so it should exist.
3. `/var/ossec/etc/sslmanager.key` must exist, or the script will create both the key and the certificate, which are not recreated when the jail is recreated, as they must exist on the volume.
4. `/wazuh-config-mount`, when mounted, the files are copied as-is to `/var/ossec`.
5. If you have `<node_name>to_be_replaced_by_hostname</node_name>` in your ossec.conf configuration file, the value of this setting can be changed with the value of `HOSTNAME`. See also: https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/cluster.html#node-name
6. `<cluster><key></key></cluster>` can be changed using the environment variable `WAZUH_CLUSTER_KEY`. See also: https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/cluster.html#key
7. `<cluster><node_name></node_name></cluster>`can be changed using the environment variable `WAZUH_NODE_NAME` which by default use the value of `HOSTNAME`. See also: https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/cluster.html#node-name
8. `WAZUH_INDEXER_HOSTS`, unlike what the Wazuh team implemented in Docker, where hosts are separated by commas, in this case they are separated by spaces. See also: https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/indexer.html#hosts
9. `<cluster><node_type></node_type></cluster>` can be changed using the environment variable `WAZUH_NODE_TYPE` which, when isn't set to `worker`, it defaults to `master`. See also: https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/cluster.html#node-type
10. `<cluster><bind_addr></bind_addr></cluster>` can be changed using the environment variable `WAZUH_CLUSTER_BIND_ADDR`. See also: https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/cluster.html#bind-addr
11. A list of cluster nodes can be defined using `WAZUH_CLUSTER_NODES`, a space-separated list. See also: https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/cluster.html#nodes
12. `/wazuh-migration`, when exists and have all the necessary files, a migration can be accomplished. See the script for details.
13. `API_USERNAME` and `API_PASSWORD`, when defined, credentials for Wazuh's API are created and the [create_user.py](https://github.com/wazuh/wazuh-docker/blob/main/build-docker-images/wazuh-manager/config/create_user.py) is executed.
14. `INDEXER_PASSWORD`, when defined, configures indexer's credentials. `INDEXER_USERNAME` can be defined, too.
15. `/entrypoint-scripts` can contain scripts that are executed in lexicographical order using `/bin/sh`.

Please note that the [indexer-connector is not optional](https://github.com/wazuh/wazuh/issues/33018), even if you disable it, so Wazuh will attempt to connect to it. Therefore, it is important to place the TLS certificates and keys in the correct location.

```console
# ls /var/appjail-volumes/wazuh/indexer-connector-certs/
node-1-key.pem	node-1.pem	root-ca.pem
```

There, we are using the CA certificate created by the certs-generator tool and the same certificate and key used by OpenSearch, which is not realistic, but useful for this PoC. If you are interested in using a different certificate and key, remember to add the subject to `opensearch.yml` as follows:

```yaml
...
plugins.security.nodes_dn:
- "CN=node-1,OU=Wazuh,O=Wazuh,L=California,C=US"
...
```

And this should match with the subject like:

```console
# openssl x509 -in user-files/certs/node-1.pem -noout -subject
subject=C=US, L=California, O=Wazuh, OU=Wazuh, CN=node-1
```
