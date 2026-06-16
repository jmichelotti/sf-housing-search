# sf-housing-search

An automated housing search agent that runs on a schedule to find the best rental listings in San Francisco meeting specific requirements, tracks them over time, and maintains a persistent record of active and expired listings.

## Mission

Find and track the best rental housing available in San Francisco that meets the requirements below. On each run, check previously found listings to see if they are still active, mark removed ones, and search for new listings. Write all findings to `listings.md`.

## Search Modes

- **Solo mode** — housing for one person under $2,000/month. **ACTIVE — run every session.**
- **Group mode** — 3BR apartments or houses with 2+ bathrooms under $5,000/month. **⏸ PAUSED as of 2026-06-15.** The qualifying market is too thin to justify the run cost (~12 listings surfaced in the prior 6.5 weeks, almost all flagged as scams or out of budget). **While paused:** do NOT run the group search block and do NOT add new group listings. Continue to re-verify any group listings still marked ACTIVE in `listings.md` until they expire naturally, then leave the Group section empty. To resume, change this line back to ACTIVE and re-enable the group search block in "What to Search Each Run."

## Income-Restriction Filter (applies to BOTH modes)

The user's income is **$100k+/year**, which disqualifies them from most income-restricted housing. Apply this filter to every listing in either mode:

- **Reject any listing whose published max income cap for a 1-person household is below $100,000/year.** This covers most BMR, MOHCD, AMI-tier (30%, 50%, 60%, 80% AMI), Mercy Housing, Brightwell, Madonna Residences, and similar income-restricted units.
- Listings labeled "120% AMI" or higher *may* still qualify — only include if the listing's stated 1-person max income clearly exceeds $100k.
- If a listing is income-restricted but does not publish its 1-person income cap, **skip it** (assume disqualifying).
- Use the rejection reason `"Income-restricted — household income exceeds cap"` when moving such a listing to Expired.

## Requirements

### Solo mode (studios / 1BR / rooms / in-laws)

**Must meet ALL of the following:**

- Monthly rent: under $2,000
- Location: San Francisco, within accepted neighborhoods only (see Geographic Filter below)
- Private bathroom — this is non-negotiable. Shared bathrooms are an automatic rejection, no matter how good the price or location. For rooms in shared housing, the listing must explicitly state private bath or en-suite.
- In-unit or on-site laundry — washer/dryer in the unit OR shared laundry facilities in the building. "Laundromat nearby" does not count.
- Kitchen in the unit — must have its own kitchen (or kitchenette at minimum). A shared communal kitchen does not count.
- Passes the Income-Restriction Filter above.

**Acceptable housing types:**
- Studios
- 1-bedroom apartments
- Rooms in shared housing (must have private bathroom)
- In-law units / ADUs / backyard cottages / basement apartments

### Group mode (3BR, 2+ bath)

**Must meet ALL of the following:**

- Monthly rent: under $5,000
- Location: San Francisco, within accepted neighborhoods only (same Geographic Filter as solo mode)
- **3 bedrooms** — must be a true 3BR (not 2BR + den, not "convertible", not 2BR loft marketed as 3)
- **2 or more bathrooms** — at least 2 full baths anywhere in the unit. They do NOT need to be en-suite. 1.5 baths or fewer is a reject. 1BA-only 3BR units are a reject. Half-baths count toward the total only if there are also at least 2 full baths (e.g. 2.5BA is OK; 1.5BA is not).
- In-unit or on-site laundry — same rule as solo mode
- Kitchen in the unit — same rule as solo mode (group mode will almost always have a full kitchen, but verify)
- Passes the Income-Restriction Filter above.

**Acceptable housing types:**
- 3BR apartments / condos / flats (2+ bath)
- Single-family houses (3BR, 2+ bath)
- Townhouses (3BR, 2+ bath)
- Full-floor flats in multi-unit buildings (3BR, 2+ bath)

### Nice-to-have for both modes (track but don't require)
- Parking (included, available for extra, or street only)
- Dishwasher
- Air conditioning
- Pet-friendly
- Furnished
- Natural light / outdoor space

## Geographic Filter

Only add listings located in the neighborhoods listed below. **Every listing must have its neighborhood verified before being added to the tracker.** Never add a listing with an unknown or unverifiable location.

