# wazuh-agent (Makejail)

Implementing the Makejail for wazuh-agent was fairly straightforward, but unlike the Docker implementation, I do not want to limit it to being just a syslog collector or for integrations. I want to use it alongside other Makejails, so from the wazuh-manager perspective, it is just like any other host.

Unlike the wazuh-manager implementation, wazuh-agent does not have any logic implemented to separate data that should persist from ephemeral data, so when the jail is recreated, wazuh-manager may consider the agent to be a duplicate, so [agent replacement options](https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/auth.html#force) must be configured to avoid or minimize this. See also: https://documentation.wazuh.com/current/user-manual/agent/agent-management/remove-agents/restful-api-remove.html#removing-disconnected-agents

1. `/etc/localtime` is copied to `/var/ossec/etc/localtime`, so it should exist.
2. `<authorization_pass_path>` is removed.
3. If you have `<address>CHANGE_MANAGER_IP</address>` in your ossec.conf configuration file, the value of this setting can be changed with the value of `WAZUH_MANAGER_SERVER` environment variable. See also: https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/client.html#address
4. If you have `<port>CHANGE_MANAGER_PORT</port>` in your ossec.conf configuration file, the value of this setting can be changed with the value of `WAZUH_MANAGER_PORT` environment variable. See also: https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/client.html#port
5. If you have `<manager_address>CHANGE_ENROLL_IP</manager_address>` in your ossec.conf configuration file, the value of this setting can be changed with the value of `WAZUH_REGISTRATION_SERVER` environment variable. See also: https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/client.html#manager-address
5. If you have `<port>CHANGE_ENROLL_PORT</port>` in your ossec.conf configuration file, the value of this setting can be changed with the value of `WAZUH_REGISTRATION_PORT` environment variable. See also: https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/client.html#enrollment-manager-port
6. If you have `<agent_name>CHANGE_AGENT_NAME</agent_name>` in your ossec.conf configuration file, the value of this setting can be changed with the value of `WAZUH_AGENT_NAME` environment variable. See also: https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/client.html#agent-name
7. If you have `<groups>CHANGE_AGENT_GROUPS</groups>` in your ossec.conf configuration file, the value of this setting can be changed with the value of `WAZUH_AGENT_GROUPS` environment variable. See also: https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/client.html#groups
8. When using passwords as an additional security measure in your wazuh-manager instance, you can use the `WAZUH_REGISTRATION_PASSWORD` environment variable.
9. `/entrypoint-scripts` can contain scripts that are executed in lexicographical order using `/bin/sh`.
