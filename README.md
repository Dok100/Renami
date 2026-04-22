# Renami

Renami ist eine native macOS-App zum sicheren Umbenennen mehrerer Dateien mit Live-Vorschau. Das Produkt ist bewusst ruhiger und einfacher als umfangreiche Profi-Tools: Dateiquellen links, Regeln in der Mitte, Wirkung und Konflikte rechts.

## Produktkern

- Fokus auf einfache, wiederkehrende Batch-Umbenennungen
- Live-Vorschau als zentrales Bedienelement
- Dateiendungen bleiben standardmaessig unveraendert
- Kritische Konflikte blockieren das Umbenennen
- Klar benannte Regeln statt technischer Power-UI

## Aktueller Funktionsstand

Der aktuelle Stand von Renami liefert:

- Dateien und optionale Ordner via Open Panel oder Drag-and-Drop hinzufuegen
- Ordner optional rekursiv einlesen
- rekursiv importierte Dateien nach einfachen Dateityp-Gruppen filtern
- Dateiliste mit Auswahlstatus, Originalname, vorgeschlagenem Namen und Validierungsstatus
- linke Quellenliste mit Fokusfiltern fuer `Alle`, `Geaendert` und `Konflikte`
- modulare Regelkette mit Live-Vorschau
- Vorschau kann geaenderte Dateien priorisiert oder isoliert anzeigen
- erste Regeln:
  - Finden und Ersetzen
  - Praefix
  - Suffix
  - Text einfuegen
  - Datum einfuegen
    - optional nur dann, wenn noch kein Datums-Praefix vorhanden ist
  - Datums-Praefix normalisieren
  - Nummerierung
  - Zeichen am Anfang oder Ende entfernen
  - Schreibweise aendern
  - Windows-kompatible Bereinigung
- Validierung fuer doppelte Zielnamen, leere oder ungueltige Namen und Kollisionen mit vorhandenen Dateien
- tatsaechliches Umbenennen im Dateisystem
- lokale Presets fuer wiederkehrende Regelkombinationen speichern, laden, aktualisieren, loeschen, exportieren und importieren
- Undo fuer die letzte erfolgreiche Umbenennung innerhalb der laufenden App-Session

## Architektur in Kurzform

- `SwiftUI` fuer die native Oberflaeche
- `FileImportService` fuer Open-Panel, Drag-and-Drop und Ordnerauflistung
- `RenameRule` als leichtgewichtige, erweiterbare Regelabstraktion
- `RenamePipeline` fuer die geordnete Transformation des bearbeitbaren Dateinamens
- `PreviewEngine` fuer die laufende Vorher-/Nachher-Berechnung
- `ValidationService` fuer blockierende Konflikte und zeilenweise Fehler
- `RenameExecutor` fuer sichere Dateisystem-Aktionen
- `PresetStore` als vorbereiteter lokaler Persistenzbaustein

## Repository-Orientierung

- Produktkontext: `docs/brief.md`
- Architektur: `docs/architecture.md`
- Entscheidungen: `docs/decision-log.md`
- MVP-Feature: `features/PROJ-1-mvp-batch-rename-workflow.md`
- UI-Konzept: `UI-Wireframe.md`
- Produktplan: `Produktplan.md`
- Implementierungsplan: `docs/implementation-plan.md`

## Entwicklung

Voraussetzungen:

- Xcode oder Xcode Command Line Tools
- `xcodegen`
- `swiftformat`

Typischer Ablauf:

```bash
make install
make test
make build
```

Vor einem Commit ist `make precommit` der sinnvolle Vollcheck.

## GitHub

- Repository: `https://github.com/Dok100/Renami`
- CI laeuft ueber GitHub Actions in `.github/workflows/ci.yml`
- statische Analyse laeuft ueber `.github/workflows/codeql.yml`
- Dependabot pflegt GitHub-Actions-Abhaengigkeiten ueber `.github/dependabot.yml`
- Issue- und PR-Vorlagen liegen unter `.github/`

Fuer den ersten lokalen Publish:

```bash
git init
git remote add origin https://github.com/Dok100/Renami.git
git add .
git commit -m "Initialer Projektstand"
git branch -M main
git push -u origin main
```

## Aktueller Fokus

Renami ist inzwischen ueber das reine MVP hinausgewachsen, bleibt aber bewusst einfach im Bedienkonzept. Der aktuelle Schwerpunkt liegt auf Stabilitaet, Klarheit in der UI und dem sauberen Ausbau der bestehenden Regeln, Presets und Import-Workflows.

Bewusst weiterhin nicht priorisiert sind:

- Regex-First-UX oder wildcard-lastige Profi-Eingaenge
- Finder-Erweiterung
- mehrstufiges Undo ueber mehrere Sessions
- Metadaten- oder EXIF-basierte Benennung
- beliebig komplexe Include-, Exclude- und Tiefenregeln fuer Ordnerimporte