**How to determine neighborhood:**
1. Check if the listing states the neighborhood or address explicitly in the title or body.
2. **Extract coordinates from the page.** Craigslist embeds lat/lng in the HTML — use `browser_evaluate` to extract them. Example JS to run:
   ```js
   (() => {
     const map = document.querySelector('#map');
     if (map) return { lat: map.dataset.latitude, lng: map.dataset.longitude };
     const meta = document.querySelector('meta[name="geo.position"]');
     if (meta) return { raw: meta.content };
     return null;
   })()
   ```
   Facebook Marketplace also shows map pins with extractable coordinates. **This extraction is mandatory for every listing — never skip it.**
3. Use the extracted coordinates to determine the neighborhood. As a rough guide for the south boundary: most accepted neighborhoods are north of ~37.745 latitude. The Mission extends to ~37.74, Twin Peaks to ~37.75. Anything below ~37.735 is almost certainly in a rejected neighborhood.
4. If you cannot determine the neighborhood from any of these methods, **skip the listing** — do not add it.

**Accepted neighborhoods:**

North SF:
- Presidio / Sea Cliff
- Richmond (Inner / Central / Outer)
- Marina / Cow Hollow
- Pacific Heights / Laurel Heights
- Russian Hill / Nob Hill / Telegraph Hill
- North Beach / Fisherman's Wharf
- Chinatown / Financial District

Central SF:
- Inner Sunset / Golden Gate Heights
- Cole Valley / Haight-Ashbury
- NoPa (North of Panhandle) / Western Addition
- Hayes Valley / Civic Center
- SoMa / South Beach
- Castro / Duboce Triangle / Eureka Valley
- Noe Valley
- Mission District
- Potrero Hill / Dogpatch

South-Central SF (selective):
- Twin Peaks

**Rejected neighborhoods (do not add listings from these areas):**
- Tenderloin / Civic Center — anything in the area bounded by Geary (north), Mason (east), Market (south), Larkin (west) is Tenderloin and rejected, **regardless of how the listing self-labels.** Listings often market TL units as "Lower Nob Hill" or "Union Square" — verify with coordinates. Rule of thumb: if an address is south of Geary and east of Larkin (roughly lat < 37.787 between lng -122.418 and -122.408), treat it as Tenderloin.
- Central Sunset / Parkside
- Outer Sunset / Outer Parkside
- Diamond Heights / Glen Park
- Bernal Heights
- Bayview / Hunters Point
- Ingleside / Oceanview
- Excelsior / Outer Mission
- Visitacion Valley / Portola
- Crocker-Amazon / Balboa Park

## What to Search Each Run

Run the **solo** search block every session. **The group search block is PAUSED (see Search Modes) — skip it.** Apply the Income-Restriction Filter to every find.

### Solo searches

#### Craigslist SF Bay Area — solo

Search the apartments/housing section (`https://sfbay.craigslist.org/search/sfc/apa`) with these parameters:
- Max price: $2,000
- Area: San Francisco only (use the `sfc` subarea)
- Search terms (run multiple searches):
  - "studio private bath"
  - "1br laundry"
  - "in-law unit"
  - "ADU"
  - "room private bathroom"
  - "studio laundry"
  - "1 bedroom"
  - "garden unit"
  - "basement apartment"

Also browse the rooms/shared section (`https://sfbay.craigslist.org/search/sfc/roo`) with max price $2,000 and search for "private bath" or "private bathroom" or "en suite".

#### Facebook Marketplace SF — solo

**Facebook Marketplace does NOT require login to browse listings.** Use the Playwright MCP to navigate directly to these URLs. Do not skip Facebook Marketplace — it is a required search source every run.

Start by navigating to the property rentals category for San Francisco:
`https://www.facebook.com/marketplace/sanfrancisco/propertyrentals/?maxPrice=2000`

If that URL doesn't load results, try the general search approach — navigate to:
`https://www.facebook.com/marketplace/sanfrancisco/search/?query=apartment%20for%20rent`

Then also search with these queries (replace the query parameter):
- `studio for rent`
- `1 bedroom for rent`
- `room for rent private bath`
- `in-law unit for rent`

### Group searches (3BR, 2+ bath, max $5,000)

> **⏸ PAUSED as of 2026-06-15 — skip this entire block.** Retained for easy resume. To re-enable, set Group mode back to ACTIVE in Search Modes and remove this banner.

#### Craigslist SF Bay Area — group

