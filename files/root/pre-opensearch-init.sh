#!/bin/sh

logstash_output_opensearch_ver=2.0.3

echo " "
echo -e "\e[1;37m Installing logstash-output-opensearch plugin ...\e[0m"
echo " "

fetch -qo "/tmp/logstash-output-opensearch-${logstash_output_opensearch_ver}.tar.gz" "https://github.com/opensearch-project/logstash-output-opensearch/releases/download/${logstash_output_opensearch_ver}/artifacts.tar.gz" || exit $?
mkdir -p "/tmp/logstash-output-opensearch-${logstash_output_opensearch_ver}" || exit $?
tar -C "/tmp/logstash-output-opensearch-${logstash_output_opensearch_ver}" -xf /tmp/logstash-output-opensearch-${logstash_output_opensearch_ver}.tar.gz || exit $?

cd /usr/local/logstash/bin; sh -c "DEBUG=1 JAVA_HOME=/usr/local/openjdk17 ./logstash-plugin install /tmp/logstash-output-opensearch-${logstash_output_opensearch_ver}/dist/logstash-output-opensearch-${logstash_output_opensearch_ver}-java.gem" || exit $?

rm -rf "/tmp/logstash-output-opensearch-${logstash_output_opensearch_ver}"
rm -f "/tmp/logstash-output-opensearch-${logstash_output_opensearch_ver}.tar.gz"

echo " "
echo -e "\e[1;37m Copy opensearch config sample files ...\e[0m"
echo " "

cd /usr/local/etc/opensearch/opensearch-security; sh -c 'for i in $(ls *.sample ) ; do cp -p ${i} $(echo ${i} | sed "s|.sample||g") ; done' || exit $?
