#!/bin/sh

chmod 770 /var/ossec/etc
chown wazuh:wazuh /var/ossec/etc
chmod 640 /var/ossec/etc/authd.pass
chown root:wazuh /var/ossec/etc/authd.pass
chmod 660 /var/ossec/etc/ossec.conf
chown root:wazuh /var/ossec/etc/ossec.conf
chown wazuh:wazuh /var/ossec/etc/rules/serpico_rules.xml
chmod 660 /var/ossec/etc/rules/serpico_rules.xml
