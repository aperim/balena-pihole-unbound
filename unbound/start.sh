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

if [ ! -s "${PRIVATE_ARPA_CONFIG}" ];
then
  PRIVATE_ARPA_CONFIG="04-private-arpa.conf"
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

if [ ! -s "${PRIVATE_ARPA}" ] && [ ! -f "${CONFIG_STORE}/${PRIVATE_ARPA_CONFIG}" ];
then
  STUB_ZONES="10.in-addr.arpa.,16.172.in-addr.arpa.,17.172.in-addr.arpa.,18.172.in-addr.arpa.,19.172.in-addr.arpa.,20.172.in-addr.arpa.,21.172.in-addr.arpa.,22.172.in-addr.arpa.,23.172.in-addr.arpa.,24.172.in-addr.arpa.,25.172.in-addr.arpa.,26.172.in-addr.arpa.,27.172.in-addr.arpa.,28.172.in-addr.arpa.,29.172.in-addr.arpa.,30.172.in-addr.arpa.,31.172.in-addr.arpa.,32.172.in-addr.arpa. ,168.192.in-addr.arpa.,61.10.in-addr.arpa."
  touch "${CONFIG_STORE}/${PRIVATE_ARPA_CONFIG}"
  echo 'c2VydmVyOiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICBsb2NhbC16b25lOiAiMTAuaW4tYWRkci5hcnBhLiIgbm9kZWZhdWx0ICAgIAogICAgICAgIGxvY2FsLXpvbmU6ICIxNi4xNzIuaW4tYWRkci5hcnBhLiIgbm9kZWZhdWx0CiAgICAgICAgbG9jYWwtem9uZTogIjE3LjE3Mi5pbi1hZGRyLmFycGEuIiBub2RlZmF1bHQKICAgICAgICBsb2NhbC16b25lOiAiMTguMTcyLmluLWFkZHIuYXJwYS4iIG5vZGVmYXVsdAogICAgICAgIGxvY2FsLXpvbmU6ICIxOS4xNzIuaW4tYWRkci5hcnBhLiIgbm9kZWZhdWx0CiAgICAgICAgbG9jYWwtem9uZTogIjIwLjE3Mi5pbi1hZGRyLmFycGEuIiBub2RlZmF1bHQKICAgICAgICBsb2NhbC16b25lOiAiMjEuMTcyLmluLWFkZHIuYXJwYS4iIG5vZGVmYXVsdAogICAgICAgIGxvY2FsLXpvbmU6ICIyMi4xNzIuaW4tYWRkci5hcnBhLiIgbm9kZWZhdWx0CiAgICAgICAgbG9jYWwtem9uZTogIjIzLjE3Mi5pbi1hZGRyLmFycGEuIiBub2RlZmF1bHQKICAgICAgICBsb2NhbC16b25lOiAiMjQuMTcyLmluLWFkZHIuYXJwYS4iIG5vZGVmYXVsdAogICAgICAgIGxvY2FsLXpvbmU6ICIyNS4xNzIuaW4tYWRkci5hcnBhLiIgbm9kZWZhdWx0CiAgICAgICAgbG9jYWwtem9uZTogIjI2LjE3Mi5pbi1hZGRyLmFycGEuIiBub2RlZmF1bHQKICAgICAgICBsb2NhbC16b25lOiAiMjcuMTcyLmluLWFkZHIuYXJwYS4iIG5vZGVmYXVsdAogICAgICAgIGxvY2FsLXpvbmU6ICIyOC4xNzIuaW4tYWRkci5hcnBhLiIgbm9kZWZhdWx0CiAgICAgICAgbG9jYWwtem9uZTogIjI5LjE3Mi5pbi1hZGRyLmFycGEuIiBub2RlZmF1bHQKICAgICAgICBsb2NhbC16b25lOiAiMzAuMTcyLmluLWFkZHIuYXJwYS4iIG5vZGVmYXVsdAogICAgICAgIGxvY2FsLXpvbmU6ICIzMS4xNzIuaW4tYWRkci5hcnBhLiIgbm9kZWZhdWx0CiAgICAgICAgbG9jYWwtem9uZTogIjMyLjE3Mi5pbi1hZGRyLmFycGEuIiBub2RlZmF1bHQgCiAgICAgICAgbG9jYWwtem9uZTogIjE2OC4xOTIuaW4tYWRkci5hcnBhLiIgbm9kZWZhdWx0CiAgICAgICAgbG9jYWwtem9uZTogIjYxLjEwLmluLWFkZHIuYXJwYS4iIG5vZGVmYXVsdAogICAgICAgICAgCg==' | base64 -d >> "${CONFIG_STORE}/${PRIVATE_ARPA_CONFIG}"

  for z in $(echo $STUB_ZONES | sed "s/,/ /g")
  do
    STUB_ZONE="$(printf "${z}" | tr -d '[:space:]')"
    printf "stub-zone:\n\tname: \"${STUB_ZONE}\"\n" >> "${CONFIG_STORE}/${PRIVATE_ARPA_CONFIG}"
	  for s in $(echo $PRIVATE_ARPA | sed "s/,/ /g")
	  do
		ARPA_DNS_SERVER="$(printf "${s}" | tr -d '[:space:]')"
		printf "\tstub-host: \"$ARPA_DNS_SERVER\"\n" >> "${CONFIG_STORE}/${PRIVATE_ARPA_CONFIG}"
	  done    
  done

fi

# Start Unbound
exec /opt/unbound/sbin/unbound -ddv -c /opt/unbound/etc/unbound/unbound.conf