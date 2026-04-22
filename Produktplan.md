**Produktplan / PRD**

**macOS-Tool zum sicheren Umbenennen von Dateien**

_Arbeitsstand: Erstfassung auf Basis der definierten Anforderungen_

|   |   |
|---|---|
|**Ziel**|Ein einfaches, schnelles und sicheres macOS-Tool entwickeln, das Dateinamen in Stapeln bearbeitet und Änderungen vor dem Anwenden in einer Live-Vorschau zeigt.|
|**Produktprinzip**|Weniger Komplexität als Better Rename, dafür klare Regeln, verständliche Bedienung und eine starke Konfliktprüfung.|

**1. Produktvision und Nutzen**

Das geplante Produkt ist ein fokussiertes macOS-Werkzeug für das sichere Umbenennen von Dateien. Der Mehrwert liegt nicht in maximaler Funktionsfülle, sondern in einer klaren, nachvollziehbaren Bedienung: Dateien auswählen, Regeln definieren, Ergebnis sofort sehen, Konflikte erkennen und Änderungen kontrolliert anwenden.

Das Tool soll insbesondere für Anwender geeignet sein, die bestehende Profi-Lösungen als zu komplex empfinden, aber trotzdem wiederkehrende Umbenennungsaufgaben sauber und effizient erledigen möchten.

**2. Zielgruppe**

**•** Mac-Anwender, die regelmäßig Dokumente, Fotos, PDFs oder Projektdateien umbenennen müssen.

**•** Nutzer, die eine Live-Vorschau und hohe Sicherheit wichtiger finden als extrem komplexe Spezialfunktionen.

**•** Anwender mit wiederkehrenden Mustern, zum Beispiel Rechnungen, Scans, Exportdateien, Bildserien oder standardisierte Ablagestrukturen.

**3. Produktziele**

**•** Deutlich geringere Einstiegshürde als bei etablierten Profi-Tools.

**•** Sofort verständliche Live-Vorschau mit Vorher-/Nachher-Ansicht.

**•** Sichere Batch-Umbenennung ohne versehentliche Beschädigung von Dateiendungen oder Namenskonflikte.

**•** Speicherbare Presets für wiederkehrende Arbeitsabläufe.

**•** Native macOS-Bedienung mit moderner, reduzierter Oberfläche.

**4. Funktionsumfang**

**Empfohlene Priorisierung**

|   |   |   |   |
|---|---|---|---|
|**Funktion**|**Phase**|**Nutzen**|**Hinweis**|
|Finden und Ersetzen|MVP|Standardfall für strukturierte Dateinamen|mit einfacher Textsuche starten|
|Präfix / Suffix|MVP|schnell, verständlich, oft gebraucht|ideal für Kategorien und Versionen|
|Text an Position einfügen|MVP|flexibel für Datums- oder Kennzeichenlogik|Position über Anfang, Ende oder Index|
|Nummerierung|MVP|zentral für Serien, Fotos, Exporte|Startwert, Schrittweite, Format|
|Zeichen am Anfang/Ende entfernen|MVP|hilfreich bei Rohdateinamen|z. B. Abschneiden von Präfixresten|
|Groß-/Kleinschreibung ändern|MVP|schnelle Vereinheitlichung|Groß, klein, Titelcase|
|Windows-Kompatibilität|MVP|praktisch für plattformübergreifende Ablage|unerlaubte Zeichen ersetzen|
|Dateiname festlegen|V1.1|klarer Sonderfall|nur mit Nummerierung oder Selektion wirklich sinnvoll|
|Diakritika entfernen|V1.1|vereinfacht Namen für Export und Austausch|é → e, ü → u/ue je nach Regel|
|Wildcards|V2|nützlich, aber erklärungsbedürftig|nur im erweiterten Modus|
|Reguläre Ausdrücke|V2|sehr mächtig für Spezialfälle|nicht im Einfach-Modus priorisieren|

**5. Bedienkonzept**

**•** Links: Dateiliste mit Auswahl, Originalname, Pfad und Status.

**•** Mitte: Regel-Editor als verständliche Bausteine statt als technische Konfigurationsmaske.

**•** Rechts: Live-Vorschau mit Originalname, neuem Namen und Konfliktanzeige.

**•** Unten: Zusammenfassung, Validierung und Schaltfläche „Anwenden“.

Wichtig ist eine konsequente Trennung zwischen Einfach-Modus und erweitertem Modus. Im Standard sieht der Nutzer nur die verständlichen Kernfunktionen. Anspruchsvollere Funktionen wie Reguläre Ausdrücke oder Wildcards werden bewusst ausgeblendet und erst bei Bedarf eingeblendet.

**6. UX-Prinzipien**

**•** Die Vorschau ist das Zentrum des Produkts, nicht nur eine Nebenfunktion.

**•** Dateiendungen werden standardmäßig geschützt und nicht mitbearbeitet.

**•** Regeln sind einzeln aktivierbar, deaktivierbar und in ihrer Reihenfolge sichtbar.

**•** Konflikte werden nicht nur angezeigt, sondern blockieren das Anwenden.

**•** Einzelne Dateien können von der Verarbeitung ausgeschlossen werden.

**7. Fachliche Kernlogik**

Die App verarbeitet pro Datei mindestens den Originalpfad, den ursprünglichen Dateinamen, die Dateiendung, den berechneten neuen Namen, den Auswahlstatus und den Validierungsstatus. Darauf wird eine Regelkette angewendet. Jede Regel transformiert nur den bearbeitbaren Namensteil, standardmäßig ohne Erweiterung.

