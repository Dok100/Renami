# PROJ-5 Release 1.0 Hardening

## Ziel

Renami soll vom funktionsfaehigen Produktstand in einen belastbaren Release-1.0-Stand ueberfuehrt werden. Der Fokus liegt auf Stabilitaet, nachvollziehbarer Auslieferung, klaren Grenzen und wenigen kleinen Abrundungen, die den vorhandenen Workflow sicherer machen.

## Nutzerproblem

Die Kernfunktionen sind vorhanden, aber ein guter 1.0-Stand braucht mehr als neue Features: Nutzer muessen sich auf Eingaben, Vorschau, Validierung, Umbenennung und Undo verlassen koennen. Gleichzeitig soll der Funktionsumfang klein genug bleiben, damit Renami nicht wieder wie ein ueberladenes Profi-Tool wirkt.

## Scope

- Regel-Editor, Vorschau, Drag-and-drop-Reordering und Texteingaben stabilisieren
- Rename-, Konflikt- und Undo-Fluesse mit echten Dateien manuell pruefen
- Sandbox-, File-Access-, Signing- und Entitlement-Stand fuer Release 1.0 klaeren
- reproduzierbaren Release-Build und Versionierung vorbereiten
- manuelle QA-Checkliste fuer kritische Pfade ergaenzen
- bekannte Grenzen fuer 1.0 dokumentieren
- Diakritika-Entfernung als einfache Bereinigungsregel bereitstellen

## Nicht im Scope

- Multi-Session-Undo
- Finder-Erweiterung
- Regex-First-UX
- EXIF- oder metadatenbasierte Benennung
- komplexe Include-, Exclude- oder Tiefenregeln fuer Ordnerimporte
- feste Namensmuster als vollstaendige Template-Sprache

## Nutzerstories

1. Als Nutzer moechte ich vor einer Umbenennung sicher erkennen, welche Dateien wirklich geaendert werden, damit ich keine unerwarteten Dateinamen erzeuge.
2. Als Nutzer moechte ich eine fehlgeschlagene oder falsche letzte Umbenennung direkt rueckgaengig machen koennen, damit ich nicht manuell reparieren muss.
3. Als Nutzer moechte ich Akzente und diakritische Zeichen entfernen koennen, damit Dateinamen einfacher kompatibel und suchbar werden.
4. Als Betreiber moechte ich einen reproduzierbaren Release-Build haben, damit Version 1.0 nachvollziehbar gebaut, getestet und veroeffentlicht werden kann.

## Akzeptanzkriterien

1. `make check`, `make test` und `make security` laufen vor dem Release erfolgreich.
2. Der Regel-Editor akzeptiert Eingaben in allen aktiven Textfeldern und aktualisiert die Vorschau unmittelbar.
3. Drag-and-drop und Pfeilaktionen fuer Regeln veraendern die tatsaechliche Pipeline-Reihenfolge stabil.
4. Konflikte blockieren die Umbenennung und zeigen eine konkrete, nutzerverstaendliche Ursache.
5. Undo steht nach einer erfolgreichen Umbenennung fuer genau diesen letzten Lauf zur Verfuegung.
6. Die Regel `Akzente entfernen` wandelt diakritische Zeichen im Dateinamen ohne Erweiterung in einfache Grundzeichen um.
7. Version, Build-Weg, Entitlements und Release-Grenzen sind dokumentiert.

## Testhinweise

- echte Testordner mit Schreibrechten verwenden
- einzelne Dateien und Ordnerimporte pruefen
- rekursive Ordner mit Dateityp-Filtern nachtraeglich umstellen
- Regeln aktivieren, deaktivieren und umordnen
- Diakritika-Entfernung mit Namen wie `Überblick für Crème brûlée.txt` pruefen
- Rename und Undo im selben App-Lauf pruefen
