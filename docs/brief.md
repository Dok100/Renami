# Projektbriefing fuer Renami

## Ausgangslage

Renami soll das vorhandene Projekt-Framework in eine native macOS-App fuer sichere Batch-Umbenennungen ueberfuehren. Das Produkt richtet sich an Nutzer, denen bestehende Tools zu komplex sind und die eine ruhige, direkte Live-Vorschau mit klaren Regeln bevorzugen.

## Nutzer

Mac-Anwender, die regelmaessig Dokumente, Bilder, PDFs oder Exportdateien umbenennen und dabei eine niedrige Einstiegshuerde, Verstaendlichkeit und sichere Validierung erwarten.

## Zielbild

Ein erstes nuetzliches Ergebnis ist eine lauffaehige SwiftUI-macOS-App mit drei klaren Bereichen: Dateiliste, Regel-Editor und Live-Vorschau. Nutzer koennen Dateien oder Ordner hinzufuegen, mehrere einfache Regeln kombinieren, Konflikte sofort sehen und nur dann umbenennen, wenn das Ergebnis gueltig ist.

## Primaerer Stack

`swift-macos`

## MVP-Scope

Welche 3 bis 5 Dinge muessen unbedingt funktionieren?

- Dateien und optionale Ordner importieren
- Regelkette mit Live-Vorschau auf den Dateinamen ohne Erweiterung
- typische Umbenennungsbausteine inklusive Datum aus manuellem oder Datei-Kontext
- Schutzlogik gegen doppeltes Datums-Praefix
- vereinfachte Normalisierung gaengiger Datums-Praefixe am Dateianfang
- blockierende Validierung vor dem Umbenennen
- tatsaechliche Batch-Umbenennung im Dateisystem
- vorbereitete Erweiterbarkeit fuer weitere Regeln und Presets

## Nicht im Scope

Was wird bewusst nicht im ersten Schritt gebaut?

- Regex-First-UX und Wildcards in der Standardansicht
- Finder-Erweiterung
- komplexe rekursive Ordner-Workflows mit Tiefensteuerung oder Include/Exclude-Regeln
- dauerhaftes Undo/Redo ueber mehrere Sessions
- EXIF- oder Metadaten-basierte Benennung

## Erfolgskriterien

Woran ist erkennbar, dass das Projekt funktioniert?

- Das Root-Repository laesst sich als macOS-App bauen und testen.
- Die Vorschau aktualisiert sich direkt bei Regel- oder Dateiaenderungen.
- Konflikte wie Duplikate, ungueltige Namen oder vorhandene Zieldateien werden je Datei sichtbar markiert.
- Das Umbenennen ist nur moeglich, wenn keine blockierenden Fehler fuer ausgewaehlte Dateien vorliegen.

## Einschraenkungen

Technische, organisatorische oder zeitliche Grenzen.

- Lokale Verarbeitung ohne Cloud-Dienste
- moeglichst wenige Abhaengigkeiten ausserhalb von SwiftUI, Foundation und AppKit-Bruecken fuer Dateiimporte
- pragmatisches MVP statt vollstaendiger Better-Rename-Paritaet
