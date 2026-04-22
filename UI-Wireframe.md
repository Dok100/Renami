**UI-Wireframe-Konzept  
**macOS-App zum Umbenennen von Dateien

**Ziel:** ein ruhiges, sehr verständliches App-Fenster mit Live-Vorschau, klarer Regel-Logik und sicherem Anwenden.

|                                                                                                                                                                                   |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Leitprinzipien: 1) Vorschau steht im Zentrum  2) Regeln sind sprachlich verständlich  3) Konflikte werden sichtbar blockiert  4) Standardfälle zuerst, Expertenfunktionen separat |
|                                                                                                                                                                                   |

**1. Hauptfenster – Desktop-Wireframe**

|   |   |   |
|---|---|---|
|Titelzeile  <br>App-Name \| Preset wählen \| Suche \| Hilfe|Titelzeile  <br>App-Name \| Preset wählen \| Suche \| Hilfe|Titelzeile  <br>App-Name \| Preset wählen \| Suche \| Hilfe|
|Dateiquellen  <br>• Dateien hinzufügen  <br>• Ordner hinzufügen  <br>• Drag & Drop  <br>• Auswahl filtern|Regelbereich  <br>• Finden & Ersetzen  <br>• Präfix / Suffix  <br>• Text einfügen  <br>• Nummerierung  <br>• Zeichen entfernen  <br>• Schreibweise  <br>• Windows-kompatibel|Live-Vorschau  <br>Vorher → Nachher  <br>Statusspalte  <br>Konflikte farbig markiert|
|Dateiliste  <br>☑ Datei A.pdf  <br>☑ Datei B.jpg  <br>☐ Datei C.docx  <br>Sortierung / Auswahl|Regeldetails  <br>Eingabefelder, Schalter,  <br>Positionswahl, Testdaten,  <br>Reihenfolge der Regeln|Validierung  <br>• Dubletten  <br>• Ungültige Zeichen  <br>• Zu langer Name  <br>• Gesperrte Datei|
|Fußleiste links  <br>Anzahl Dateien  <br>Aktive Auswahl|Fußleiste Mitte  <br>Konflikte: 2  <br>Änderungen: 18|Fußleiste rechts  <br>Vorschau aktualisiert  <br>[Anwenden] [Abbrechen]|
|Optional einklappbar  <br>Ordnerstruktur / Pfade|Optional Profi-Modus  <br>Regex / Wildcards|Optional Protokoll  <br>Erfolg / Fehler / Undo|

**Empfohlene Fensterlogik:** links Auswahl, in der Mitte Bearbeitung, rechts Wirkung. So kann der Nutzer Ursache und Ergebnis direkt nebeneinander erfassen.

**2. Fensterbereiche im Detail**

Die Titelleiste bleibt bewusst schlank. Links steht der App-Name, daneben ein Preset-Menü. In der Mitte kann später eine kleine Suche oder Filterung sitzen. Rechts genügen Hilfe, Einstellungen und ein Profi-Schalter.

Die linke Spalte dient ausschließlich der Dateiauswahl. Dort werden Dateien oder Ordner aufgenommen, einzelne Dateien an- und abgewählt und bei Bedarf nach Typ oder Namen gefiltert. Die mittlere Spalte ist der eigentliche Regel-Editor. Dort werden Regeln als klar benannte Karten dargestellt. Die rechte Spalte zeigt ausschließlich die Live-Vorschau und Validierung. Diese Trennung sorgt für Ruhe und verhindert, dass sich Eingabe und Ergebnis vermischen.

**3. Interaktionsfluss**

Schritt 1: Dateien oder Ordner per Drag-and-Drop hineinziehen.  
Schritt 2: Eine Regel auswählen oder ein Preset laden.  
Schritt 3: Parameter der Regel bearbeiten.  
Schritt 4: Sofortige Aktualisierung der Vorschau.  
Schritt 5: Konflikte prüfen und problematische Dateien bei Bedarf deaktivieren.  
Schritt 6: Änderungen anwenden.

**4. Wireframe für die Regelkarten**

Jede Regelkarte sollte denselben Aufbau haben: Überschrift, kurze Beschreibung, Eingabefelder, Vorschau-Hinweis und ein Schalter zum Aktivieren oder Deaktivieren. Unter der Karte kann optional eine Mini-Zeile stehen wie: „Wirkt auf 24 von 31 Dateien“. Dadurch bleibt verständlich, welche Regel gerade welchen Effekt hat.

Beispielkarten: „Text ersetzen“, „Präfix / Suffix“, „Nummerierung“, „Zeichen entfernen“, „Schreibweise ändern“, „Windows-Kompatibilität“. Regex und Wildcards gehören nicht in die Standardansicht, sondern in einen einklappbaren Profi-Bereich.

**5. Validierung und Sicherheitszone**

Die rechte Vorschau-Spalte sollte oberhalb eine kompakte Statusleiste haben: Anzahl Dateien, geänderte Namen, Konflikte, blockierte Aktionen. Darunter folgt die eigentliche Vorher-Nachher-Liste. Jede problematische Zeile wird farblich markiert und mit einer knappen Ursache versehen, etwa „Doppelter Zielname“ oder „Ungültiges Zeichen“.

Der Anwenden-Button bleibt deaktiviert, solange kritische Konflikte vorliegen. Das ist nicht nur technisch sauber, sondern Teil der UX.

**6. Sinnvolle Zustände**

Leerer Zustand: große Drag-and-Drop-Fläche mit kurzer Erklärung.  
Arbeitszustand: dreispaltiges Layout mit Dateiliste, Regeln und Vorschau.  
Fehlerzustand: gut lesbare Meldungen mit konkreter Ursache.  
Erfolgszustand: kurze Bestätigung mit Zahl der umbenannten Dateien und optionalem Protokoll.

**7. Empfehlungen für das visuelle Design**

Für macOS passt eine ruhige, helle Oberfläche mit klaren Abständen, dezenten Trennlinien und wenigen Akzentfarben. Keine überladene Symbolik. Die wichtigste Akzentfarbe sollte nur für aktive Elemente, Statushinweise und den Anwenden-Button verwendet werden. Konflikte erscheinen in Gelb oder Rot, erfolgreiche Prüfungen in Grün.

Die Typografie sollte sehr nüchtern bleiben: deutliche Bereichsüberschriften, kompakte Tabellenzeilen, ausreichend Weißraum. Das Produkt gewinnt hier über Klarheit, nicht über visuelle Effekte.

**8. Empfehlung für V1**

Für die erste Version sollte das Fenster bereits vollständig so strukturiert sein, auch wenn noch nicht jede Funktion aktiv ist. Das spart spätere Umbauten. Für V1 reichen Dateiliste, 5 bis 7 Regelkarten, Live-Vorschau, Konfliktprüfung, Presets und Anwenden. Ein Profi-Bereich für Regex und Wildcards kann im Layout bereits vorgesehen, aber zunächst deaktiviert sein.