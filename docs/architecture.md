# Architektur

## Ziel

Technische Leitplanken fuer eine bewusst einfache, native macOS-App zum Batch-Umbenennen festhalten. Die Architektur soll das MVP schnell tragfaehig machen, ohne spaetere Erweiterungen wie weitere Regeln, Presets oder einen Profi-Modus zu verbauen.

## Systemkontext

- Eingaben:
  - Datei- und Ordner-URLs aus Drag-and-Drop oder Open Panel
  - regelbasierte Benennungskonfiguration
- Ausgaben:
  - Live-Vorschau je Datei
  - Validierungsstatus je Datei
  - umbenannte Dateien im lokalen Dateisystem
- externe Systeme:
  - lokales Dateisystem
  - AppKit fuer Open Panels
- primaere Nutzer:
  - Mac-Anwender mit wiederkehrenden Umbenennungsaufgaben

## Kernbausteine

- `FileImportService`
  - importiert Dateien und optionale Ordner
  - unterstuetzt flachen oder optional rekursiven Ordnerimport
  - kann rekursiv importierte Dateien ueber einfache Dateityp-Gruppen eingrenzen
- `RenameRule`
  - modelliert eine benannte, aktivierbare Regel mit leichtgewichtiger Konfiguration
  - arbeitet standardmaessig auf dem Dateinamen ohne Erweiterung
- `RenamePipeline`
  - wendet Regeln in stabiler Reihenfolge auf jede Datei an
- `PreviewEngine`
  - berechnet aus Dateiliste und Regelkette die Vorschau in Echtzeit
- `ValidationService`
  - prueft leere Namen, ungueltige Zeichen, doppelte Zielnamen und vorhandene Zieldateien
- `RenameExecutor`
  - fuehrt nur valide, ausgewaehlte Umbenennungen aus
- `PresetStore`
  - kapselt die spaetere Persistenz wiederverwendbarer Regelsets
- `PresetTransferService`
  - serialisiert Presets fuer Import und Export als einfache JSON-Dateien

## Daten und Schnittstellen

- zentrale Datenobjekte:
  - `FileItem`: Quell-URL, Originalname, Erweiterung, Auswahlstatus
  - `RenameRule`: Typ, Anzeigename, Aktivierung, Konfiguration
  - `PreviewItem`: Originalzustand, Vorschlag, Fehler und Umbenennungsstatus
  - `ValidationIssue`: maschinenlesbarer Typ plus menschenlesbare Meldung
- kritische Schnittstellen:
  - Drag-and-Drop von `fileURL`
  - `NSOpenPanel` fuer Dateien und Ordner
  - `FileManager.moveItem` fuer das eigentliche Umbenennen
- Validierungs- und Fehlerstrategie:
  - jede Datei wird separat validiert
  - blockierende Probleme erscheinen direkt in Liste und Vorschau
  - die Ausfuehrung wird global blockiert, wenn ausgewaehlte Dateien Fehler haben
- personenbezogene Datenkategorien:
  - keine bewusst verarbeiteten personenbezogenen Daten
  - Dateinamen und Pfade werden lokal verarbeitet und nicht extern uebertragen
- Speicherorte und Regionen:
  - lokal auf dem Geraet
- Loesch- und Exportfaehigkeit:
  - keine serverseitige Speicherung
  - spaetere Presets lokal loeschbar

## Leitplanken

- bevorzugter Stack:
  - `Swift 6`, `SwiftUI`, `Foundation`, punktuell `AppKit`
- Deployment-Ziel:
  - native macOS-App
- Repository-Sichtbarkeit:
  - privat
- Sicherheitsanforderungen:
  - keine stillschweigenden Ueberschreibungen
  - Dateiendungen standardmaessig schuetzen
  - nur explizit gewaehlte Dateien umbenennen
- Logging und Monitoring:
  - im MVP kein Telemetrie-System
  - lokale Fehlerzustaende sichtbar in der UI
- Datenschutz und DSGVO:
  - verarbeitet personenbezogene Daten: nein, abgesehen von lokal sichtbaren Dateinamen und Pfaden
  - relevante Verarbeitungen in `docs/privacy/ropa.md`
  - Dienstleister in `docs/privacy/vendor-register.md`
  - Aufbewahrung in `docs/privacy/data-retention.md`

## Architekturprinzipien

- Einfachheit vor Vollstaendigkeit
- Vorschau ist kein Nebenpfad, sondern Kernfluss
- klare Trennung zwischen Import, Transformation, Validierung und Ausfuehrung
- Erweiterbarkeit ueber kleine, isolierte Regeltypen statt grosse if-else-Logik in Views
- pragmatische ViewModels fuer UI-Zustand, keine fruehe Mehrschicht-Ueberabstraktion

## Offene technische Fragen

- Reicht `UserDefaults` fuer Presets oder ist frueh eine JSON-Datei pro Benutzer sinnvoller?
- Welche Sandbox-/Security-Scoped-Strategie soll fuer spaetere Distribution ausserhalb lokaler Builds vertieft werden?
