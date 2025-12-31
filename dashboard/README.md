# wazuh-dashboard (Makejail)

Unlike the manager, agent, and certs-generator tool, this Makejail is not based on the Dockerfile created by the Wazuh team. Instead, this Makejail simply installs the `wazuh-dashboard` package and then configures two crucial files: `opensearch_dashboards.yml` and `wazuh.yml`. The first is the configuration for opensearch-dashboards and the second is the configuration for the wazuh module. Automation is possible thanks to the `REPLACE` instruction of `appjail-makejail(5)`, but the front-end interface is the Makejail arguments, which are as follows:

* `opensearch_addr` (mandatory)
* `wazuh_api_url` (mandatory)
* `wazuh_api_password` (mandatory)
* `opensearch_port` (default: `9200`)
* `opensearch_username` (default: `admin`)
* `opensearch_password` (default: `admin`)
* `wazuh_api_port` (default: `55000`)
* `wazuh_api_username` (default: `wazuh-wui`)

See wazuh-dashboard's Director file for more details, although it's worth mentioning the permissions used by TLS certificates and keys:

```console
# ls -ld /var/appjail-volumes/wazuh-dashboard/certs
drwxr-xr-x  2 root wheel 5 28 dic.  17:46 /var/appjail-volumes/wazuh-dashboard/certs
# ls -ld /var/appjail-volumes/wazuh-dashboard/certs/*
-r--------  1 www www 1704 28 dic.  14:10 /var/appjail-volumes/wazuh-dashboard/certs/dashboard-key.pem
-r--------  1 www www 1281 28 dic.  14:10 /var/appjail-volumes/wazuh-dashboard/certs/dashboard.pem
-r--------  1 www www 1204 28 dic.  14:10 /var/appjail-volumes/wazuh-dashboard/certs/root-ca.pem
```
