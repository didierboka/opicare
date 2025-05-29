#!/usr/bin/env node

const fs = require('fs');
const { execSync } = require('child_process');

// Configuration - SYNCHRONISÉE avec .githooks/commit-msg
const CHANGELOG_FILE = 'CHANGELOG.md';
const REPO_URL = 'https://github.com/didierboka/opicare';

// Types autorisés - MÊME LISTE que dans .githooks/commit-msg
const ALLOWED_TYPES = ['feat', 'fix', 'perf', 'refactor', 'style', 'test', 'docs', 'build', 'ci', 'chore'];

// Regex IDENTIQUE à celle du hook
const COMMIT_REGEX = /^(feat|fix|perf|refactor|style|test|docs|build|ci|chore)(\(.+\))?: .{1,50}/;

// Headers du changelog
const HEADER = `# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
et ce projet suit la spécification [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

`;

// Mapping des types de commits vers les sections Keep a Changelog
const COMMIT_TYPE_MAP = {
  feat: 'Added',      // Nouvelles fonctionnalités
  fix: 'Fixed',       // Corrections de bugs
  perf: 'Changed',    // Améliorations de performances
  refactor: 'Changed', // Refactorisation
  style: 'Changed',   // Changements UI/style
  docs: 'Changed',    // Documentation
  test: 'Changed',    // Tests
  build: 'Changed',   // Système de build
  ci: 'Changed',      // CI/CD
  chore: 'Changed',   // Maintenance
  revert: 'Fixed'     // Annulation de commits
};

function getCommitsSinceLastTag() {
  try {
    const lastTag = execSync('git describe --tags --abbrev=0', { encoding: 'utf8' }).trim();
    const commits = execSync(`git log ${lastTag}..HEAD --pretty=format:"%s|%H"`, { encoding: 'utf8' });
    return commits.split('\n').filter(line => line.trim());
  } catch (error) {
    // Pas de tags, récupère tous les commits
    const commits = execSync('git log --pretty=format:"%s|%H"', { encoding: 'utf8' });
    return commits.split('\n').filter(line => line.trim());
  }
}

function validateAndParseCommit(commitLine) {
  const [message, hash] = commitLine.split('|');
  const shortHash = hash.substring(0, 7);

  // Validation avec la MÊME regex que le hook
  if (!COMMIT_REGEX.test(message)) {
    console.warn(`⚠️  Commit ignoré (format invalide): ${message} (${shortHash})`);
    return null;
  }

  // Parse conventional commit: type(scope): description
  const match = message.match(/^(\w+)(?:\(([^)]+)\))?: (.+)$/);

  if (!match) {
    console.warn(`⚠️  Commit ignoré (parsing failed): ${message} (${shortHash})`);
    return null;
  }

  const type = match[1];

  // Vérification supplémentaire que le type est autorisé
  if (!ALLOWED_TYPES.includes(type)) {
    console.warn(`⚠️  Commit ignoré (type non autorisé): ${type} dans ${message} (${shortHash})`);
    return null;
  }

  return {
    type: type,
    scope: match[2] || '',
    description: match[3],
    hash: shortHash,
    fullMessage: message
  };
}

function groupCommitsByType(commits) {
  const groups = {
    Added: [],
    Changed: [],
    Fixed: [],
    Removed: []
  };

  let validCommits = 0;
  let skippedCommits = 0;

  commits.forEach(commit => {
    const parsed = validateAndParseCommit(commit);

    if (!parsed) {
      skippedCommits++;
      return;
    }

    validCommits++;
    const section = COMMIT_TYPE_MAP[parsed.type] || 'Changed';

    const scopeText = parsed.scope ? `**${parsed.scope}**: ` : '';
    const commitUrl = `${REPO_URL}/commit/${parsed.hash}`;
    const line = `- ${scopeText}${parsed.description} ([${parsed.hash}](${commitUrl}))`;

    groups[section].push(line);
  });

  console.log(`✅ ${validCommits} commits valides traités`);
  if (skippedCommits > 0) {
    console.log(`⚠️  ${skippedCommits} commits ignorés (format invalide)`);
  }

  return groups;
}

function generateChangelog() {
  console.log('🚀 Génération du changelog...');

  const commits = getCommitsSinceLastTag();

  if (commits.length === 0) {
    console.log('ℹ️  Aucun nouveau commit trouvé');
    return;
  }

  console.log(`📝 Analyse de ${commits.length} commits...`);

  const groups = groupCommitsByType(commits);
  const date = new Date().toISOString().split('T')[0];

  let changelog = HEADER;

  // Section Unreleased
  changelog += '## [Unreleased]\n';

  // Ordre des sections selon Keep a Changelog
  const sectionOrder = ['Added', 'Changed', 'Fixed', 'Removed'];

  sectionOrder.forEach(section => {
    const items = groups[section];
    if (items && items.length > 0) {
      changelog += `### ${section}\n`;
      items.forEach(item => {
        changelog += `${item}\n`;
      });
      changelog += '\n';
    }
  });

  // Lire l'ancien changelog s'il existe
  let existingContent = '';
  if (fs.existsSync(CHANGELOG_FILE)) {
    existingContent = fs.readFileSync(CHANGELOG_FILE, 'utf8');
    // Enlever le header et la section Unreleased
    const lines = existingContent.split('\n');
    const firstVersionIndex = lines.findIndex(line => line.match(/^## \[\d+\.\d+\.\d+\]/));
    if (firstVersionIndex > -1) {
      existingContent = '\n' + lines.slice(firstVersionIndex).join('\n');
    } else {
      existingContent = '';
    }
  }

  changelog += existingContent;

  fs.writeFileSync(CHANGELOG_FILE, changelog);
  console.log(`✅ Changelog généré dans ${CHANGELOG_FILE}`);
}

// Fonction pour valider la cohérence avec le hook
function validateHookConsistency() {
  const hookFile = '.githooks/commit-msg';

  if (!fs.existsSync(hookFile)) {
    console.warn('⚠️  Hook .githooks/commit-msg non trouvé');
    return;
  }

  const hookContent = fs.readFileSync(hookFile, 'utf8');

  // Vérifier que les types sont les mêmes
  const hookTypesMatch = hookContent.match(/\(([^)]+)\)/);
  if (hookTypesMatch) {
    const hookTypes = hookTypesMatch[1].split('|');
    const missingTypes = ALLOWED_TYPES.filter(type => !hookTypes.includes(type));
    const extraTypes = hookTypes.filter(type => !ALLOWED_TYPES.includes(type));

    if (missingTypes.length > 0 || extraTypes.length > 0) {
      console.warn('⚠️  Types de commits non synchronisés entre le hook et le script !');
      if (missingTypes.length > 0) {
        console.warn(`   Types manquants dans le hook: ${missingTypes.join(', ')}`);
      }
      if (extraTypes.length > 0) {
        console.warn(`   Types en trop dans le hook: ${extraTypes.join(', ')}`);
      }
    } else {
      console.log('✅ Types de commits synchronisés avec le hook');
    }
  }
}

// Exécuter
console.log('🔍 Vérification de la cohérence avec le hook...');
validateHookConsistency();
console.log('');
generateChangelog();