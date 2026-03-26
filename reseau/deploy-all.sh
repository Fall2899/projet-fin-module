#!/bin/bash
# ============================================================
# deploy-all.sh — Déploiement complet du projet en une commande
# Ordre : réseaux → VM1 → VM3 → VM2
# Prérequis : oc login effectué
# ============================================================
set -e

NAMESPACE="projet-reseau"

echo "======================================="
echo "   DÉPLOIEMENT PROJET FIN DE MODULE"
echo "======================================="
echo ""

echo "==> Vérification connexion OpenShift..."
oc whoami || { echo "ERREUR : lance 'oc login' d'abord."; exit 1; }

echo "==> Création du namespace..."
oc get namespace $NAMESPACE 2>/dev/null || oc new-project $NAMESPACE
oc project $NAMESPACE

# ── Étape 1 : Réseaux ──────────────────────────────────────
echo ""
echo "[1/4] Réseaux LAN + DMZ..."
oc apply -f reseau/nad-lan.yaml
oc apply -f reseau/nad-dmz.yaml
echo "✓ Réseaux appliqués"

# ── Étape 2 : VM1 pfSense ──────────────────────────────────
echo ""
echo "[2/4] VM1 — pfSense (VirtualMachine KubeVirt)..."
oc apply -f vm1-passerelle/vm1-pfsense-datavolume.yaml
oc apply -f vm1-passerelle/vm1-pfsense.yaml
oc apply -f vm1-passerelle/vm1-pfsense-service.yaml
echo "✓ VM1 appliquée (démarrage en arrière-plan)"

# ── Étape 3 : VM3 MySQL Fedora ─────────────────────────────
echo ""
echo "[3/4] VM3 — MySQL Fedora 39 (VirtualMachine KubeVirt)..."
oc apply -f vm3-db/vm3-datavolume.yaml
oc apply -f vm3-db/vm3-db.yaml
echo "✓ VM3 appliquée (cloud-init MySQL en arrière-plan)"

# ── Étape 4 : VM2 conteneur ────────────────────────────────
echo ""
echo "[4/4] VM2 — Nginx + Node.js (Deployment conteneur)..."
oc apply -f vm2-web/vm2-deployment.yaml
oc apply -f vm2-web/vm2-service-route.yaml

echo "==> Attente que le pod VM2 soit Running..."
oc rollout status deployment/vm2-web \
  -n $NAMESPACE \
  --timeout=120s
echo "✓ VM2 pod Running"

# ── Résumé ─────────────────────────────────────────────────
echo ""
echo "======================================="
echo "         RÉSUMÉ DÉPLOIEMENT"
echo "======================================="
echo ""
echo "── VirtualMachines ──"
oc get vm -n $NAMESPACE

echo ""
echo "── Pod VM2 ──"
oc get pods -n $NAMESPACE -l app=vm2-web

echo ""
echo "── Routes exposées ──"
oc get routes -n $NAMESPACE

echo ""
echo "── URLs publiques ──"
URL_VM2=$(oc get route vm2-web-route -n $NAMESPACE \
  -o jsonpath='https://{.spec.host}' 2>/dev/null || echo "non disponible")
URL_PF=$(oc get route vm1-pfsense-ui-route -n $NAMESPACE \
  -o jsonpath='https://{.spec.host}' 2>/dev/null || echo "non disponible")

echo "  VM2 (site web)    : $URL_VM2"
echo "  VM1 (pfSense UI)  : $URL_PF"
echo ""
echo "======================================="
echo "✓ Déploiement complet terminé !"
echo "======================================="
echo ""
echo "Note : VM1 et VM3 continuent leur démarrage en arrière-plan."
echo "VM3 cloud-init (MySQL) prend 3-5 minutes supplémentaires."
echo "Surveiller avec : oc get vm -n $NAMESPACE -w"
