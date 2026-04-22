# PROJ-2 Preset Management

## Ziel

Renami soll wiederkehrende Regelkombinationen als einfache, lokale Presets nutzbar machen: benennen, speichern, erneut laden, aktualisieren, loeschen sowie als Datei exportieren und importieren.

## Nutzerproblem

Der MVP kann Regeln bereits lokal speichern, aber der Ablauf ist noch zu roh fuer echte Wiederverwendung. Nutzer brauchen eine schlanke Preset-Verwaltung, damit typische Umbenennungsmuster nicht jedes Mal neu gebaut werden muessen.

## Scope

- Presets lokal in `UserDefaults` speichern
- Presets mit eindeutigem, menschenlesbarem Namen verwalten
- vorhandenes Preset aktualisieren koennen
- gespeichertes Preset laden koennen
- ausgewaehltes Preset loeschen koennen
- ausgewaehltes Preset als Datei exportieren koennen
- Preset-Datei importieren und in den lokalen Bestand uebernehmen
- klare Rueckmeldung bei Speichern, Aktualisieren, Laden, Loeschen, Export und Import

## Nicht im Scope

- Cloud-Sync
- Ordner- oder Dateifilter innerhalb eines Presets
- Versionsmigration fuer mehrere historische Preset-Formate

## Nutzerstories

1. Als Nutzer moechte ich eine funktionierende Regelkombination unter einem Namen speichern, damit ich sie spaeter erneut verwenden kann.
2. Als Nutzer moechte ich ein vorhandenes Preset aktualisieren, damit ich kleine Anpassungen nicht als neues Preset duplizieren muss.
3. Als Nutzer moechte ich ein nicht mehr benoetigtes Preset loeschen, damit die Auswahl schlank und uebersichtlich bleibt.
4. Als Nutzer moechte ich ein Preset exportieren und spaeter wieder importieren, damit ich meine Regelsets sichern oder auf einem anderen Mac erneut anlegen kann.

## Akzeptanzkriterien

1. Ein Preset kann mit einem nicht-leeren Namen gespeichert werden.
2. Wird ein vorhandenes Preset erneut gespeichert, wird es aktualisiert statt als Dublette angelegt.
3. Die Auswahl eines Presets erlaubt das Laden der gespeicherten Regeln in die aktuelle Sitzung.
4. Ein ausgewaehltes Preset kann geloescht werden.
5. Ein ausgewaehltes Preset kann als JSON-Datei exportiert werden.
6. Eine gueltige JSON-Preset-Datei kann importiert und lokal gespeichert werden.
7. Nach Speichern, Aktualisieren, Laden, Loeschen, Export oder Import zeigt die App eine kurze, verstaendliche Rueckmeldung an.

## Edge Cases

- Preset-Name enthaelt nur Leerzeichen.
- Preset-Name unterscheidet sich nur in Gross-/Kleinschreibung von einem vorhandenen Preset.
- Ein Preset wird geloescht, waehrend es gerade ausgewaehlt ist.
- Eine importierte Datei enthaelt kein gueltiges Preset.

## Abhaengigkeiten

- `features/PROJ-1-mvp-batch-rename-workflow.md`
- `docs/architecture.md`

## Testhinweise

- Preset wird neu angelegt
- Preset wird mit demselben Namen aktualisiert
- Preset wird per ausgewaehlter ID aktualisiert
- geloeschtes Preset ist nicht mehr in der Auswahl
- Preset laesst sich in Datei schreiben und wieder lesen