Vor dem Umbenennen wird das Ergebnis validiert. Dazu gehören insbesondere leere Namen, doppelte Zielnamen im selben Ordner, unzulässige Zeichen, versehentliche Entfernung der Dateiendung, bestehende Zieldateien und fehlende Schreibrechte.

**8. Nichtfunktionale Anforderungen**

**•** Native macOS-App mit Swift und SwiftUI.

**•** Schnelle Reaktion der Live-Vorschau auch bei größeren Dateimengen.

**•** Zuverlässige Verarbeitung ohne stillschweigende Überschreibungen.

**•** Klare Fehlermeldungen in verständlicher Sprache.

**•** Lokale Verarbeitung ohne Cloud-Abhängigkeit.

**9. Technische Empfehlung**

Für die Umsetzung ist eine native macOS-App mit Swift und SwiftUI die beste Wahl. Das passt zur Plattform, ermöglicht eine moderne Oberfläche, unterstützt Drag-and-Drop sauber und vereinfacht den Zugriff auf Dateisystemfunktionen. Eine Web- oder Electron-Lösung wäre nur dann sinnvoll, wenn bereits ein starkes Web-Entwicklungsteam vorhanden wäre. Für dieses Produkt überwiegen jedoch die Vorteile einer nativen Lösung.

**•** UI-Layer: SwiftUI

**•** Dateioperationen: FileManager / URL-basierte Verarbeitung

**•** Regelmodell: klar gekapselte Transformationsschritte

**•** Persistenz für Presets: lokal, leichtgewichtig, z. B. JSON oder UserDefaults je nach Komplexität

**10. Empfohlene Modulstruktur**

|   |   |
|---|---|
|**Modul**|**Aufgabe**|
|**FileImportService**|Import von Dateien und optional Ordnern, inklusive Drag-and-Drop.|
|**RenameRule**|Abstraktion einzelner Regeln wie Ersetzen, Präfix, Nummerierung oder Bereinigung.|
|**RenamePipeline**|Anwendung der Regeln in definierter Reihenfolge.|
|**PreviewEngine**|Berechnung der Vorher-/Nachher-Ansicht in Echtzeit.|
|**ValidationService**|Prüfung auf Konflikte, unzulässige Zeichen und Dubletten.|
|**RenameExecutor**|Kontrolliertes tatsächliches Umbenennen auf Dateisystemebene.|
|**PresetStore**|Speichern und Laden wiederverwendbarer Regelsets.|

**11. MVP-Definition**

Das Minimum Viable Product sollte nicht versuchen, alle denkbaren Sonderfälle abzudecken. Ziel ist eine erste Version, die in typischen Alltagsfällen sofort nützlich ist und ein hohes Sicherheitsgefühl vermittelt.

**•** Dateien per Drag-and-Drop hinzufügen

**•** Dateiliste mit Auswahl je Datei

**•** Live-Vorschau Vorher/Nachher

**•** Finden und Ersetzen

**•** Präfix / Suffix

**•** Text einfügen

**•** Nummerierung

**•** Zeichen entfernen

**•** Groß-/Kleinschreibung

**•** Windows-Kompatibilität

**•** Konfliktprüfung und blockiertes Anwenden bei Fehlern

**•** Presets speichern und wiederverwenden

**12. Roadmap**

|   |   |   |
|---|---|---|
|**Phase**|**Ziel**|**Inhalt**|
|1|**Konzept**|Produktkern, Zielgruppe, MVP und UI-Logik definieren.|
|2|**UX-Entwurf**|Fensteraufbau, Regelkarten, Vorschau und Fehlerzustände skizzieren.|
|3|**Prototyp**|Drag-and-Drop, 2–3 Regeln und Live-Vorschau implementieren.|
|4|**MVP**|Erste vollständig nutzbare Version mit Konfliktprüfung und Presets.|
|5|**Ausbau**|Regex, Wildcards, Undo, Finder-Integration, Speziallogiken.|

**13. Risiken und Gegenmaßnahmen**

**•** Zu großer Funktionsumfang zu früh: Gegenmaßnahme ist eine harte MVP-Grenze.

**•** Überfordernde Oberfläche: Gegenmaßnahme ist die Trennung in Einfach- und Profi-Modus.

**•** Unsichere Dateioperationen: Gegenmaßnahme ist eine strenge Validierung vor dem Anwenden.

**•** Manipulation von Dateiendungen: Gegenmaßnahme ist ein geschützter Standardmodus ohne Erweiterungsbearbeitung.

**•** Unklare Reihenfolge von Regeln: Gegenmaßnahme ist eine sichtbare, veränderbare Pipeline.

**14. Offene Entscheidungen**

**•** Soll die App nur Dateien innerhalb eines Fensters verarbeiten oder auch komplette Ordner rekursiv einlesen können?

**•** Soll es in einer späteren Version ein echtes Undo geben oder zunächst nur ein Änderungsprotokoll?

**•** Sollen Presets lokal pro Benutzer gespeichert werden oder zusätzlich exportierbar sein?

**•** Soll der Fokus langfristig auf maximaler Einfachheit bleiben oder soll ein optionaler Profi-Modus systematisch ausgebaut werden?

|   |
|---|
|**Empfehlung: Zuerst einen UX-/Funktions-Prototyp mit Live-Vorschau, Drag-and-Drop und drei Kernregeln bauen. Erst wenn die Bedienung klar und sicher wirkt, den Funktionsumfang schrittweise erweitern.**|

_Erstellt für die weitere Produkt- und Umsetzungsplanung_