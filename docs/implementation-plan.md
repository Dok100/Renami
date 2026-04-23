# Implementierungsplan

## Ziel

Das Repository vom generischen Framework in eine baubare, testbare macOS-App fuer sicheres Batch-Umbenennen ueberfuehren.

## Umgesetzte Inkremente

1. Root-Dokumentation und Build-Dateien auf Renami und `swift-macos` ausrichten.
2. Domain- und Service-Schicht fuer Import, Regeln, Preview, Validierung und Rename anlegen.
3. SwiftUI-Hauptfenster mit Dateiliste, Regelbereich und Vorschau bauen.
4. Erste nutzbare Regeln und die Batch-Umbenennung implementieren.
5. Basistests fuer Pipeline und Validierung ergaenzen.
6. Preset-Verwaltung mit lokalem Speichern sowie Import und Export umsetzen.
7. Undo fuer die letzte erfolgreiche Umbenennung in der laufenden Session ergaenzen.
8. linke Quellenliste um Fokusfilter fuer `Alle`, `Geaendert` und `Konflikte` erweitern.
9. rekursiven Ordnerimport und Dateityp-Filter in den Importfluss integrieren.
10. UI und Regel-Editor fuer stabileres Reordering und klarere Vorschau nachziehen.

## Naechste Ausbaustufen

- stabilere Feinschliffe fuer den Regel-Editor und weitere Tests rund um Texteingaben, Drag-and-drop und Fokuszustand
- weitere einfache Regeln und Release-Haertung unter `PROJ-5`
- feste Namensmuster als spaeterer Preset-/Profi-Baustein pruefen
- feinere Importoptionen fuer Ordner, ohne in eine komplexe Profi-UI abzugleiten
- Undo-Konzept ueber mehrere Sessions und optionales Aktivitaetsprotokoll
- Polishing fuer Release, Distribution und Sandboxing ausserhalb lokaler Entwicklungslaeufe
