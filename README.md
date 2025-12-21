**files/usr/local/etc/pkg/repos/Latest.conf**:

```
FreeBSD: {
  url: "pkg+https://pkg.FreeBSD.org/${ABI}/latest",
  mirror_type: "srv",
  signature_type: "fingerprints",
  fingerprints: "/usr/share/keys/pkg",
  enabled: yes
}
FreeBSD-kmods: {
  enabled: no
}
```

**files/usr/local/etc/pkg/repos/Custom.conf**:

```
Custom: {
  url: "http://pkg.dyn.dc-air.home.arpa:4080/143amd64-local",
  priority: 1,
  enabled: yes
}
```

```sh
mkdir -p .volumes/pkgcache
appjail makejail \
    -j wazuh \
    -f gh+DtxdF/wazuh-makejail \
    -o virtualnet=":<random> address:10.0.0.80 default" \
    -o nat \
    -o copydir="$PWD/files" \
    -o file=/usr/local/etc/pkg/repos/Latest.conf \
    -o file=/usr/local/etc/pkg/repos/Custom.conf \
    -o osversion=14.3-RELEASE \
    -o label="security-group:1" \
    -o label="security-group.rules.allow-pkg-custom:pass on ajnet proto tcp from %i to 100.65.139.52 port 4080" \
    -o fstab="$PWD/.volumes/pkgcache /var/cache/pkg" \
    -- \
    --wazuh_server_ip 10.0.0.80
```
