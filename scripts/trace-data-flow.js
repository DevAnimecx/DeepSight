#!/usr/bin/env node
/**
 * DeepSight Data Flow Tracer — Cross-file dependency analysis.
 * Usage: node trace-data-flow.js --from routes.ts --to sanitize --direction both
 *
 * Traces data flow between files/functions to verify security boundaries.
 */

const { execSync, execFileSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const args = process.argv.slice(2);
const params = {};

for (let i = 0; i < args.length; i++) {
    if (args[i].startsWith("--")) {
        const key = args[i].slice(2);
        params[key] = args[i + 1] !== undefined && !args[i + 1].startsWith("--") ? args[i + 1] : true;
        if (params[key] === true) i++;
    }
}

const { from = ".", to, direction = "both", maxDepth = 5 } = params;

if (!to) {
    console.error("Error: --to parameter is required (function/module name to trace)");
    process.exit(1);
}

const extensions = [".ts", ".js", ".tsx", ".jsx", ".py", ".php", ".rb", ".go"];
const extPattern = extensions.map(e => `--include=*${e}`).join(" ");

function grep(pattern, dir = from) {
    try {
        const result = execFileSync("grep", [
            "-rn",
            ...extPattern.split(" "),
            pattern,
            dir
        ], { encoding: "utf8", stdio: ["pipe", "pipe", "pipe"] });
        return result.split("\n").filter(line => line.trim() && !line.includes("node_modules") && !line.includes("vendor") && !line.includes(".git"));
    } catch {
        return [];
    }
}

function glob(pattern, dir = from) {
    try {
        const result = execFileSync("find", [dir, ...extPattern.split(" "), "-name", pattern], { encoding: "utf8" });
        return result.split("\n").filter(f => f.trim());
    } catch {
        return [];
    }
}

console.log(`=== DeepSight Data Flow Trace ===`);
console.log(`From: ${from}`);
console.log(`To: ${to}`);
console.log(`Direction: ${direction}`);
console.log(`Max depth: ${maxDepth}`);
console.log("");

// Trace imports/requires pointing to the target
const importPatterns = [
    new RegExp(`(import|require|from|using)\\s+.*${to.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}`, "i"),
    new RegExp(`require\\(['"]${to.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}['"]\\)`, "i"),
];

const traces = [];
let currentDepth = 0;
let searchPaths = [from];

while (currentDepth < maxDepth && searchPaths.length > 0) {
    const currentPath = searchPaths.shift();
    const found = [];

    // Search for imports of the target module
    for (const ext of extensions) {
        const files = glob(`*${ext}`, currentPath);
        for (const file of files) {
            try {
                const content = fs.readFileSync(file, "utf8");
                for (const pattern of importPatterns) {
                    const matches = content.match(pattern);
                    if (matches) {
                        found.push({ file, match: matches[0] });
                    }
                }
            } catch { /* skip unreadable files */ }
        }
    }

    if (found.length > 0) {
        traces.push({ depth: currentDepth, path: currentPath, imports: found });
        // Add found files for next iteration (for transitive tracing)
        for (const f of found) {
            const dir = path.dirname(f.file);
            if (!searchPaths.includes(dir)) {
                searchPaths.push(dir);
            }
        }
    }

    currentDepth++;
}

// Output results
console.log(`--- Trace Results (${traces.length} hops) ---`);
for (const trace of traces) {
    console.log(`\n[Depth ${trace.depth}] ${trace.path}`);
    for (const imp of trace.imports) {
        console.log(`  → ${imp.file}: ${imp.match.trim()}`);
    }
}

if (traces.length === 0) {
    console.log("No import traces found. The target module may not be imported directly.");
    console.log("Try searching for function/method calls instead:");
    console.log(`  grep -rn "${to}" ${from}`);
}

// Summary
console.log(`\n--- Summary ---`);
console.log(`Files importing "${to}": ${traces.reduce((sum, t) => sum + t.imports.length, 0)}`);
console.log(`Trace depth reached: ${traces.length > 0 ? traces.length - 1 : 0}`);

if (traces.length === 0 && direction === "both") {
    // Also search for function calls
    console.log(`\nSearching for direct function calls...`);
    const calls = grep(`\\b${to}\\s*\\(`, from);
    if (calls.length > 0) {
        console.log(`Found ${calls.length} call sites:`);
        calls.forEach(c => console.log(`  ${c}`));
    }
}
