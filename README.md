
# Balena Cloud PiHole + Unbound

Private DNS with privacy and advertisment blocking - built for Balena hosted devices.
## What is this?
This work brings together three great tools. [balenaCloud](https://balena-cloud.com) for managing devices (think Raspberry Pi's etc), [Unbound](https://www.nlnetlabs.nl/projects/unbound/about/) (recursive DNS resolver) and [PiHole](https://pi-hole.net/) (advertising and privacy at a network level).
## Why
PiHole is great, but it's even greater with Unbound.
Not having to manage releases across a bunch of devices is great also!
## Danger

## Getting Started
This is as simple as it can be. It is assumed that you know how to get around Balena Cloud's interface, how to create an application and how to provision devices.
If you don't - [start here](https://www.balena.io/os/docs/raspberrypi4-64/getting-started/) and come back to visit once you [grok](https://en.wikipedia.org/wiki/Grok) that.
## Installation
 1. Create the application in the [balena Cloud dashboard](https://dashboard.balena-cloud.com/apps)
 3. Clone this repository
```bash
 git clone https://github.com/aperim/balena-pihole-unbound.git
 ```
4. Add the balena remote via git (hint - it's in the [top right corner](https://www.balena.io/docs/learn/deploy/deployment/#git-push) of the dashboard)
```bash
git remote add balena <USERNAME>@git.balena-cloud.com:<USERNAME>/<APPLICATION_NAME>.git
```
5. Push it to Balena
```bash
git push balena master
```
6. There will now be two services in the dashboard. One is `unbound` the other is `pihole`. Those services can be configured with environment variables (service variables)
## Configuration
### PiHole
The `pihole` service takes all the standard [environment variables](https://hub.docker.com/r/pihole/pihole/). You should configure:
|Variable Name|Example Content  |
|--|--|
|`TZ`|`Australia/Sydney`  |
| `WEBPASSWORD` | `sUp3r_s#crET!` |

**NOTE**: You don't need to override the settings of the other variables. Setting more than the above could break things.
### Unbound
Unbound will operate with no configuration. This typically won't suit most environments where domains used locally may need to return private IP addresses. This can be managed with `PRIVATE_DOMAINS` (example below).
The IP restriction only applies to Unbound - it does not change how PiHole answeres queries. This should not normally need to be changed as Unbound is operating on a non standard (`5353`) port. Add IP's here only if you know what you are doing, and need access to the recursive DNS server from elsewhere.

| First Header  | Second Header |
| ------------- | ------------- |
| Content Cell  | Content Cell  |
| Content Cell  | Content Cell  |

|Variable Name|Use|Example|Default|
|--|--|--|--|
|`IP_ACCESS_CONTROL`|Comma separated list of IP addresses permitted to access the DNS server. |`127.0.0.1/32,::1/128,192.168.100.0/24`|`127.0.0.1/32,::1/128`
| `PRIVATE_DOMAINS` | Comma separated list of domains that can return [RFC1918](https://tools.ietf.org/html/rfc1918) and [RFC4193](https://tools.ietf.org/html/rfc4193) private IP addresses | `example.com,example.org`|[NONE]

## Operation
Once you have started the services of your application - you should be able to send DNS queries to the IPv4 or IPv6 address of your device. You can test be using [dig](https://linux.die.net/man/1/dig) and supplying your devices IP address. For example, if I was using a RaspberryPi and it had the address `192.168.100.100` I would check it was working with:
```bash
| => dig A aperim.com @192.168.100.100

; <<>> DiG 9.10.6 <<>> A aperim.com @192.168.100.100
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 55235
;; flags: qr rd ra; QUERY: 1, ANSWER: 4, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1472
;; QUESTION SECTION:
;aperim.com.			IN	A

;; ANSWER SECTION:
aperim.com.		1800	IN	A	198.185.159.144
aperim.com.		1800	IN	A	198.185.159.145
aperim.com.		1800	IN	A	198.49.23.144
aperim.com.		1800	IN	A	198.49.23.145

;; Query time: 232 msec
;; SERVER: 192.168.100.100#53(192.168.100.100)
;; WHEN: Mon Sep 30 14:07:32 AEST 2019
;; MSG SIZE  rcvd: 103
```
## Next Steps
You now need to configure the devices on your network to use your new DNS server.
A great place to start is the [PiHole documentation](https://docs.pi-hole.net/main/post-install/).
