#!/usr/bin/env node

const fs = require('fs');
const { execSync } = require('child_process');

// Script pour créer une release depuis [Unreleased]
function createRelease(version) {
  const CHANGELOG_FILE = 'CHANGELOG.md';

  if (!fs.existsSync(CHANGELOG_FILE)) {
    console.error('❌ CHANGELOG.md non trouvé');
    process.exit(1);
  }

  const content = fs.readFileSync(CHANGELOG_FILE, 'utf8');
  const date = new Date().toISOString().split('T')[0];

  // Remplacer [Unreleased] par la version
  const updatedContent = content.replace(
    /## \[Unreleased\]/,
    `## [Unreleased]

## [${version}] – ${date}`
  );

  // Si aucun changement trouvé, créer une nouvelle section
  if (updatedContent === content) {
    console.error('❌ Section [Unreleased] non trouvée dans CHANGELOG.md');
    process.exit(1);
  }

  fs.writeFileSync(CHANGELOG_FILE, updatedContent);
  console.log(`✅ Release ${version} créée dans CHANGELOG.md`);
}

// Récupérer la version depuis la ligne de commande
const version = process.argv[2];

if (!version) {
  console.error('❌ Usage: node scripts/create-release.js <version>');
  console.error('   Exemple: node scripts/create-release.js 1.0.0');
  process.exit(1);
}

// Validation du format de version (semantic versioning)
if (!/^\d+\.\d+\.\d+$/.test(version)) {
  console.error('❌ Format de version invalide. Utilise: X.Y.Z (ex: 1.0.0)');
  process.exit(1);
}

createRelease(version);