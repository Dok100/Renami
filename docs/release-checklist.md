# Release Checklist

Schlanke Checkliste fuer Solo-Releases von Renami.

## Vor dem Release

- Ziel und Scope des Releases sind klar
- offene bekannte Risiken sind dokumentiert
- relevante Features oder Fixes sind in `features/` aktualisiert
- Dokumentation ist auf aktuellem Stand
- `README.md`, `docs/runbook.md` und `features/INDEX.md` passen zum aktuellen Funktionsstand

## Technische Checks

- `make check` laeuft
- `make test` laeuft
- `make security` wurde ausgefuehrt
- optional `make lint` vor dem Tag oder Release-Kandidaten ausfuehren
- GitHub Actions laufen fuer den Ziel-Branch gruen
- keine echten Secrets oder `.env`-Dateien im Commit
- Logging enthaelt keine unnoetigen personenbezogenen Daten oder lokalen Pfadfragmente in Dokumentation und Screenshots

## Produkt und Datenschutz

- neue Datenfluesse rund um Dateizugriff, Presets oder Export sind in `docs/privacy/` dokumentiert
- neue Dienstleister stehen in `docs/privacy/vendor-register.md`
- neue Aufbewahrungsregeln stehen in `docs/privacy/data-retention.md`
- `SECURITY.md` und `docs/security-baseline.md` sind bei sicherheitsrelevanten Aenderungen mitgezogen

## Deployment

- Zielumgebung ist korrekt
- Standard-Branch und Remote zeigen auf das richtige GitHub-Repository
- Backups oder Rollback-Weg sind bekannt
- fuer lokale Releases ist klar, ob nur ein GitHub-Release, ein Tag oder auch ein verteilter App-Build gemeint ist
- kritische Umgebungsvariablen sind gesetzt, falls fuer Build- oder Signing-Prozesse benoetigt
- Build in Xcode oder via `make build` ist auf der Zielmaschine nachvollziehbar reproduzierbar

## Nach dem Release

- Smoke-Test in der Zielumgebung
- kritische Pfade kurz pruefen:
  - Dateien importieren
  - Regeln bearbeiten
  - Vorschau und Validierung pruefen
  - Umbenennen und Undo testen
- bekannte Follow-ups notieren
