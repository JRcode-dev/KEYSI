---
name: Expo 58 runtime and package setup
description: Runtime and Replit package-firewall observations for this Expo and React Native version.
---

For this project’s Expo SDK 58 / React Native 0.88 stack, Replit’s Node 20 environment emitted engine warnings; Node 22 was available and allowed the web export. The package firewall rejected the locked `shell-quote` 1.8.3 transitively through React Native’s devtools dependency as a critical CVE; the approved latest version 1.12.0 installed and stayed transitive after removing the temporary direct dependency.

**Why:** Restoring the imported lockfile initially failed before verification could run, and using Node 20 was below the stack’s declared engine requirement.

**How to apply:** When setting up this Expo version, use Node 22 or newer. If the package firewall rejects a vulnerable transitive lockfile version, follow package-management guidance to resolve an approved compatible version; do not bypass the firewall or keep an unnecessary direct dependency. For a Replit Expo web workflow, prefix the start command with `BROWSER=none` so headless Linux does not attempt `xdg-open` and terminate the process.
