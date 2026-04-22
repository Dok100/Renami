# GitHub Publish

Fuer Renami ist das Ziel-Repository bereits angelegt:

- `https://github.com/Dok100/Renami`

## Standardablauf

1. lokales Git-Repository initialisieren
2. Remote `origin` auf GitHub setzen
3. ersten Commit erstellen
4. Branch `main` pushen

## Beispiel

```bash
git init
git remote add origin https://github.com/Dok100/Renami.git
git add .
git commit -m "Initialer Projektstand"
git branch -M main
git push -u origin main
```

## Vor dem ersten Push

- `README.md`, `SECURITY.md` und `docs/brief.md` angepasst
- `.gitignore` deckt Xcode-, Swift- und lokale Build-Artefakte ab
- keine echten Secrets im Repository
- `.env` nicht mitgestaged
- `make precommit` ist erfolgreich gelaufen

## GitHub-Basis im Repository

- CI: `.github/workflows/ci.yml`
- CodeQL: `.github/workflows/codeql.yml`
- Dependabot: `.github/dependabot.yml`
- Issue Templates: `.github/ISSUE_TEMPLATE/`
- Pull-Request-Vorlage: `.github/pull_request_template.md`
- Code Ownership: `.github/CODEOWNERS`
