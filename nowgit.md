# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | Doze |
| **Git URL** | git@github.com:asunnyboy861/Doze.git |
| **Repo URL** | https://github.com/asunnyboy861/Doze |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from /docs folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/Doze/ | ✅ Active |
| Support | https://asunnyboy861.github.io/Doze/support.html | ✅ Active |
| Privacy Policy | https://asunnyboy861.github.io/Doze/privacy.html | ✅ Active |
| Terms of Use | https://asunnyboy861.github.io/Doze/terms.html | ✅ Active |

**Note**: Terms of Use required for IAP subscription apps.

## Repository Structure

### Main App Repository
```
Doze/
├── Doze/                        # iOS App Source Code
│   ├── Doze.xcodeproj/          # Xcode Project
│   ├── Doze/                    # Swift Source Files
│   │   ├── Models/
│   │   ├── Views/
│   │   ├── Services/
│   │   ├── Components/
│   │   ├── Extensions/
│   │   └── ...
│   └── ...
├── docs/                        # Policy Pages for GitHub Pages
│   ├── index.html
│   ├── support.html
│   ├── privacy.html
│   └── terms.html
├── .github/workflows/           # GitHub Actions
│   └── deploy.yml               # Deploys /docs to GitHub Pages
├── us.md                        # English Development Guide
├── keytext.md                   # App Store Metadata
├── capabilities.md              # Capabilities Configuration
├── icon.md                      # App Icon Details
├── price.md                     # Pricing Configuration
└── nowgit.md                    # This File
```

## Deployment Information

- **GitHub Pages Source**: `/docs` folder on `main` branch
- **Deployment Method**: GitHub Actions (automatic on push to main)
- **Last Deployment**: 2026-05-02
- **Workflow File**: `.github/workflows/deploy.yml`
