-- ============================================================
-- init.sql — Initialisation MySQL pour VM3
-- Cohérent avec les credentials définis dans VM2 (Secret db-credentials)
--   DB_HOST : 192.168.10.10
--   DB_USER : webuser
--   DB_NAME : appdb
--   DB_PASS : ChangeMe2024!  ← à changer aussi dans vm2-deployment.yaml
-- ============================================================

-- Sécuriser le compte root : interdire connexion distante
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'RootSecure2024!';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Supprimer les comptes anonymes
DELETE FROM mysql.user WHERE User='';

-- Supprimer la base de test
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Créer la base de données de l'application
CREATE DATABASE IF NOT EXISTS appdb
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- Créer l'utilisateur pour VM2 (Nginx + Node.js)
-- Accessible UNIQUEMENT depuis l'IP de VM2 dans la DMZ
CREATE USER IF NOT EXISTS 'webuser'@'192.168.100.10'
  IDENTIFIED WITH mysql_native_password
  BY 'ChangeMe2024!';

-- Droits limités : SELECT, INSERT, UPDATE, DELETE uniquement sur appdb
GRANT SELECT, INSERT, UPDATE, DELETE
  ON appdb.*
  TO 'webuser'@'192.168.100.10';

-- Appliquer les changements
FLUSH PRIVILEGES;

-- ============================================================
-- Schéma de démonstration
-- ============================================================
USE appdb;

CREATE TABLE IF NOT EXISTS utilisateurs (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  nom        VARCHAR(100)  NOT NULL,
  email      VARCHAR(150)  NOT NULL UNIQUE,
  created_at TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS logs_acces (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  ip_source  VARCHAR(45)   NOT NULL,
  action     VARCHAR(100)  NOT NULL,
  created_at TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Données de test
INSERT INTO utilisateurs (nom, email) VALUES
  ('Admin Projet', 'admin@projet-reseau.local'),
  ('Test User',    'test@projet-reseau.local');

INSERT INTO logs_acces (ip_source, action) VALUES
  ('192.168.100.10', 'Connexion initiale depuis VM2');

-- Vérification finale
SELECT 'Base appdb initialisee avec succes' AS statut;
SELECT User, Host FROM mysql.user WHERE User = 'webuser';
