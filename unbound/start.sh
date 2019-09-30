#!/usr/bin/env ash

mkdir -p /opt/unbound/etc/unbound/dev 2>/dev/null
cp -a /dev/random /dev/urandom /opt/unbound/etc/unbound/dev/

mkdir -p -m 700 /opt/unbound/etc/unbound/var 2>/dev/null
chown _unbound:_unbound /opt/unbound/etc/unbound/var

# update the root trust anchor for DNSSEC validation
/opt/unbound/sbin/unbound-anchor -a /opt/unbound/etc/unbound/var/root.key

# Add deafult values
if [ ! -s "${CONFIG_STORE}" ];
then
  CONFIG_STORE="/opt/unbound/etc/unbound/unbound.conf.d"
fi

if [ ! -s "${IP_ACCESS_CONTROL}" ];
then
  IP_ACCESS_CONTROL="127.0.0.1/32,::1/128"
fi

if [ ! -s "${PIHOLE_CONFIG}" ];
then
  PIHOLE_CONFIG="pi-hole.conf"
fi

if [ ! -s "${ACCESS_CONTROL_CONFIG}" ];
then
  ACCESS_CONTROL_CONFIG="02-access-control.conf"
fi

if [ ! -s "${PRIVATE_DOMAIN_CONFIG}" ];
then
  PRIVATE_DOMAIN_CONFIG="03-private-domains.conf"
fi

# restore the default config files if they do not exist
if [ ! -f /opt/unbound/etc/unbound/unbound.conf ]
then
    cp -av /unbound.conf /opt/unbound/etc/
fi

if [ ! -f "${CONFIG_STORE}/${PIHOLE_CONFIG}" ]
then
    mkdir -p "${CONFIG_STORE}"  2>/dev/null
    cp -av /pi-hole.conf "${CONFIG_STORE}/${PIHOLE_CONFIG}"
fi

if [ ! -s "${IP_ACCESS_CONTROL}" ] && [ ! -f "${CONFIG_STORE}/${ACCESS_CONTROL_CONFIG}" ];
then
  touch "${CONFIG_STORE}/${ACCESS_CONTROL_CONFIG}"
  echo 'IyBJUCBBZGRyZXNzZXMgdGhhdCBhcmUgcGVybWl0dGVkIHRvIGFjY2VzcyB0aGlzIHNlcnZlcgojIENyZWF0ZWQgYXV0b21hdGljYWxseSBmcm9tIHRoZSBJUF9BQ0NFU1NfQ09OVFJPTCBlbnYgdmFyaWFibGUKIyBTdXBwbHkgYSBjb21tYSBzZXBhcmF0ZWQgbGlzdCBlZyAxMjcuMC4wLjEsMTAuMC4wLjAvOApzZXJ2ZXI6CiAgICAjIEFsbG93ZWQgSVAgYWRkcmVzc2VzCg==' | base64 -d >> "${CONFIG_STORE}/${ACCESS_CONTROL_CONFIG}"

  for s in $(echo $IP_ACCESS_CONTROL | sed "s/,/ /g")
  do
    IP_ADDRESS="$(printf "${s}" | tr -d '[:space:]')"
    printf "    access-control: \"$IP_ADDRESS\" allow\n" >> "${CONFIG_STORE}/${ACCESS_CONTROL_CONFIG}"
  done

fi

if [ ! -s "${PRIVATE_DOMAINS}" ] && [ ! -f "${CONFIG_STORE}/${PRIVATE_DOMAIN_CONFIG}" ];
then
  touch "${CONFIG_STORE}/${PRIVATE_DOMAIN_CONFIG}"
  echo 'IyBEb21haW5zIHRoYXQgYXJlIHBlcm1pdHRlZCB0byByZXR1cm4gYSBsb2NhbCBJUCBhZGRyZXNzCiMgQ3JlYXRlZCBhdXRvbWF0aWNhbGx5IGZyb20gdGhlIFBSSVZBVEVfRE9NQUlOUyBlbnYgdmFyaWFibGUKIyBTdXBwbHkgYSBjb21tYSBzZXBhcmF0ZWQgbGlzdCBlZyBleGFtcGxlLmNvbSxhbm90aGVyLWV4YW1wbGUuY29tCnNlcnZlcjoKICAgICMgUHJpdmF0ZSBEb21haW5zCg==' | base64 -d >> "${CONFIG_STORE}/${PRIVATE_DOMAIN_CONFIG}"

  for s in $(echo $PRIVATE_DOMAINS | sed "s/,/ /g")
  do
    DOMAIN_NAME="$(printf "${s}" | tr -d '[:space:]')"
    printf "    private-domain: \"$DOMAIN_NAME\"\n" >> "${CONFIG_STORE}/${PRIVATE_DOMAIN_CONFIG}"
  done

fi

# Start Unbound
exec /opt/unbound/sbin/unbound -ddv -c /opt/unbound/etc/unbound/unbound.conf
