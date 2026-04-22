# Runbook

Schlankes Solo-Runbook fuer Betrieb, Fehlerbehebung und schnelle Orientierung.

## Systemueberblick

- Anwendung:
- Hauptzweck:
- Primaerer Stack:
- Deployment-Ziel:
- wichtigste externen Systeme:

## Wichtige Zugaenge

- Produktions-URL:
- Hosting:
- Datenbank:
- Auth:
- Logs:
- Monitoring:
- Incident-Kanal:

## Standardbefehle

- lokal starten:
- Tests ausfuehren:
- Build:
- Deployment:
- Rollback:

## Typische Stoerungen

### App startet nicht

- Logs pruefen
- Environment-Variablen pruefen
- letzte Aenderungen oder Deployments pruefen

### Login oder Auth kaputt

- Auth-Provider oder Session-Konfiguration pruefen
- Redirects, Cookies oder Token-Gueltigkeit pruefen
- betroffene Nutzer und Scope eingrenzen

### Daten fehlen oder sind falsch

- betroffene Tabellen oder APIs eingrenzen
- Migrationsstand pruefen
- Loesch- oder Synchronisationsjobs pruefen

### Externer Dienst ausgefallen

- Vendor-Status pruefen
- Fallback oder degradierter Modus dokumentieren
- Auswirkungen auf Nutzer und Datenfluss pruefen

## Rollback

- letzter stabiler Stand:
- technischer Rollback-Weg:
- Datenbank-Risiken:
- manuelle Nacharbeiten:

## Nachbearbeitung

- Ursache dokumentieren
- Schutzmassnahme oder Test nachziehen
- falls relevant `docs/decision-log.md` aktualisieren
