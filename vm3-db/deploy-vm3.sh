#!/bin/bash
# ============================================================
# deploy-vm3.sh — Déploiement VM3 MySQL (Fedora Cloud 39)
# Prérequis : oc login effectué + namespace projet-reseau créé
# ============================================================
set -e

NAMESPACE="projet-reseau"

echo "==> Vérification connexion OpenShift..."
oc whoami || { echo "ERREUR : lance 'oc login' d'abord."; exit 1; }
oc project $NAMESPACE

echo "==> Déploiement DataVolume Fedora Cloud 39..."
oc apply -f vm3-db/vm3-datavolume.yaml

echo "==> Attente du téléchargement image Fedora (peut prendre 5-10 min)..."
oc wait datavolume/vm3-fedora-dv \
  --for=condition=Ready \
  --timeout=600s \
  -n $NAMESPACE

echo "==> Déploiement VirtualMachine VM3..."
oc apply -f vm3-db/vm3-db.yaml

echo "==> Attente démarrage VM + cloud-init MySQL (3-5 min)..."
sleep 30

echo ""
echo "==> Statut VM3 :"
oc get vm vm3-db -n $NAMESPACE

echo ""
echo "✓ VM3 Fedora MySQL déployée !"
echo ""
echo "  Accéder à la console VM3 :"
echo "    virtctl console vm3-db -n $NAMESPACE"
echo ""
echo "  Vérifier les logs cloud-init depuis la console :"
echo "    cat /var/log/cloud-init-output.log"
echo "    cat /var/log/cloud-init-projet.log"
echo ""
echo "  Tester MySQL depuis VM2 :"
echo "    mysql -h 192.168.10.10 -u webuser -p'ChangeMe2024!' appdb"
