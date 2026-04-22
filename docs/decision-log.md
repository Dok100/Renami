# Decision Log

### 2026-04-21 - Renami wird als native SwiftUI-macOS-App umgesetzt

- Kontext: Das Repository startet als generisches Projekt-Framework und enthaelt mehrere Stack-Profile. Das Produktziel ist ein nativer macOS-Datei-Umbenenner mit Live-Vorschau.
- Entscheidung: Der Projekt-Root wird auf das `swift-macos`-Profil ausgerichtet. SwiftUI bildet die Oberflaeche, Foundation die Datei- und Regelverarbeitung, AppKit wird nur fuer native Dateiauswahl verwendet.
- Alternativen: Weiterarbeit als generisches Framework; Electron/Web-App; Hybrid-Prototyp ohne Root-Umstellung.
- Auswirkungen: Das Repository wird direkt baubar und testbar als macOS-App. Makefile, Projektdateien und CI orientieren sich ab jetzt an macOS.

### 2026-04-21 - Vorschau und Validierung sind Kern der Architektur

- Kontext: Das Produkt soll bewusst einfacher und sicherer sein als stark funktionsgeladene Konkurrenz.
- Entscheidung: Die Anwendung wird um eine zentrale Preview-Pipeline aufgebaut. Regeln transformieren nur den bearbeitbaren Namensteil; eine separate Validierung blockiert unsichere Operationen vor der Ausfuehrung.
- Alternativen: direkte Mutation ohne vorgelagerte Vorschau; Validierung nur beim finalen Rename.
- Auswirkungen: Mehr Klarheit in UI und Code, zusaetzlicher Modellierungsaufwand fuer `PreviewItem` und `ValidationIssue`.

### 2026-04-21 - MVP-Regeln werden klein, benannt und erweiterbar modelliert

- Kontext: Das Produkt braucht mehrere Standardregeln, soll aber nicht in ein fruehes komplexes Plugin-System kippen.
- Entscheidung: Regeln werden als leichtgewichtige, aktivierbare Domaintypen mit gemeinsamer Ausfuehrung modelliert. Das schafft Erweiterbarkeit ohne separate Runtime oder Skript-Engine.
- Alternativen: Pro Regel eigene View-spezifische Sonderlogik; generische JSON-Interpreter; fruehes Protocol/Type-Erasure-Setup fuer jede Komponente.
- Auswirkungen: Schneller MVP-Aufbau, spaeter problemlos erweiterbar um weitere Regeltypen und Presets.
