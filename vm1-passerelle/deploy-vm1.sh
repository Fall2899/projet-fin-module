#!/bin/bash
# ============================================================
# deploy-vm1.sh — Déploiement VM1 pfSense
# Prérequis : oc login effectué + namespace projet-reseau créé
# ============================================================
set -e

NAMESPACE="projet-reseau"

echo "==> Vérification connexion OpenShift..."
oc whoami || { echo "ERREUR : lance 'oc login' d'abord."; exit 1; }
oc project $NAMESPACE

echo "==> Déploiement des réseaux LAN et DMZ..."
oc apply -f reseau/nad-lan.yaml
oc apply -f reseau/nad-dmz.yaml

echo "==> Déploiement du DataVolume pfSense (téléchargement ISO)..."
oc apply -f vm1-passerelle/vm1-pfsense-datavolume.yaml

echo "==> Attente du téléchargement (peut prendre 5-10 min)..."
oc wait datavolume/pfsense-dv \
  --for=condition=Ready \
  --timeout=600s \
  -n $NAMESPACE

echo "==> Déploiement de la VirtualMachine VM1..."
oc apply -f vm1-passerelle/vm1-pfsense.yaml

echo "==> Déploiement Service + Route pfSense UI..."
oc apply -f vm1-passerelle/vm1-pfsense-service.yaml

echo ""
echo "==> Statut VM1 :"
oc get vm vm1-pfsense -n $NAMESPACE

echo ""
echo "==> URL interface pfSense :"
oc get route vm1-pfsense-ui-route -n $NAMESPACE \
  -o jsonpath='https://{.spec.host}'
echo ""
echo ""
echo "✓ VM1 pfSense déployée !"
echo "  Identifiants par défaut : admin / pfsense"
echo "  Interfaces : vtnet0=WAN  vtnet1=LAN(10.1)  vtnet2=DMZ(100.1)"
