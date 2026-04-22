# Implementierungsplan

## Ziel

Das Repository vom generischen Framework in eine baubare, testbare macOS-App fuer sicheres Batch-Umbenennen ueberfuehren.

## Inkremente

1. Root-Dokumentation und Build-Dateien auf Renami und `swift-macos` ausrichten.
2. Domain- und Service-Schicht fuer Import, Regeln, Preview, Validierung und Rename anlegen.
3. SwiftUI-Hauptfenster mit Dateiliste, Regelbereich und Vorschau bauen.
4. Erste nutzbare Regeln und die Batch-Umbenennung implementieren.
5. Basistests fuer Pipeline und Validierung ergaenzen.

## Naechste Ausbaustufen

- Preset-Verwaltung mit Datei-Import und -Export abrunden
- Undo fuer die letzte Umbenennung mit klarer Session-Grenze in der laufenden App
- linke Quellenliste mit Fokusfiltern fuer Alle, Geaendert und Konflikte
- staerkere Reorder-Rueckmeldung fuer fachlich relevante Regelreihenfolge
- weitere Regeln wie Diakritika-Entfernung oder feste Namensmuster
- bessere Ordner- und Profi-Workflows
- Undo-Konzept ueber mehrere Sessions und Protokollierung
