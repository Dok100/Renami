# PROJ-3 Undo und Selektions-Workflow

## Ziel

Renami soll die letzte erfolgreiche Umbenennung direkt rueckgaengig machen koennen, in der Quellenliste schneller auf relevante Dateien fokussieren und das Umordnen von Regeln sichtbarer und vertrauenswuerdiger machen.

## Nutzerproblem

Nach einer Batch-Umbenennung fehlt aktuell eine direkte Sicherheitsleine fuer den letzten Schritt. Gleichzeitig wird die linke Quellenliste bei groesseren Mengen schnell unuebersichtlich, wenn nur geaenderte oder konfliktbehaftete Dateien interessant sind. Beim Verschieben von Regeln fehlt zudem noch klare visuelle Rueckmeldung fuer das eigentliche Drop-Ziel.

## Scope

- letzte erfolgreiche Umbenennung innerhalb der laufenden App-Session rueckgaengig machen
- Undo nur fuer tatsaechlich erfolgreich umbenannte Dateien anbieten
- Quellenliste links nach `Alle`, `Geaendert` und `Konflikte` filterbar machen
- Drag-and-drop bei Regeln mit klarer Rueckmeldung fuer das aktuelle Drop-Ziel verbessern
- Status- und Rueckmeldetexte fuer Rename und Undo verstaendlich halten

## Nicht im Scope

- mehrstufiges Undo ueber mehrere Sessions
- persistente Historie oder Aktivitaetsprotokolle
- differenzierte Quellenfilter fuer jede denkbare Statuskombination
- vollstaendige Rework der Regel- oder Vorschauarchitektur

## Nutzerstories

1. Als vorsichtiger Nutzer moechte ich die letzte Umbenennung sofort rueckgaengig machen koennen, damit ich einen Fehler nicht manuell reparieren muss.
2. Als Nutzer moechte ich links nur geaenderte oder konfliktbehaftete Dateien sehen, damit ich grosse Listen schneller pruefen kann.
3. Als Nutzer moechte ich beim Ziehen einer Regel klar sehen, wo sie eingefuegt wird, damit die fachlich relevante Reihenfolge vertrauenswuerdig bleibt.

## Akzeptanzkriterien

1. Nach einer erfolgreichen Umbenennung bietet die App eine Undo-Aktion fuer genau diesen letzten Lauf an.
2. Undo stellt die urspruenglichen Dateinamen fuer alle erfolgreich rueckgaengig gemachten Dateien wieder her.
3. Wenn nur ein Teil der Dateien erfolgreich umbenannt wurde, kann Undo nur fuer diesen erfolgreichen Teil ausgefuehrt werden.
4. Die Quellenliste kann zwischen `Alle`, `Geaendert` und `Konflikte` umgeschaltet werden.
5. Die Filterung links aendert nur die sichtbare Liste, nicht die zugrunde liegende Auswahl.
6. Beim Drag-and-drop von Regeln wird das aktuelle Ziel visuell hervorgehoben.
7. Nach Reordering, Rename und Undo bleibt die Vorschau konsistent.

## Edge Cases

- Undo wird angeboten, obwohl nachtraeglich einzelne Zieldateien fehlen oder verschoben wurden.
- Ein Undo-Lauf ist nur teilweise erfolgreich.
- Die Quellenliste ist durch einen Filter leer, obwohl insgesamt Dateien geladen sind.
- Eine Regel wird ueber Abschnittsgrenzen hinweg verschoben.

## Abhaengigkeiten

- `features/PROJ-1-mvp-batch-rename-workflow.md`
- `features/PROJ-2-preset-management.md`
- `docs/architecture.md`

## Testhinweise

- letzter Rename kann erfolgreich rueckgaengig gemacht werden
- Undo nach teilweisem Rename aktualisiert nur erfolgreiche Dateien
- linker Filter zeigt nur geaenderte oder konfliktbehaftete Dateien
- Reorder-Feedback stoert keine Texteingaben in Regelkarten
