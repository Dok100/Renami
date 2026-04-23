# Runbook

Schlankes Solo-Runbook fuer Betrieb, Fehlerbehebung und schnelle Orientierung.

## Systemueberblick

- Anwendung: `Renami`
- Hauptzweck: lokale Batch-Umbenennung von Dateien und rekursiv importierten Ordnerinhalten mit Live-Vorschau
- Primaerer Stack: `Swift 6`, `SwiftUI`, `Foundation`, punktuell `AppKit`
- Deployment-Ziel: native macOS-App fuer lokale Nutzung und Xcode-basierte Builds
- wichtigste externen Systeme:
  - lokales Dateisystem
  - `NSOpenPanel` und `NSSavePanel`
  - GitHub fuer Repository, CI und CodeQL

## Wichtige Zugaenge

- Produktions-URL: keine, lokale Desktop-App
- Hosting: keines
- Datenbank: keine
- Auth: keine Nutzeranmeldung
- Logs: Xcode-Konsole sowie `/tmp/xcodebuild-build.log` und `/tmp/xcodebuild-test.log`
- Monitoring: keines, Fehler werden primaer in UI und lokalen Builds sichtbar
- Incident-Kanal: GitHub Issues im Repository `Dok100/Renami`

## Standardbefehle

- lokal starten: `make install` und anschliessend `open Renami.xcodeproj`
- Tests ausfuehren: `make test`
- Lint: `make lint`
- Build: `make build`
- Vollcheck vor Commit: `make precommit`
- Sicherheitsbasis pruefen: `make security`
- Rollback: letzter stabiler Git-Commit oder Git-Tag auf `main`

## Typische Stoerungen

### App startet nicht

- `make install` erneut ausfuehren, damit `Renami.xcodeproj` sauber neu generiert wird
- in Xcode `Product > Clean Build Folder` ausfuehren
- Build-Log in `/tmp/xcodebuild-build.log` pruefen
- pruefen, ob `xcodegen`, `swiftformat` und `xcodebuild` lokal verfuegbar sind

### Dateien lassen sich nicht auswaehlen oder umbenennen

- App-Sandbox und Berechtigungen pruefen
- sicherstellen, dass Dateien oder Zielordner ueber Open Panel oder Drag-and-drop in die App gegeben wurden
- bei rekursiv importierten Ordnern reicht die Freigabe des uebergeordneten Importordners fuer enthaltene Unterordner
- bei einzeln importierten Dateien aus verschiedenen Ordnern muessen die betroffenen Zielordner freigegeben werden
- bei Umbenennungsfehlern Vorschau und Konflikthinweise rechts lesen
- pruefen, ob Schreibrechte fuer den Zielordner vorliegen

### Eingaben im Regel-Editor reagieren nicht

- zuerst pruefen, ob ein lokaler Regression-Stand vorliegt: `make test`
- `RuleEditorPane.swift` auf Overlay- oder Drag-State-Aenderungen pruefen
- bei Fokusproblemen App neu starten und Xcode Build Folder bereinigen
- sicherstellen, dass keine transparente Overlay-View Eingaben abfaengt

### Vorschau zeigt unerwartete Konflikte

- Konflikttext in der Vorschau lesen: haeufig sind es vorhandene Zieldateien, doppelte Zielnamen oder ungueltige Zeichen
- Konflikte immer pro Zielordner bewerten; identische Namen in verschiedenen Ordnern sind nur dann okay, wenn sie nicht im selben Ordner landen
- bei Datums- und Schreibweisen-Regeln auf die Reihenfolge der Regelkette achten
- pruefen, ob eine Bereinigungsregel oder Schreibweisen-Regel bestehende Datums-Praefixe ungewollt veraendert

## Rollback

- letzter stabiler Stand: letzter gruener Commit auf `main` oder letzter Release-Tag
- technischer Rollback-Weg: betroffenen Commit in Git revertieren oder auf letzten stabilen Stand zurueckgehen und neu bauen
- Datenbank-Risiken: keine
- manuelle Nacharbeiten: nach fehlgeschlagenen Rename-Laeufen Dateinamen pruefen und falls moeglich die Undo-Funktion innerhalb derselben Session verwenden

## Nachbearbeitung

- Ursache in `docs/decision-log.md` oder passender Feature-Spezifikation dokumentieren
- Schutzmassnahme oder Test nachziehen
- `README.md`, `docs/architecture.md` oder betroffene Feature-Datei aktualisieren, wenn sich Verhalten geaendert hat
