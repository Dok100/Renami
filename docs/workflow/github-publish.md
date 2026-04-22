# GitHub Publish

Fuer Renami ist das Ziel-Repository bereits angelegt:

- `https://github.com/Dok100/Renami`

## Standardablauf fuer laufende Arbeit

1. lokalen Arbeitsstand pruefen
2. Dokumentation und Feature-Status bei Bedarf aktualisieren
3. lokale Checks ausfuehren
4. Commit erstellen
5. Branch nach `origin` pushen

## Empfohlene Befehle

```bash
make precommit
git status
git add .
git commit -m "Kurz und praezise beschreiben"
git push
```

## Erster Push oder neues Setup

- lokales Git-Repository initialisieren
- Remote `origin` auf GitHub setzen
- `README.md`, `SECURITY.md` und `docs/brief.md` an den echten Projektstand anpassen
- `.gitignore` deckt Xcode-, Swift- und lokale Build-Artefakte ab
- keine echten Secrets im Repository
- `.env` nicht mitgestaged
- `make precommit` ist erfolgreich gelaufen

Beispiel:

```bash
git init
git remote add origin https://github.com/Dok100/Renami.git
git add .
git commit -m "Initialer Projektstand"
git branch -M main
git push -u origin main
```

## Vor jedem Push

- `features/INDEX.md` spiegelt den echten Status wider
- `README.md` beschreibt keine bereits ueberholten Einschraenkungen mehr
- relevante Feature-Dateien und Betriebsdokumente sind mitgezogen
- lokaler Testlauf ist gruen
- Arbeitsbaum ist verstanden; keine unbeabsichtigten Dateien werden mitcommittet

## GitHub-Basis im Repository

- CI: `.github/workflows/ci.yml`
- CodeQL: `.github/workflows/codeql.yml`
- Dependabot: `.github/dependabot.yml`
- Issue Templates: `.github/ISSUE_TEMPLATE/`
- Pull-Request-Vorlage: `.github/pull_request_template.md`
- Code Ownership: `.github/CODEOWNERS`
