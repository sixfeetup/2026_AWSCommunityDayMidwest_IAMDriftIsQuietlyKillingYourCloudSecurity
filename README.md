# IAM Drift Is Quietly Killing Your Cloud Security

## 🎤 Talk Summary

**IAM Drift Is Quietly Killing Your Cloud Security** is a presentation for **AWS Community Day Midwest 2026** by
**Calvin Hendryx-Parker, CTO at Six Feet Up**.

The talk explains why identity and access management drift is one of the easiest cloud security risks to miss:
permissions grow, identities are forgotten, MFA gaps appear, and manual audits only capture a moment in time. It
shows how **Cloud Custodian (C7N)** can turn IAM hygiene into repeatable policy-as-code across AWS, Azure, and GCP.

## 🧭 What the Talk Covers

- 🔐 **IAM hygiene across clouds**: why AWS, Azure, and GCP need a holistic governance approach.
- 🛡️ **MFA gaps**: detecting users without strong authentication before accounts are compromised.
- 🧹 **Orphaned identities**: finding and removing unused roles, stale service account keys, and forgotten access paths.
- 💥 **Overly permissive access**: reducing blast radius from wildcard policies and broad owner assignments.
- 📋 **Compliance controls**: mapping IAM checks to benchmarks such as CIS Microsoft Azure Foundations and NIST SP 800-53.
- 🤖 **Automated remediation**: evolving from detection and notification to trusted, event-driven enforcement.

## ✨ Core Message

Cloud security does not fail only through dramatic breaches. It also erodes quietly when identity controls drift away
from what the organization intended. This deck makes the case for starting small, detecting high-confidence IAM issues,
tuning the signal, and then automating remediation once teams trust the policy.

## 🗂️ Repository Contents

- `slides.md` - the source content for the talk.
- `index.html` - the Reveal.js presentation entry point.
- `themes/` - custom presentation themes.
- `images/` - visual assets used by the deck.
- `Makefile` - helper targets for building and running the presentation.

## 📜 License

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br />
This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons
Attribution-ShareAlike 4.0 International License</a>.

## 🚀 Build this Presentation

### 🧰 Build Dependencies

- nvm
- pandoc
- bsdtar (part of the `libarchive-tools` package on Ubuntu)

Make sure that your working directory is set up to use the LTS version of Node before you begin. Then build the
presentation with `make`.

```bash
$ nvm install --lts
$ make start
```
