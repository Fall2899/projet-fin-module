# Guide de Tests et Validation

## Tests réseau à effectuer après déploiement

### Depuis VM2 (Web) vers VM3 (DB)
```bash
# Tester la connectivité MySQL
mysql -h 192.168.10.10 -u webuser -p -e "SELECT 1;"

# Tester le ping (si ICMP autorisé)
ping -c 3 192.168.10.10
```

### Depuis Internet vers VM2 (Web)
```bash
# Tester que le site web répond
curl http://<IP_PUBLIQUE_VM1>

# Tester HTTPS
curl -k https://<IP_PUBLIQUE_VM1>
```

### Vérifier que VM3 est inaccessible depuis Internet
```bash
# Cette commande doit échouer (timeout)
curl --connect-timeout 5 http://192.168.10.10:3306
```

## Commandes OpenShift utiles

```bash
# Voir toutes les VMs
oc get vm -n projet-reseau

# Voir les logs d'une VM
oc get vmi vm1-pfsense -n projet-reseau

# Accéder à la console d'une VM
virtctl console vm1-pfsense -n projet-reseau

# Voir les events
oc get events -n projet-reseau --sort-by='.lastTimestamp'
```
