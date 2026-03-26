# Projet de Fin de Module — Architecture Réseau 3-Tiers Virtualisée

Déploiement d'une infrastructure réseau multi-VM sur **OpenShift Virtualization (KubeVirt)**,
reproduisant un environnement d'entreprise avec segmentation LAN/DMZ sécurisée.

## Architecture

```
Internet (NAT)
      |
  [ VM1 — pfSense ]  ← Passerelle / Firewall
      |           |
  LAN (10.0/24)  DMZ (100.0/24)
      |               |
  [ VM3 — MySQL ]  [ VM2 — Nginx + Node.js ]
```

| VM | Rôle | OS | Réseau |
|----|------|----|--------|
| VM1 | Passerelle / Firewall | pfSense CE 2.7 | WAN + LAN + DMZ |
| VM2 | Serveur Web | Ubuntu 22.04 LTS | DMZ (192.168.100.0/24) |
| VM3 | Serveur Base de données | Ubuntu 22.04 LTS | LAN (192.168.10.0/24) |

## Structure du dépôt

```
projet-fin-module/
├── vm1-passerelle/          # VM1 pfSense — Firewall/Gateway
│   ├── vm1-pfsense.yaml
│   ├── vm1-pfsense-datavolume.yaml
│   ├── vm1-pfsense-service.yaml
│   └── deploy-vm1.sh
├── vm2-web/                 # VM2 Ubuntu — Nginx + Node.js
│   ├── vm2-web.yaml
│   ├── cloud-init-vm2.yaml
│   ├── vm2-service.yaml
│   └── deploy-vm2.sh
├── vm3-db/                  # VM3 Ubuntu — MySQL
│   ├── vm3-db.yaml
│   ├── cloud-init-vm3.yaml
│   ├── init.sql
│   └── deploy-vm3.sh
├── reseau/                  # Réseaux OpenShift
│   ├── nad-lan.yaml
│   ├── nad-dmz.yaml
│   └── topology.md
├── docs/                    # Documentation
│   ├── guide-installation.md
│   └── tests-validation.md
├── .github/
│   └── workflows/
│       └── deploy.yml       # CI/CD GitHub Actions
├── .gitignore
└── README.md
```

## Prérequis

- Compte Red Hat avec trial OpenShift 60 jours (console.redhat.com)
- `oc` CLI installé et configuré
- `git` installé

## Déploiement rapide

```bash
# 1. Cloner le dépôt
git clone https://github.com/TON_USERNAME/projet-fin-module.git
cd projet-fin-module

# 2. Se connecter à OpenShift
oc login --token=<TOKEN> --server=<CLUSTER_URL>

# 3. Déployer dans l'ordre
bash vm1-passerelle/deploy-vm1.sh
bash vm2-web/deploy-vm2.sh
bash vm3-db/deploy-vm3.sh
```

## Parties du projet

- **Partie 1** : Virtualisation — définition des VMs en YAML KubeVirt
- **Partie 2** : Déploiement des services — pfSense, Nginx, Node.js, MySQL
- **Partie 3** : Réseaux — LAN/DMZ via NetworkAttachmentDefinition
- **Partie 4** : Intégration GitHub — CI/CD avec GitHub Actions
