#!/bin/bash
# ============================================================
# deploy-vm2.sh — Déploiement VM2 (conteneur OpenShift)
# Nginx + Node.js en Deployment (pas une VirtualMachine)
# ============================================================

set -e

NAMESPACE="projet-reseau"

echo "==> Vérification connexion OpenShift..."
oc whoami || { echo "ERREUR : lance 'oc login' d'abord."; exit 1; }
oc project $NAMESPACE

echo "==> Déploiement ConfigMaps, Secret, Deployment..."
oc apply -f vm2-web/vm2-deployment.yaml

echo "==> Déploiement Service et Route..."
oc apply -f vm2-web/vm2-service-route.yaml

echo "==> Attente du démarrage du pod..."
oc rollout status deployment/vm2-web -n $NAMESPACE --timeout=120s

echo "==> URL publique du serveur web :"
oc get route vm2-web-route -n $NAMESPACE -o jsonpath='{.spec.host}'
echo ""

echo "✓ VM2 (conteneur) déployée avec succès !"
echo ""
echo "Teste avec : curl https://\$(oc get route vm2-web-route -n $NAMESPACE -o jsonpath='{.spec.host}')"
