#!/bin/bash
# ============================================================
# deploy-vm2.sh — Déploiement VM2 (Deployment conteneur)
# Nginx:1.25-alpine + Node:18-alpine dans le même pod
# Prérequis : oc login effectué + namespace projet-reseau créé
# ============================================================
set -e

NAMESPACE="projet-reseau"

echo "==> Vérification connexion OpenShift..."
oc whoami || { echo "ERREUR : lance 'oc login' d'abord."; exit 1; }
oc project $NAMESPACE

echo "==> Déploiement ConfigMaps + Secret + Deployment..."
oc apply -f vm2-web/vm2-deployment.yaml

echo "==> Déploiement Service + Route..."
oc apply -f vm2-web/vm2-service-route.yaml

echo "==> Attente que le pod soit Running..."
oc rollout status deployment/vm2-web \
  -n $NAMESPACE \
  --timeout=120s

echo ""
echo "==> Statut pod VM2 :"
oc get pods -n $NAMESPACE -l app=vm2-web

echo ""
echo "==> URL publique VM2 :"
oc get route vm2-web-route -n $NAMESPACE \
  -o jsonpath='https://{.spec.host}'
echo ""
echo ""
echo "✓ VM2 conteneur déployée !"
echo "  Tester : curl https://\$(oc get route vm2-web-route -n $NAMESPACE -o jsonpath='{.spec.host}')/api/status"
