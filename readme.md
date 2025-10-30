# AGRIMO

AGRIMO ist eine Webapplikation zur Verwaltung von landwirtschaftlichen Assets und Daten. Dieses Dokument beschreibt, wie du das Projekt lokal aufsetzen und betreiben kannst.

---

## Voraussetzungen

Stelle sicher, dass die folgenden Tools auf deinem System installiert sind:

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- Git
- Optional: PHP CLI, falls du lokal PHP-Skripte ausführen möchtest

---

## Repository klonen

```bash
git clone git@github.com:whispers2011/AGRIMO.git
cd AGRIMO
```

---

## Projektstruktur

```
AGRIMO/
├─ DEPLOYMENT.md
├─ docker-compose.yml
├─ php.ini
├─ setup-cron.sh
├─ status.sh
├─ sites/
│  ├─ default/
│  │  ├─ default.services.yml
│  │  ├─ default.settings.php
│  │  └─ files/
│  └─ README.txt
├─ config/
├─ private/          # lokal, nicht versioniert
├─ backup.sh          # lokal, nicht versioniert
├─ restore.sh         # lokal, nicht versioniert
└─ db-init/           # lokal, nicht versioniert
```

- `sites/default` enthält die Standard-Site für die AGRIMO-Anwendung.
- `config/` beinhaltet globale Konfigurationen.
- `private/`, `backup.sh`, `restore.sh` und `db-init/` werden **nicht** versioniert und müssen lokal gepflegt werden.

---

## Lokales Setup mit Docker

1. Starte die Container:

```bash
docker-compose up -d
```

2. Prüfe die laufenden Container:

```bash
docker ps
```

3. Zugriff auf die AGRIMO-Site:

- Öffne deinen Browser unter `http://localhost` (Standardport: 80)
- Die Standard-Site befindet sich in `sites/default`

---

## Cronjobs einrichten

Falls nötig, können Cronjobs wie in `setup-cron.sh` beschrieben eingerichtet werden:

```bash
bash setup-cron.sh
```

Dies richtet geplante Aufgaben für Backups, Status-Skripte oder Datenimporte ein.

---

## Datenbank

- Die Datenbank wird über Docker Compose bereitgestellt.
- Initialisierungsskripte befinden sich in `db-init/` (nicht versioniert).
- Datenbank-Zugang: siehe `docker-compose.yml`

---

## Git & Versionierung

- Lokale Änderungen werden mit Git verwaltet:

```bash
git status
git add .
git commit -m "Beschreibung der Änderungen"
git push origin main
```

- Dateien in `.gitignore` werden **nicht** versioniert (Backups, private Konfigurationen, Cache-Dateien, lokale Claude-Versionen etc.).

---

## Tipps für Entwickler:innen

- Änderungen an `sites/default/settings.php` oder `config/` können lokal getestet werden.
- Große Dateien oder temporäre Daten nicht ins Repo aufnehmen.
- Für die Produktion müssen `private/`-Daten manuell auf den Server übertragen werden.

---

## Kontakt

Für Fragen und Support siehe `DEPLOYMENT.md` oder kontaktiere das AGRIMO-Team.