Search the apartments/housing section (`https://sfbay.craigslist.org/search/sfc/apa`) with these parameters:
- **Max price: $5,000**
- **Min bedrooms: 3** (use the `minBedrooms=3` parameter, e.g. `https://sfbay.craigslist.org/search/sfc/apa?minBedrooms=3&max_price=5000`)
- Area: San Francisco only (`sfc` subarea)
- Search terms (run multiple searches):
  - "3 bedroom 3 bath"
  - "3br 3ba"
  - "3 bedroom"
  - "house for rent"
  - "townhouse"
  - "full floor flat"
  - "3br"

Also browse the housing/all section without a keyword (just the minBedrooms=3 + max_price=5000 filter) to catch listings that don't use the exact "3BR/3BA" phrasing in the title.

#### Facebook Marketplace SF — group

Navigate to property rentals with the higher cap:
`https://www.facebook.com/marketplace/sanfrancisco/propertyrentals/?maxPrice=5000&minBedrooms=3`

Then also search with these queries:
- `3 bedroom for rent`
- `3 bedroom 3 bath`
- `house for rent san francisco`
- `townhouse for rent`

For each search, scroll down to load more results and extract listings. Apply the appropriate mode's requirements (solo: $2k cap + private bath; group: $5k cap + 3BR/3BA + Income-Restriction Filter) and coordinate verification as before.

If Facebook shows a login wall or CAPTCHA that blocks browsing, note it in the session summary as "Facebook Marketplace blocked — [reason]" and continue with Craigslist results. But attempt it every run — the block may be intermittent.

## How to Run a Session

Each session must follow these steps in order:

### Step 1 — Read the current state

Read `listings.md` in full. Note all active listings, their URLs, prices, and date first found. Note all previously expired/removed listings so you don't re-add them.

If `listings.md` does not exist (first run), create it with the format specified below, with empty Active Listings and Search History sections.

### Step 2 — Check existing active listings

For each listing currently marked ACTIVE in `listings.md`:
- Visit the URL using the Playwright MCP
- Determine if the listing is still live, price has changed, or has been removed/rented
- **Re-verify the neighborhood.** If the listing's Location field says "not listed" or lacks a confirmed neighborhood, extract the coordinates now (see Geographic Filter section) and determine the neighborhood. If the listing is in a rejected neighborhood, move it to Expired with reason "Location verified — rejected neighborhood."
- **Verify the listing is actually available, not just that the URL loads.** Use `browser_evaluate` on the rendered page to check:
  - **Craigslist:** The post body and "reply" button must be present. A "this posting has been deleted by its author" / "this posting has expired" / "flagged for removal" page means the listing is dead.
  - **Facebook Marketplace:** The listing must still render with price and "Message" button. "Sold" overlays, "This listing isn't available" messages, or redirects to the Marketplace home mean it's gone.
- If the page loads but the listing is no longer available, set status to `REMOVED` (or `RENTED` if the page explicitly says rented/pending) and move to the Expired section.
- **Promote survivors.** If a listing currently marked `PROBATION` is still live this run, it has survived its probation window — change its Status to `ACTIVE` (now eligible for rank 1 / Best). If a `QUARANTINED` listing is still live AND its below-market price now has a verified legitimate explanation, promote it to `ACTIVE`; if it is still live but the discount remains unexplained, keep it `QUARANTINED`.
- Update the status accordingly: ACTIVE, PROBATION, QUARANTINED, PRICE CHANGED, REMOVED, or RENTED
- Note the date of the status change

### Step 3 — Search for new listings

Run the **solo** searches listed above (group mode is paused — skip the group search block). For each promising find:
- **Confirm the listing is actually available before adding it** — apply the same verification checks from Step 2.
- **Check it against the repeat-scam blocklist** (below). If it is tied to a blocklisted operator or address, skip it.
- **First, identify which mode it belongs to** (solo or group) based on its size and price, then apply that mode's hard requirements:
  - **Solo:** price under $2,000/mo; private bathroom; in-unit or on-site laundry; in-unit kitchen; accepted neighborhood.
  - **Group:** price under $5,000/mo; **3 bedrooms**; **2 or more bathrooms** (do not need to be en-suite); in-unit or on-site laundry; in-unit kitchen; accepted neighborhood.
- **Apply the Income-Restriction Filter to every listing in either mode.** If the listing is income-restricted and its 1-person max income cap is below $100,000/year (or the cap is not published), skip it.
- If a listing is ambiguous about private bathroom (solo), bathroom count is missing or unclear (group, needs 2+), laundry, or kitchen (not mentioned either way), note the ambiguity but DO NOT add it to the tracker. Only add listings where these requirements are confirmed.
- Extract all trackable details (see listing format below) and add the listing to the matching mode's section.
- Only add if it's a real listing worth tracking — do not pad with low-quality or suspicious entries.

