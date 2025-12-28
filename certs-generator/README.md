# wazuh-certs-generator (Makejail)

This Makejail aims to implement the logic implemented in the [certs-generator](https://hub.docker.com/layers/wazuh/wazuh-certs-generator) Docker image. Interestingly, the Dockerfile and related stuff (such as the `entrypoint.sh` script) were not easy to retrieve, as they do not appear to be in the [wazuh-docker](https://github.com/wazuh/wazuh-docker) repository. Therefore, for the Dockerfile, I simply read the [image build instructions](https://hub.docker.com/layers/wazuh/wazuh-certs-generator/0.0.4/images/sha256-f3d041b595cf895fcd9395a24d6cf8bbcbd42573e50e3807d3e77ce147596d37), and for `entrypoint.sh`, I extracted it from the container and then modified it slightly to work seamlessly with FreeBSD.

```console
# appjail-director up                                                                          
Starting Director (project:wazuh-certs-generator) ...                                                                                                          
Stopping generator (wazuh-certs-generator) ... Done.                                                                                                           
Destroying generator (wazuh-certs-generator) ... Done.                                                                                                         
Creating generator (wazuh-certs-generator) ... Done.                                                                                                           
Finished: wazuh-certs-generator
# appjail-director info
wazuh-certs-generator:                                                         
 state: DONE                                                                   
 last log: /root/.director/logs/2025-12-28_13h14m18s                  
 locked: false                                                                 
 services:                                                                     
  + generator (wazuh-certs-generator)
# ls -l user-files/certs/*
-r--------  1 855 855 1704 28 dic.  13:16 user-files/certs/admin-key.pem
-r--------  1 855 855 1220 28 dic.  13:16 user-files/certs/admin.pem
-r--------  1 309 309 1704 28 dic.  13:16 user-files/certs/root-ca-manager.key
-r--------  1 309 309 1204 28 dic.  13:16 user-files/certs/root-ca-manager.pem
-r--------  1 855 855 1704 28 dic.  13:16 user-files/certs/root-ca.key
-r--------  1 855 855 1204 28 dic.  13:16 user-files/certs/root-ca.pem
-r--------  1 309 309 1704 28 dic.  13:16 user-files/certs/wazuh-key.pem
-r--------  1 309 309 1273 28 dic.  13:16 user-files/certs/wazuh.pem
# appjail-director down -d
Starting Director (project:wazuh-certs-generator) ...
Stopping generator (wazuh-certs-generator) ... Done.
Destroying generator (wazuh-certs-generator) ... Done.
Destroying wazuh-certs-generator ... Done.
```

As you may have noticed, the mode, UID, and GID have already been modified. `855` corresponds to opensearch and `309` to wazuh. Check the UIDs and GIDs in your port tree for more details.
