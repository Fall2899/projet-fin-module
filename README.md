# Projet Fin de Module — Architecture Réseau 3-Tiers sur OpenShift

## Architecture finale

| VM | Rôle | Technologie | OS | Réseau |
|----|------|-------------|-----|--------|
| VM1 | Firewall / Passerelle | VirtualMachine KubeVirt | pfSense CE 2.7 (FreeBSD) | WAN + LAN + DMZ |
| VM2 | Serveur Web | Deployment conteneur | nginx:1.25 + node:18 (Alpine) | DMZ — 192.168.100.10 |
| VM3 | Base de données | VirtualMachine KubeVirt | Fedora Cloud 39 + MySQL 8.0 | LAN — 192.168.10.10 |

> VM2 est un conteneur (et non une VM) pour optimiser les ressources du trial OpenShift.
> VM3 utilise Fedora Cloud 39, plus compatible avec l'écosystème Red Hat / OpenShift.

## Topologie réseau

```
Internet
    |
[ VM1 pfSense ] — WAN (DHCP pod OpenShift)
    |          |
    |   LAN 192.168.10.0/24      DMZ 192.168.100.0/24
    |          |                         |
    |   [ VM3 MySQL ]           [ VM2 Nginx+Node.js ]
    |   192.168.10.10           192.168.100.10
    |          ^                         |
    |          └─────────────────────────┘
    |                 port 3306 (webuser uniquement)
```

## Structure du dépôT
Le projet est maintenant complet avec **17 fichiers** :
```
projet-fin-module/
├── deploy-all.sh                         ← déploiement global
├── .github/workflows/deploy.yml          ← CI/CD GitHub Actions
├── .gitignore
├── README.md
├── reseau/
│   ├── nad-lan.yaml
│   └── nad-dmz.yaml
├── vm1-passerelle/
│   ├── deploy-vm1.sh
│   ├── vm1-pfsense.yaml
│   ├── vm1-pfsense-datavolume.yaml
│   └── vm1-pfsense-service.yaml
├── vm2-web/
│   ├── deploy-vm2.sh
│   ├── vm2-deployment.yaml
│   └── vm2-service-route.yaml
└── vm3-db/
    ├── deploy-vm3.sh
    ├── vm3-db.yaml
    └── vm3-datavolume.yaml

## Secret à modifier avant déploiement

Dans `vm2-web/vm2-deployment.yaml` et `vm3-db/vm3-db.yaml`,
remplacer **`ChangeMe2024!`** par le même mot de passe dans les deux fichiers.

## Secrets GitHub Actions à configurer

Settings → Secrets and variables → Actions → New repository secret

| Nom | Valeur |
|-----|--------|
| `OC_SERVER` | `https://api.<cluster>:6443` |
| `OC_TOKEN` | résultat de `oc whoami -t` |
| `OC_NAMESPACE` | `projet-reseau` |
