# Security Policy

Danke fuer verantwortungsvolle Hinweise auf Sicherheitsprobleme in diesem Projekt.

## Supported Versions

Aktiv gepflegt wird der aktuelle Stand auf `main`.

| Version | Supported |
| --- | --- |
| `main` | yes |

## Meldung von Schwachstellen

Bitte melde vermutete Sicherheitsluecken nicht als oeffentliches GitHub Issue.

Bevorzugter Weg:

- GitHub Private Vulnerability Reporting oder Security Advisory in diesem Repository, falls aktiviert

Falls diese Option nicht verfuegbar ist:

- direkte Kontaktaufnahme mit dem Repository-Eigentuemer ueber GitHub

Bitte liefere in der Meldung nach Moeglichkeit:

- betroffene Komponente oder Datei
- kurze Beschreibung der Schwachstelle
- Reproduktionsschritte
- moegliche Auswirkungen
- falls vorhanden: Screenshots oder Proof of Concept

## Erwartete Reaktion

- Eingangsbestätigung innerhalb von `3` Werktagen
- erste Einschaetzung innerhalb von `7` Werktagen
- weitere Updates, solange die Meldung bearbeitet wird

## Offenlegung

Wir bitten darum, Sicherheitsluecken zunaechst vertraulich zu behandeln, bis:

- die Meldung validiert wurde
- ein Fix oder eine tragfaehige Gegenmassnahme bereitsteht
- ein sinnvoller Zeitpunkt fuer die Veroeffentlichung abgestimmt wurde

## Scope

Im Scope:

- SwiftUI-App-Code unter `Sources/App`
- Dateizugriff, Import, Umbenennung und Validierungslogik
- Build-, Release- und GitHub-Workflow-Dateien

Nicht im Scope:

- rein theoretische Risiken ohne realistische Ausnutzbarkeit
- Probleme in lokalen Beispiel- oder Testdaten ohne Sicherheitsrelevanz
- Schwachstellen, die ausschliesslich aus lokaler Fehlkonfiguration der Entwicklungsumgebung entstehen
