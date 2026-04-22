# PROJ-1 MVP Batch Rename Workflow

## Ziel

Renami soll eine erste wirklich nutzbare Batch-Umbenennung fuer macOS liefern: Dateien hinzufuegen, Regeln anwenden, Ergebnis live sehen, Konflikte pro Datei erkennen und nur sichere Umbenennungen ausfuehren.

## Nutzerproblem

Bestehende Tools fuer Batch-Renames sind fuer viele Alltagsfaelle zu komplex. Nutzer brauchen eine fokussierte App, die typische Umbenennungen mit klaren Regeln, Vorschau und Konfliktpruefung abbildet, ohne sie mit Profi-Funktionen zu ueberladen.

## Scope

- Dateien und optionale Ordner importieren
- Auswahl je Datei verwalten
- Live-Vorschau fuer Originalname und vorgeschlagenen Namen
- Vorschau kann geaenderte Dateien zuerst oder isoliert anzeigen
- modulare Regeln fuer Standardfaelle
- Datumseinfuegung auf Basis manueller Eingabe oder Dateidatum
- Datumsregel kann bestehende Praefixe im Format `YYYY-MM-DD_` respektieren
- Normalisierungsregel fuer gaengige Datums-Praefixe am Anfang des Dateinamens
- blockierende Validierung vor dem Umbenennen
- tatsaechliche Umbenennung im Dateisystem
- vorbereitete Struktur fuer Presets

## Nicht im Scope

- Regex-First-UX
- Wildcards im Standardmodus
- Finder-Erweiterung
- rekursive Ordnerverarbeitung als Pflichtpfad
- mehrstufiges Undo ueber App-Sessions
- Metadaten- oder EXIF-basierte Benennung

## Nutzerstories

1. Als Mac-Anwender moechte ich mehrere Dateien auf einmal importieren, damit ich wiederkehrende Umbenennungen gesammelt erledigen kann.
2. Als Nutzer moechte ich Regeln wie Ersetzen, Praefix oder Nummerierung kombinieren, damit ich Dateinamen schnell an ein Zielmuster anpassen kann.
3. Als vorsichtiger Nutzer moechte ich Konflikte vor dem Umbenennen sehen, damit keine Dateien versehentlich kollidieren oder ungueltige Namen bekommen.
4. Als Nutzer moechte ich einzelne Dateien von der Verarbeitung ausschliessen koennen, damit ich Ausnahmen direkt im selben Lauf behandeln kann.

## Akzeptanzkriterien

1. Der Nutzer kann Dateien und Ordner per Drag-and-Drop oder Dateiauswahl hinzufuegen.
2. Die App zeigt pro Datei mindestens Auswahlstatus, Originalname, vorgeschlagenen Namen und Validierungsstatus.
3. Aenderungen an Regeln aktualisieren die Vorschau ohne manuellen Zwischenschritt.
4. Die Vorschau kann geaenderte Dateien vor ungeaenderten anzeigen, damit Unterschiede schneller sichtbar werden.
5. Kritische Fehler wie doppelte Zielnamen, leere Namen oder Kollisionen mit bestehenden Dateien blockieren das Umbenennen.
6. Die eigentliche Umbenennung betrifft nur ausgewaehlte Dateien ohne Validierungsfehler.
7. Die Datumsregel kann so konfiguriert werden, dass Dateien mit vorhandenem Datums-Praefix nicht erneut ein Datum erhalten.
8. Die Normalisierungsregel kann gaengige Praefixformate wie `18-04-2026_`, `2026_04_18_` oder `20260418_` in `YYYY-MM-DD_` ueberfuehren.

## Edge Cases

- Dateiname wird nach Regelanwendung leer.
- Zwei verschiedene Quelldateien erzeugen denselben Zielnamen im gleichen Ordner.
- Zielname existiert bereits im Dateisystem.
- Eine Datei bleibt unveraendert und darf nicht faelschlich als Fehler markiert werden.
- Ordnerimport enthaelt Unterordner, die im MVP nicht rekursiv verarbeitet werden.

## Abhaengigkeiten

- `Produktplan.md`
- `UI-Wireframe.md`
- `docs/architecture.md`

## Offene Fragen

- Presets zunaechst nur lokal in `UserDefaults` oder direkt als exportierbare JSON-Dateien?
- Soll ein spaeterer Profi-Modus eigene Regeltypen oder nur mehr Optionen in bestehenden Regeln freischalten?

## Testhinweise

- Pipeline-Tests fuer mehrere Regelkombinationen
- Validierungs-Tests fuer Duplikate, leere Namen und bestehende Ziele
- manuelle UI-Pruefung fuer Drag-and-Drop, Selektion und Rename-Ablauf
