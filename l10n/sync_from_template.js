#!/usr/bin/env node
/**
 * Syncs translations_template.json into ARB files.
 * Maps: new → newLabel, continue → continueButton
 * Preserves @availableToCurrencyPair and @appTitle metadata.
 */
const fs = require('fs');
const path = require('path');

const TEMPLATE_PATH = path.join(__dirname, 'translations_template.json');
const LOCALES = ['en', 'ko', 'vi', 'pt'];
const KEY_MAP = { new: 'newLabel', continue: 'continueButton' };

const template = JSON.parse(fs.readFileSync(TEMPLATE_PATH, 'utf8'));

function templateKeyToArbKey(key) {
  return KEY_MAP[key] ?? key;
}

function buildArb(locale) {
  const arbPath = path.join(__dirname, `app_${locale}.arb`);
  const existing = fs.existsSync(arbPath)
    ? JSON.parse(fs.readFileSync(arbPath, 'utf8'))
    : {};

  const arb = {
    '@@locale': locale,
    ...(locale === 'en' && { '@appTitle': { description: 'Application title' } }),
    '@availableToCurrencyPair': {
      placeholders: { currency: { type: 'String' } },
    },
    '@upToPercent': {
      placeholders: { percent: { type: 'String' } },
    },
  };

  for (const [templateKey, value] of Object.entries(template)) {
    const arbKey = templateKeyToArbKey(templateKey);
    const str = value[locale];
    if (str !== undefined) {
      arb[arbKey] = str;
    }
  }

  // Preserve keys in existing ARB that aren't in template
  for (const [k, v] of Object.entries(existing)) {
    if (k.startsWith('@') || k === '@@locale') continue;
    if (arb[k] === undefined) arb[k] = v;
  }

  return arb;
}

function writeArb(locale, arb) {
  const filename = `app_${locale}.arb`;
  const filepath = path.join(__dirname, filename);
  const json = JSON.stringify(arb, null, 2);
  fs.writeFileSync(filepath, json + '\n', 'utf8');
  console.log(`Wrote ${filename}`);
}

for (const locale of LOCALES) {
  const arb = buildArb(locale);
  writeArb(locale, arb);
}

console.log('Done.');
