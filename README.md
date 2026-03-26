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

## Structure du dépôt

```
projet-fin-module/
├── .github/workflows/deploy.yml   ← CI/CD complet GitHub Actions
├── reseau/
│   ├── nad-lan.yaml               ← LAN 192.168.10.0/24
│   └── nad-dmz.yaml               ← DMZ 192.168.100.0/24
├── vm1-passerelle/
│   ├── vm1-pfsense.yaml           ← VirtualMachine pfSense
│   ├── vm1-pfsense-datavolume.yaml
│   └── vm1-pfsense-service.yaml   ← Route vers UI pfSense
├── vm2-web/
│   ├── vm2-deployment.yaml        ← Deployment Nginx + Node.js
│   └── vm2-service-route.yaml     ← Route HTTPS publique
├── vm3-db/
│   ├── vm3-db.yaml                ← VirtualMachine Fedora 39 + MySQL
│   └── vm3-datavolume.yaml        ← Image Fedora Cloud qcow2
├── .gitignore
└── README.md
```

## Déploiement

```bash
# 1. Cloner
git clone https://github.com/TON_USERNAME/projet-fin-module.git
cd projet-fin-module

# 2. Connexion OpenShift
oc login --token=<TOKEN> --server=<URL_CLUSTER>
oc new-project projet-reseau

# 3. Déployer (ou laisser GitHub Actions le faire automatiquement)
oc apply -f reseau/
oc apply -f vm1-passerelle/
oc apply -f vm3-db/
oc apply -f vm2-web/
oc rollout status deployment/vm2-web -n projet-reseau
```

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
