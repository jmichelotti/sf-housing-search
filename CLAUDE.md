# sf-housing-search

An automated housing search agent that runs on a schedule to find the best rental listings in San Francisco meeting specific requirements, tracks them over time, and maintains a persistent record of active and expired listings.

## Mission

Find and track the best rental housing available in San Francisco that meets the requirements below. On each run, check previously found listings to see if they are still active, mark removed ones, and search for new listings. Write all findings to `listings.md`.

## Search Modes

Two modes are active. Both run every session and are tracked in separate sections of `listings.md`.

- **Solo mode** — housing for one person under $2,000/month.
- **Group mode** — 3BR apartments or houses with 2+ bathrooms under $5,000/month.

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

Run **both** the solo and group search blocks every session. Apply the Income-Restriction Filter to every find from either block.

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
- Update the status accordingly: ACTIVE, PRICE CHANGED, REMOVED, or RENTED
- Note the date of the status change

### Step 3 — Search for new listings

Run **both** the solo and group searches listed above. For each promising find:
- **Confirm the listing is actually available before adding it** — apply the same verification checks from Step 2.
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

### Step 4 — Update listings.md

Write the updated file with all changes from this session. See format below.

**Caps are per-mode:**
- **Solo Active Listings:** capped at 20 entries.
- **Group Active Listings:** capped at 10 entries.

If a session would push either mode above its cap, archive the weakest current listings within that mode (worst value, most red flags, oldest without verification, etc.) until the mode is at or below its cap. Below the cap is fine — do not pad with weak listings. Use removal reason `"Pruned — cap reached, weaker than alternatives"` for cap-driven removals. The two modes' caps are independent; do not prune a solo listing because of a group find or vice versa.

### Step 5 — Rank all active listings

After all updates, assign rankings **separately within each mode** (solo and group each have their own 1..N). Ranking criteria, in rough priority order:
1. Price (lower is better, all else equal)
2. How well it matches requirements (confirmed > ambiguous)
3. Location quality and commute convenience
4. Amenities (parking, dishwasher, AC, etc.)
5. Listing quality (more photos, detailed description, responsive poster)
6. Posting freshness (newer listings ranked higher, all else equal)

The ranking order must match the order of listings within each mode's Active Listings section of `listings.md` — best deal at the top of each section = rank 1 for that mode.

### Step 6 — Print a session summary

After updating the file, print a brief summary to the terminal:
- Active listing count **per mode** (e.g. "Solo: 18 active / cap 20. Group: 4 active / cap 10.")
- Any new listings found this session (call out which mode)
- Any listings that were removed since last run (and why)
- Any listings with price changes
- The single best current listing **per mode** and why

This summary is also the required final output. Do not end the run silently — print the summary as plain text after all file updates are complete.

## listings.md Format

```markdown
# SF Housing Search
Last updated: [DATE TIME]
Total runs: [N]

## Best Current Listings
- **Solo:** [one-line description + reason]
- **Group (3BR/3BA):** [one-line description + reason]

## Active Listings — Solo (cap 20)

### [TITLE] — $[PRICE]/mo — [SOURCE]
- **Rank:** [1..N within solo]
- **Mode:** Solo
- **Status:** ACTIVE
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
- Do not leave browser tabs open between searches
- Do not cache or reuse listing data from prior runs without re-verifying via URL visit
- Do not create code files, plan documents, or anything other than `listings.md`
- Do not commit or push git during a session
- Do not re-add listings from the Expired section — if a listing was removed and reappears, note it as "relisted" in the Active section but with the original first-found date
- Do not mix the two modes' listings in a single Active Listings section — always keep solo and group separate, with their own rankings and caps
