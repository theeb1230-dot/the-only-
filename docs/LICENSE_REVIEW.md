# Source License / Reuse Gate

This document is a technical compliance gate, not legal advice.

## Policy
Public availability is not permission to redistribute or incorporate code. Until a source's license text is inspected at the archived exact SHA and its obligations are recorded, its code status is `REFERENCE_ONLY`.

| Source capability | Archived input | Status | Allowed now |
|---|---|---|---|
| Cinema application | Cinema-HQ | REFERENCE_ONLY | inspect behavior/interfaces only |
| Metadata/embed providers | TMDB-Embed-API | REFERENCE_ONLY | inspect behavior/interfaces only |
| Python provider/resolver set | PyEmbed-Api | REFERENCE_ONLY | inspect behavior/interfaces only |
| IPTV/M3U/XCAPI/EPG | M3U-XCAPI-EPG-IPTV-Stremio | REFERENCE_ONLY | inspect behavior/interfaces only |
| URL resolution | ResolveURL | REFERENCE_ONLY | inspect behavior/interfaces only |
| Android/ADB tooling | Electron-ADB-ToolKit | OUT_OF_PRODUCT | archive/reference only |
| Desktop/hardware projects | DeskEngine, XStat, Rainity projects | OUT_OF_PRODUCT | archive/reference only |
| Other archived projects | remaining archive entries | REFERENCE_ONLY | no code migration until classified |

## Required evidence before code migration
For each candidate source record: exact archived SHA, license filename/text, SPDX identifier when determinable, copyright/notice obligations, redistribution/modification conditions, dependency-license concerns, and final `CLEARED` or `BLOCKED` decision.

Fail closed: missing or ambiguous license means no code copying. Independent implementation against documented/public behavior remains separate work and must not reproduce protected source expression.
