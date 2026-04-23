# Security Baseline

Diese Datei beschreibt die aktuelle Sicherheitsbasis von Renami als lokale macOS-App mit GitHub-gestuetztem Entwicklungsworkflow.

## Enthalten

- `.gitignore` deckt lokale Build-Artefakte, abgeleitete Xcode-Daten und offensichtliche lokale Geheimnisse ab
- `scripts/check-secrets.sh` blockiert typische Secrets im lokalen Pre-Commit
- `scripts/pre-commit.sh` fuehrt die lokalen Basischecks vor Commits aus
- `scripts/install-git-hooks.sh` kann den Git-Hook lokal installieren
- `make security` prueft grundlegende Sicherheitsannahmen wie Secret-Muster, App Sandbox und Code-Signing-Konfiguration
- GitHub Actions CI und CodeQL sind unter `.github/workflows/` vorhanden
- `Dependabot` aktualisiert GitHub-Actions-Abhaengigkeiten ueber `.github/dependabot.yml`
- `SECURITY.md` beschreibt den Responsible-Disclosure-Prozess fuer dieses Repository
- `docs/privacy/` enthaelt die Datenschutz-Basis fuer lokale Dateiverarbeitung, Dienstleister und Loeschregeln

## `.env`-Policy

- Renami benoetigt fuer die Kernfunktion aktuell keine Laufzeit-Umgebungsvariablen
- echte Geheimnisse gehoeren nur in `.env` oder einen Secret-Manager
- `.env.example` darf nur Platzhalter oder offensichtliche Beispielwerte enthalten
- neue Umgebungsvariablen muessen immer zuerst in `.env.example` dokumentiert werden, falls sie spaeter eingefuehrt werden
- keine Tokens, privaten Zertifikate oder Zugangsdaten in Markdown, Tests oder Fixtures ablegen
- Kontaktweg in `SECURITY.md` muss konsistent mit dem realen Repository-Zugriff bleiben

## Erwartete Arbeitsweise

- vor Commits `make precommit` ausfuehren
- vor Releases mindestens `make test` und `make security` ausfuehren
- Git-Hooks lokal installieren, wenn der Workflow dauerhaft auf derselben Maschine genutzt wird
- Dependabot-PRs nicht blind mergen, sondern durch Tests und Review absichern
- sicherheitsrelevante Aenderungen an Dateizugriff, Sandbox oder Rename-Logik in `docs/decision-log.md` oder der passenden Feature-Datei dokumentieren
- vor externer Weitergabe klaeren, ob die App nur lokal gezippt oder Developer-ID-signiert und notarisiert verteilt wird

## Grenzen

- Musterbasierte Secret-Pruefung findet nicht alles
- CodeQL und CI decken nicht jede lokale Laufzeit- oder UI-Regression ab
- lokale Desktop-Apps haben andere Risiken als Web-Apps; CSP- oder Header-Themen sind hier nicht zentral
- Security-Scoped-Zugriffe und Sandbox-Verhalten sind fuer lokale Builds stabilisiert; fuer breitere Distribution bleiben Developer-ID-Signierung, Notarisierung und Gatekeeper-Verhalten separat zu pruefen

## Abgrenzung zu Datenschutz

Security ist nicht gleich DSGVO. Technische Sicherheit hilft, ersetzt aber nicht:

- Transparenz gegenueber Nutzern
- Rechtsgrundlagen fuer Verarbeitung
- Loesch- und Auskunftsprozesse
- Vendor- und Transfer-Pruefung

## Solo-Betrieb

Wenn du allein arbeitest, sind diese Dateien oft die pragmatischsten Ergaenzungen:

- `docs/release-checklist.md`
- `docs/runbook.md`
- `docs/data-classification.md`
- `SECURITY.md`
