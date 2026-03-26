# Topologie Réseau

## Sous-réseaux

| Réseau | Plage IP | VLAN | Usage |
|--------|----------|------|-------|
| LAN | 192.168.10.0/24 | 10 | VM1 (eth1) + VM3 (eth0) |
| DMZ | 192.168.100.0/24 | 100 | VM1 (eth2) + VM2 (eth0) |
| WAN | DHCP OpenShift | — | VM1 (eth0) — accès Internet |

## Adresses IP fixes

| VM | Interface | Adresse IP |
|----|-----------|------------|
| VM1 pfSense | WAN (eth0) | DHCP (pod network) |
| VM1 pfSense | LAN (eth1) | 192.168.10.1 |
| VM1 pfSense | DMZ (eth2) | 192.168.100.1 |
| VM2 Web | DMZ (eth0) | 192.168.100.10 |
| VM3 DB | LAN (eth0) | 192.168.10.10 |

## Règles Firewall pfSense

| Source | Destination | Port | Action |
|--------|-------------|------|--------|
| Internet | VM2 (DMZ) | 80, 443 | ALLOW |
| VM2 (DMZ) | VM3 (LAN) | 3306 | ALLOW |
| Internet | VM3 (LAN) | * | BLOCK |
| LAN | Internet | * | ALLOW (NAT) |
| DMZ | Internet | * | BLOCK |