**Scam detection — flag or skip these:**
- No photos, or only 1-2 stock/generic photos
- Price significantly below market for the area and type (e.g., a 1BR in Nob Hill for $800)
- Duplicate postings (same photos/text reposted under different accounts)
- Poster has no history or the posting uses a generic email relay with suspicious language
- Listing asks for money before viewing, demands wire transfer, or says landlord is "overseas"
- Text is copied from another legitimate listing (compare against already-tracked listings)
- Refuses live video call or in-person showing under "respecting current tenant's privacy" pretext and offers only a pre-recorded virtual tour (classic scam script — privacy framing is the tell)
- Charges an upfront application fee paid directly to a personal Gmail address rather than via a screening service (SmartMove, RentSpree, AppFolio); legit landlords/PMs almost never collect fees this way
- Multi-URL aggressive reposting from the same individual landlord (e.g. 3+ simultaneous CL URLs for the same address) combined with any of the above

**Known repeat-scam operators / addresses — auto-skip (do not add, no matter how good the listing looks):**

These have been confirmed across multiple runs as serial scam / batch-spam posters or chronically re-flagged relisters. Skip any listing tied to them on sight, and never feature them:
- **Palm Breeze / Palm Breeze Executive Leasing** (also seen paired with "City Lights Realty / Fred")
- **Marinas Property Group** (CalDRE BK#34488-12 / CA DRE 01927702)
- **2245 Larkin St** (Russian Hill) — confirmed scam address, recycled under many titles/URLs
- **1645 Irving St** (Inner Sunset) — chronic same-day re-flag/relist cycle

When a session confirms a NEW repeat-scam operator or address (same entity flagged/removed across 2+ runs, or a batch-poster matching the scam-detection pattern above), append it to this list so future runs skip it automatically. Note: legitimate property managers such as **Meridian Management Group (Yoli Handoko / MMG)** are NOT scammers — their listings simply rent quickly; do not blocklist them.

**Price-Anomaly Quarantine — a low price is the #1 scam tell, not a green light:**

Scam bait is deliberately priced far below market, which is exactly why below-market listings keep auto-sorting to the top of the rankings and then getting flagged within hours. For every find, benchmark the rent against the typical market rate for that neighborhood + unit type:
- If the rent is **≥30% below** the typical market rate for the neighborhood and type, treat it as a **price anomaly**.
- A price-anomaly listing may still be added to its mode's Active section, but its **Status must be `QUARANTINED`**, and it is **ineligible for the top tier**: never name it "Best Current Listing" and never rank it in the top 3, no matter how cheap it is.
- Promote a quarantined listing to a normal rank only when BOTH are true: (a) it survives the probation window below (still live on a later run), AND (b) the steep discount has a verified legitimate explanation (confirmed rent-controlled unit, verified owner/PM, documented reason). If it gets flagged/removed first (the usual outcome), move it straight to Expired with reason `"Price anomaly — flagged/removed before verification (suspected scam)"`.
- The cheaper a listing is relative to market, the MORE scrutiny it gets, not less. A discount alone is never enough to make a listing the headline.

**New-Listing Probation — do not crown a listing that hasn't survived:**

Roughly half of every listing this tracker has ever found vanished within 24 hours of discovery (most flagged by Craigslist as scams). A listing found *this run* has not yet proven it is real, so it cannot be the headline pick yet:
- Any listing added for the first time this session starts with **Status `PROBATION`**.
- A PROBATION listing is tracked and ranked within its section but is **ineligible to be the "Best Current Listing"** for its mode and **may not occupy rank 1**. It is a candidate, not a confirmed pick.
- On a later run (Step 2), when the listing is re-verified and confirmed still live (survived ≥1 verification cycle, i.e. it appears in a subsequent run), promote it from `PROBATION` to `ACTIVE`. Only `ACTIVE` listings are eligible to be Best / rank 1.
- A listing that is both new and a price anomaly is `QUARANTINED` (the stricter state), not `PROBATION`.

### Step 4 — Update listings.md

Write the updated file with all changes from this session. See format below.

**Caps are per-mode:**
- **Solo Active Listings:** capped at 20 entries.
- **Group Active Listings:** capped at 10 entries.

If a session would push either mode above its cap, archive the weakest current listings within that mode (worst value, most red flags, oldest without verification, etc.) until the mode is at or below its cap. Below the cap is fine — do not pad with weak listings. Use removal reason `"Pruned — cap reached, weaker than alternatives"` for cap-driven removals. The two modes' caps are independent; do not prune a solo listing because of a group find or vice versa.

### Step 5 — Rank all active listings

After all updates, assign rankings **separately within each mode** (each mode has its own 1..N; group is currently paused, so in practice this is solo only).

**Eligibility gate — apply this BEFORE ranking by the criteria below:**
- `QUARANTINED` (price-anomaly) and `PROBATION` (new-this-run) listings may **not** be ranked #1 and may **not** be named "Best Current Listing." Sort them *below* every confirmed `ACTIVE` listing, then order them among themselves by the criteria below. This is the fix for below-market scam bait auto-winning a price-first sort and headlining the report before it has survived verification.
- Rank the confirmed `ACTIVE` tier first (these are the only listings eligible for rank 1 / Best), then the probation/quarantine tier beneath them.

Ranking criteria within a tier, in rough priority order:
1. Price (lower is better, all else equal — but an implausibly below-market price is a scam signal, not a winner; see Price-Anomaly Quarantine)
2. How well it matches requirements (confirmed > ambiguous)
3. Location quality and commute convenience
4. Amenities (parking, dishwasher, AC, etc.)
5. Listing quality (more photos, detailed description, responsive poster)
6. Posting freshness (newer listings ranked higher, all else equal)

The ranking order must match the order of listings within each mode's Active Listings section of `listings.md` — best deal at the top of each section = rank 1 for that mode.

### Step 6 — Print a session summary

After updating the file, print a brief summary to the terminal:
- Active listing count for solo, **broken out by tier** (e.g. "Solo: 9 confirmed ACTIVE + 3 PROBATION + 1 QUARANTINED / cap 20."). State "Group: PAUSED" — do not report group counts or a group best.
- Any new listings found this session, and which tier they landed in (PROBATION, or QUARANTINED with the discount that triggered it)
- Any listings promoted from PROBATION/QUARANTINED to confirmed ACTIVE this run
- Any listings that were removed since last run (and why — distinguish "flagged/removed (suspected scam)" from "deleted by author (likely rented)")
- Any listings with price changes
- The single best current listing for solo and why — **must be a confirmed `ACTIVE` listing**, never one still on PROBATION or QUARANTINE

This summary is also the required final output. Do not end the run silently — print the summary as plain text after all file updates are complete.

## listings.md Format

```markdown
# SF Housing Search
Last updated: [DATE TIME]
Total runs: [N]

## Best Current Listings
- **Solo:** [one-line description + reason — must be a confirmed ACTIVE listing, never one still on PROBATION or QUARANTINE]
- **Group (3BR/3BA):** PAUSED — see Search Modes

## Active Listings — Solo (cap 20)

### [TITLE] — $[PRICE]/mo — [SOURCE]
- **Rank:** [1..N within solo]
- **Mode:** Solo
- **Status:** ACTIVE / PROBATION / QUARANTINED
- **URL:** [url]
- **First found:** [date]
- **Last verified:** [date]
- **Type:** [Studio / 1BR / Room / In-law / ADU]
- **Location:** [neighborhood, cross streets or address if available]
- **Size:** [sq ft if listed, "not listed" otherwise]
- **BR/BA:** [e.g. 1BR/1BA, Studio/1BA]
- **Rent:** $[amount]/mo
- **Deposit:** [amount if listed, "not listed" otherwise]
- **Lease:** [term if listed — month-to-month, 1 year, etc.]
- **Available:** [move-in date if listed]
- **Laundry:** [in-unit / on-site shared / not listed]
- **Parking:** [included / available for $X / street only / not listed]
- **Pet policy:** [cats OK / dogs OK / no pets / not listed]
- **Other amenities:** [dishwasher, AC, furnished, yard, etc.]
- **Photos:** [count, brief quality note]
- **Posting age:** [days since posted or date posted]
- **Poster:** [name if available, any legitimacy notes]
- **Income-restricted?:** [No, or "Yes — 1-person cap $X" if explicitly verified above $100k]
- **vs. market:** [brief benchmark — e.g. "avg studio in Sunset is $1,800, this is $1,650 = good deal"]
- **Notes:** [red flags, standout features, anything worth noting]

---

## Active Listings — Group 3BR/2+BA (cap 10)

### [TITLE] — $[PRICE]/mo — [SOURCE]
- **Rank:** [1..N within group]
- **Mode:** Group
- **Status:** ACTIVE
- **URL:** [url]
- **First found:** [date]
- **Last verified:** [date]
- **Type:** [Apartment / Condo / House / Townhouse / Full-floor flat]
- **Location:** [neighborhood, cross streets or address if available]
- **Size:** [sq ft if listed, "not listed" otherwise]
- **BR/BA:** 3BR/[2|2.5|3]BA (confirmed bath count)
- **Rent:** $[amount]/mo
- **Deposit:** [amount if listed, "not listed" otherwise]
- **Lease:** [term if listed — month-to-month, 1 year, etc.]
- **Available:** [move-in date if listed]
- **Laundry:** [in-unit / on-site shared / not listed]
- **Parking:** [included / available for $X / street only / not listed]
- **Pet policy:** [cats OK / dogs OK / no pets / not listed]
- **Other amenities:** [dishwasher, AC, furnished, yard, garage, etc.]
- **Photos:** [count, brief quality note]
- **Posting age:** [days since posted or date posted]
- **Poster:** [name if available, any legitimacy notes]
- **Income-restricted?:** [No, or "Yes — 1-person cap $X" if explicitly verified above $100k]
- **vs. market:** [brief benchmark vs typical 3BR/3BA in that neighborhood]
- **Notes:** [red flags, standout features, anything worth noting]

---

## Expired / No Longer Available

### [TITLE] — $[PRICE]/mo — [SOURCE]
- **Mode:** [Solo / Group]
- **Status:** REMOVED / RENTED / EXPIRED / PRICE CHANGED / INCOME-RESTRICTED
- **URL:** [url]
- **First found:** [date]
- **Removed:** [date]
- **Notes:** [reason for removal]

---

## Search History
| Run | Date | Solo new | Group new | Removed | Best Solo | Best Group |
|-----|------|----------|-----------|---------|-----------|------------|
| 1   | [date] | [n] | [n] | [n] | [title] | [title] |
```

## Tooling Notes

- **Default tool for all web searches is the Playwright MCP.** Use it for Craigslist, Facebook Marketplace, and all listing verification.
- **Use `browser_evaluate` to extract structured listing data** from pages — do not rely solely on snapshots for data extraction, they are too large and imprecise.
- **Verify listing status by visiting the URL directly** — do not assume a listing is still active from a prior run.
- **Close browser tabs when done** with each search source to keep memory usage down.
- **Do not create any files other than `listings.md`** — no plan documents, no sub-READMEs, no code files.
- **Do not commit or push to git from inside a tracking session** — the session is automated and unattended. Git commits happen manually via the user's `/ucp` command. Never stage, commit, or push from within a scheduled run.
- **Logging:** `run-tracker.sh` writes session output to two log files. `tracker-log.txt` is the master log (all runs, appended with timestamped separators). `tracker-latest.txt` is overwritten each run with only the latest session output. Both are gitignored.

## Report Writing

- Be honest about thin markets — "found nothing new this run" is a valid and useful result
- Flag listings that have been sitting more than 2 weeks — may indicate an issue or room to negotiate
- Show price comparisons against typical market rates for the neighborhood and type
- Note if a listing was reposted (same content, new URL)
- Call out standout features or unusual red flags explicitly

## What NOT to Do

- Do not add listings that don't confirm private bathroom (solo) or 2+ bath count (group), laundry, and kitchen — ambiguous is not good enough
- **Do not add income-restricted listings whose 1-person max income cap is below $100,000/year** (or whose cap is not published). The user is voided out of these. This applies in both solo and group modes.
- Do not pad the tracker with weak listings that barely meet requirements
- **Do not name as "Best" or rank #1 any listing still on PROBATION or QUARANTINE** — only confirmed ACTIVE listings are eligible
- **Do not add any listing tied to a blocklisted repeat-scam operator or address** (see the blocklist in Step 3), no matter how good it looks
- **Do not treat a far-below-market price as a positive** — it is a scam signal; quarantine it per the Price-Anomaly Quarantine rule
- **Do not run the group search block or add group listings while group mode is paused** (see Search Modes)
- Do not leave browser tabs open between searches
- Do not cache or reuse listing data from prior runs without re-verifying via URL visit
- Do not create code files, plan documents, or anything other than `listings.md`
- Do not commit or push git during a session
- Do not re-add listings from the Expired section — if a listing was removed and reappears, note it as "relisted" in the Active section but with the original first-found date
- Do not mix the two modes' listings in a single Active Listings section — always keep solo and group separate, with their own rankings and caps
