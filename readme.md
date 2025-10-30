# FarmOS Projekt - Lokale Installation

Dieses Repository enthält eine lokale FarmOS-Installation. Dieses README erklärt, wie man das Projekt lokal einrichtet und startet.

---

## Voraussetzungen

Stelle sicher, dass folgende Software installiert ist:

- [Docker](https://www.docker.com/get-started) & [Docker Compose](https://docs.docker.com/compose/)
- Git
- PHP (optional, falls du lokal Tests außerhalb von Docker machen willst)
- Composer (optional, falls du PHP-Abhängigkeiten manuell installieren willst)

---

## Projektstruktur

```
farmos/
├─ config/                # Konfigurationen (Datenbank, Services, etc.)
├─ db-init/               # Datenbank-Initialisierungsskripte
├─ docker-compose.yml     # Docker-Setup
├─ php.ini                # PHP-Konfiguration
├─ private/               # Private Dateien (nicht versioniert)
├─ restore.sh             # Backup Restore Script
├─ setup-cron.sh          # Cronjob Setup Script
├─ sites/                 # Drupal Sites
│  ├─ default/            # Standard FarmOS Site
│  └─ example.*           # Beispiel-Dateien (ignoriert durch Git)
├─ status.sh              # Health-Check / Status Script
└─ DEPLOYMENT.md          # Deployment Hinweise
```

---

## 1. Repository klonen

```bash
git clone git@github.com:whispers2011/AGRIMO.git farmos
cd farmos
```

---

## 2. Umgebungsvariablen einrichten

Erstelle eine `.env` Datei (wird von Docker ignoriert, siehe `.gitignore`):

```bash
cp .env.example .env
```

Passe ggf. Datenbank-Host, Benutzer, Passwort und Ports an.

---

## 3. Docker Container starten

```bash
docker-compose up -d
```

Dies startet:

- Webserver (PHP + Apache/Nginx)
- Datenbank (z.B. MySQL)
- Alle weiteren Services, die im `docker-compose.yml` definiert sind

---

## 4. Datenbank initialisieren

Wenn du die Datenbank zum ersten Mal aufsetzen willst:

```bash
./db-init/init-db.sh
```

oder den entsprechenden Befehl für deine `db-init` Scripts.

---

## 5. FarmOS installieren / konfigurieren

- Kopiere die Beispiel-Site-Konfiguration:

```bash
cp sites/example.settings.local.php sites/default/settings.php
```

- Stelle sicher, dass die `sites/default/files` Ordner **schreibbar** sind:

```bash
chmod -R 775 sites/default/files
```

- Rufe die Seite im Browser auf:  
```
http://localhost:8080
```

> Port kann je nach `docker-compose.yml` variieren.

---

## 6. Cronjobs einrichten (optional)

```bash
./setup-cron.sh
```

Dies richtet die FarmOS-typischen Cronjobs ein (z.B. für Sensor-Updates, Logs, Backups).

---

## 7. Backup & Restore

- Backup erstellen:

```bash
./backup.sh
```

- Backup wiederherstellen:

```bash
./restore.sh <backup-datei>.tar.gz
```

---

## 8. Git Workflow

- Änderungen committen:

```bash
git add .
git commit -m "Beschreibung der Änderung"
git push origin main
```

> Private Dateien (z.B. `private/`, `.env`) werden nicht ins Git gepusht.

---

## 9. Tipps

- **Composer** verwenden, um zusätzliche PHP-Module zu installieren
- **Docker Logs** checken:

```bash
docker-compose logs -f
```

- **Datenbank-Zugriff lokal**:

```bash
docker exec -it <db-container-name> mysql -u root -p
```

---

## Lizenz

Dieses Projekt ist **privat** / auf Anfrage.