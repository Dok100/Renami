# PROJ-4 Rekursive Ordner und Dateityp-Filter

## Ziel

Renami soll beim Ordnerimport optional auch Unterordner einlesen koennen und dabei die importierten Dateien ueber einfache, verstaendliche Dateityp-Filter eingrenzen.

## Nutzerproblem

Der aktuelle flache Ordnerimport reicht fuer kleine, einfache Ordner aus, wird aber schnell unpraktisch, wenn relevante Dateien in Unterordnern liegen oder ein Ordner viele unterschiedliche Dateitypen enthaelt. Nutzer brauchen eine einfache Moeglichkeit, groessere Dateibestaende gezielt und ohne Nacharbeit in die bestehende Rename-Pipeline zu uebernehmen.

## Scope

- optionaler Schalter `Unterordner einbeziehen` beim Ordnerimport
- rekursives Einsammeln von Dateien aus Unterordnern, wenn die Option aktiv ist
- einfache Dateityp-Filter fuer den Import
- Standardverhalten `Alle Dateien`
- vordefinierte Dateityp-Gruppen statt komplexer Freitext- oder Regex-Filter
- versteckte und typische Systemdateien standardmaessig ignorieren
- vorhandene Dateiliste, Vorschau, Validierung und Umbenennung mit rekursiv importierten Dateien weiterverwenden
- Konfliktpruefung weiterhin pro Zielordner, nicht global ueber alle Ordner hinweg

## Nicht im Scope

- Ordner selbst umbenennen
- frei definierbare Regex- oder Musterfilter
- beliebig komplexe Include- und Exclude-Regeln
- Tiefenbegrenzung fuer die Rekursion im ersten Schritt
- gesonderte Profi-Ansicht fuer Importregeln

## Vorgeschlagene Dateityp-Gruppen

- Alle Dateien
- Bilder
- Dokumente
- Tabellen
- Praesentationen
- Audio
- Video
- Archive

## Nutzerstories

1. Als Nutzer moechte ich einen Ordner mit Unterordnern importieren koennen, damit ich groessere Dateibestaende gesammelt umbenennen kann.
2. Als Nutzer moechte ich den Import auf bestimmte Dateitypen begrenzen, damit irrelevante Dateien gar nicht erst in der Liste auftauchen.
3. Als Nutzer moechte ich versteckte und technische Systemdateien nicht sehen, damit die App bei rekursiven Imports uebersichtlich bleibt.
4. Als Nutzer moechte ich identische Zielnamen in verschiedenen Unterordnern nicht faelschlich als globalen Konflikt sehen, damit die Validierung nachvollziehbar bleibt.

## Akzeptanzkriterien

1. Beim Ordnerimport kann der Nutzer waehlen, ob nur der oberste Ordner oder auch Unterordner eingelesen werden.
2. Ist `Unterordner einbeziehen` deaktiviert, bleibt das heutige flache Verhalten unveraendert.
3. Ist `Unterordner einbeziehen` aktiviert, werden Dateien aus Unterordnern in die bestehende Dateiliste uebernommen.
4. Der Nutzer kann beim Import einen Dateityp-Filter aus einer kleinen, festen Liste waehlen.
5. Der Filter `Alle Dateien` importiert alle unterstuetzten Dateien unabhaengig vom Typ.
6. Versteckte Dateien und typische Systemartefakte wie `.DS_Store` werden standardmaessig nicht importiert.
7. Dateien aus unterschiedlichen Ordnern duerfen denselben Zielnamen haben, solange sie nicht im selben Zielordner kollidieren.
8. Vorschau, Auswahl, Validierung und Umbenennung funktionieren fuer rekursiv importierte Dateien weiterhin ohne separaten Sondermodus.

## Edge Cases

- sehr grosse Ordnerstrukturen mit vielen Dateien
- gemischte Dateitypen innerhalb eines rekursiv importierten Ordners
- Unterordner enthalten nur versteckte oder ausgeschlossene Dateien
- gleiche Dateinamen in verschiedenen Unterordnern
- ein Ordner enthaelt Symlinks oder nicht lesbare Unterordner

## Abhaengigkeiten

- `features/PROJ-1-mvp-batch-rename-workflow.md`
- `features/PROJ-3-undo-and-selection-workflow.md`
- `docs/architecture.md`

## Offene Fragen

- Sollen die Dateityp-Gruppen fest im Code definiert sein oder spaeter lokal konfigurierbar werden?
- Sollen Paketdateien auf macOS wie `.app` oder `.pages` im ersten Schritt als Datei oder als Ordner behandelt werden?

## Testhinweise

- flacher Ordnerimport bleibt unveraendert
- rekursiver Import findet Dateien in Unterordnern
- Dateityp-Filter laesst nur passende Dateien in die Liste
- versteckte Dateien werden nicht importiert
- Konflikte werden fuer rekursiv importierte Dateien korrekt pro Zielordner berechnet
