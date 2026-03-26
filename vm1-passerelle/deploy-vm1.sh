#!/bin/bash
# ============================================================
# deploy-vm1.sh — Déploiement complet VM1 pfSense
# Exécuter depuis la racine du dépôt GitHub
# Prérequis : oc login effectué
# ============================================================

set -e  # arrêter si une commande échoue

NAMESPACE="projet-reseau"

echo "==> Vérification connexion OpenShift..."
oc whoami || { echo "ERREUR : tu n'es pas connecté à OpenShift. Lance 'oc login' d'abord."; exit 1; }

echo "==> Création du namespace si inexistant..."
oc get namespace $NAMESPACE 2>/dev/null || oc create namespace $NAMESPACE

echo "==> Passage sur le namespace..."
oc project $NAMESPACE

echo "==> Déploiement des réseaux LAN et DMZ..."
oc apply -f reseau/nad-lan.yaml
oc apply -f reseau/nad-dmz.yaml

echo "==> Déploiement du DataVolume pfSense (téléchargement ISO)..."
oc apply -f vm1-passerelle/vm1-pfsense-datavolume.yaml

echo "==> Attente du téléchargement de l'ISO (peut prendre plusieurs minutes)..."
oc wait datavolume/pfsense-dv \
  --for=condition=Ready \
  --timeout=600s \
  -n $NAMESPACE

echo "==> Déploiement de la VirtualMachine VM1..."
oc apply -f vm1-passerelle/vm1-pfsense.yaml

echo "==> Déploiement du Service et de la Route..."
oc apply -f vm1-passerelle/vm1-pfsense-service.yaml

echo "==> Attente du démarrage de la VM (30 secondes)..."
sleep 30

echo "==> Statut de la VM :"
oc get vm vm1-pfsense -n $NAMESPACE

echo "==> URL d'accès à l'interface pfSense :"
oc get route vm1-pfsense-ui-route -n $NAMESPACE -o jsonpath='{.spec.host}'
echo ""

echo "✓ VM1 pfSense déployée avec succès !"
echo ""
echo "Prochaines étapes :"
echo "  1. Accède à l'interface pfSense via l'URL ci-dessus"
echo "  2. Identifiants par défaut : admin / pfsense"
echo "  3. Configure les interfaces : WAN=vtnet0, LAN=vtnet1, DMZ=vtnet2"
echo "  4. Active le NAT sur l'interface WAN"
echo "  5. Crée les règles firewall LAN→DMZ"
