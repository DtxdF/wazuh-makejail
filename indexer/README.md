# wazuh-indexer (Makejail)

Unlike the manager, agent, and certs-generator tool, this Makejail is not based on the Dockerfile created by the Wazuh team. Instead, this Makejail simply installs filebeat, logstash, and opensearch. It installs the wazuh module for filebeat, installs the logstash-output-opensearch plugin, configures opensearch, configures logstash and filebeat, and initializes the opensearch security index each time this Makejail is run. Since we are not modifying `internal_users.yml`, we are using the default credentials, but you can use the `file` option of `appjail-quick(1)` to copy a modified `internal_users.yml` that better suits your needs, although you will also need to modify `logstash.conf`.

Since Director can easily deploy multiple jails on the same host, we could deploy one jail per service, or in other words, one jail for filebeat, another for logstash, and another for opensearch. This is recommended for a production environment, as it can be scaled even if they are on different servers using a tool like Overlord, although filebeat must be deployed on the same host as the manager, as it needs to access `alerts.json`.

Do not assume that the configuration files used here are up to date. If you need them at any time, here are the remotes used by the ports:

* http://distcache.FreeBSD.org/local-distfiles/acm/wazuh/wazuh-4.14.1-indexer.yml
* http://distcache.freebsd.org/local-distfiles/acm/wazuh/logstash.conf
* http://distcache.freebsd.org/local-distfiles/acm/wazuh/filebeat.yml
* https://packages.wazuh.com/4.x/filebeat/wazuh-filebeat-0.4.tar.gz
* https://raw.githubusercontent.com/wazuh/wazuh/v4.14.1/extensions/elasticsearch/7.x/wazuh-template.json

The last two are downloaded each time this Makejail is run.

See wazuh-indexer's Director file for more details, although it's worth mentioning the permissions used by TLS certificates and keys:

```console
# ls -ld /var/appjail-volumes/wazuh-indexer/opensearch-certs
drwxr-xr-x  2 root 855 7 31 dic.  01:47 /var/appjail-volumes/wazuh-indexer/opensearch-certs
# ls -ld /var/appjail-volumes/wazuh-indexer/opensearch-certs/*
-r--------  1 855 855 1704 28 dic.  14:10 /var/appjail-volumes/wazuh-indexer/opensearch-certs/admin-key.pem
-r--------  1 855 855 1220 28 dic.  14:10 /var/appjail-volumes/wazuh-indexer/opensearch-certs/admin.pem
-r--------  1 855 855 1708 28 dic.  14:10 /var/appjail-volumes/wazuh-indexer/opensearch-certs/node-1-key.pem
-r--------  1 855 855 1277 28 dic.  14:10 /var/appjail-volumes/wazuh-indexer/opensearch-certs/node-1.pem
-r--------  1 855 855 1204 28 dic.  14:10 /var/appjail-volumes/wazuh-indexer/opensearch-certs/root-ca.pem
```
