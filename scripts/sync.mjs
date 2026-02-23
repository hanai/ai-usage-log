#!/usr/bin/env node
import { execSync } from 'node:child_process'
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs'
import os from 'node:os'
import path from 'node:path'

const dataDir = path.join(os.homedir(), '.ai-usage-log')

const device = process.env.AI_USAGE_DEVICE
if (!device) {
	console.error('Error: AI_USAGE_DEVICE environment variable is not set')
	console.error('Example: AI_USAGE_DEVICE=macbook-pro node scripts/sync.mjs')
	process.exit(1)
}

console.log(`Device: ${device}`)
console.log('Fetching ccusage data...')

const raw = execSync('npx -y @hanai/ccusage@latest daily --json', { encoding: 'utf-8' })
const { daily } = JSON.parse(raw)

console.log(`Fetched ${daily.length} daily entries`)

// Group modelBreakdowns by month -> date
const byMonth = new Map()
for (const entry of daily) {
	if (!entry.modelBreakdowns?.length) continue
	const month = entry.date.slice(0, 7).replace('-', '') // "2026-02-01" -> "202602"
	if (!byMonth.has(month)) byMonth.set(month, new Map())
	byMonth.get(month).set(entry.date, entry.modelBreakdowns)
}

const ccDir = path.join(dataDir, 'cc', device)
if (!existsSync(ccDir)) mkdirSync(ccDir, { recursive: true })

for (const [month, newEntries] of byMonth) {
	const filePath = path.join(ccDir, `${month}.json`)

	let existing = {}
	if (existsSync(filePath)) {
		existing = JSON.parse(readFileSync(filePath, 'utf-8'))
	}

	const merged = { ...existing }

	for (const [date, newBreakdowns] of newEntries) {
		const oldByModel = new Map((existing[date] ?? []).map((b) => [b.modelName, b]))
		for (const breakdown of newBreakdowns) {
			oldByModel.set(breakdown.modelName, breakdown)
		}
		merged[date] = Array.from(oldByModel.values())
	}

	const sorted = Object.fromEntries(Object.entries(merged).sort(([a], [b]) => a.localeCompare(b)))
	writeFileSync(filePath, JSON.stringify(sorted, null, 2) + '\n')
	console.log(`  ✓ cc/${device}/${month}.json`)
}

console.log('Done.')
