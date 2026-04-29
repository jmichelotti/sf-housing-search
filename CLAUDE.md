# sf-housing-search

An automated housing search agent that runs on a schedule to find the best rental listings in San Francisco meeting specific requirements, tracks them over time, and maintains a persistent record of active and expired listings.

## Mission

Find and track the best rental housing available in San Francisco that meets the requirements below. On each run, check previously found listings to see if they are still active, mark removed ones, and search for new listings. Write all findings to `listings.md`.

## Search Mode

**Solo mode** (active now): Find housing for one person under $2,000/month.

<!-- Future: 3-person mode — $5,500/month budget, 3BR, 2+ bath. Not yet active. -->

## Requirements

**Must meet ALL of the following:**

- Monthly rent: under $2,000
- Location: San Francisco, within accepted neighborhoods only (see Geographic Filter below)
- Private bathroom — this is non-negotiable. Shared bathrooms are an automatic rejection, no matter how good the price or location. For rooms in shared housing, the listing must explicitly state private bath or en-suite.
- In-unit or on-site laundry — washer/dryer in the unit OR shared laundry facilities in the building. "Laundromat nearby" does not count.
- Kitchen in the unit — must have its own kitchen (or kitchenette at minimum). A shared communal kitchen does not count.

**Acceptable housing types:**
- Studios
- 1-bedroom apartments
- Rooms in shared housing (must have private bathroom)
- In-law units / ADUs / backyard cottages / basement apartments

**Nice-to-have (track but don't require):**
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

### Craigslist SF Bay Area

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

### Facebook Marketplace SF

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

For each search, scroll down to load more results and extract listings. Apply the same requirements filter (price under $2,000, SF location, private bath, laundry, kitchen) and coordinate verification as Craigslist listings.

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

Run the searches listed above. For each promising find:
- **Confirm the listing is actually available before adding it** — apply the same verification checks from Step 2.
- **Verify it meets ALL hard requirements:**
  - Price under $2,000/month
  - Private bathroom (explicitly stated or clearly shown in photos/description)
  - In-unit or on-site laundry (explicitly stated)
  - Kitchen in the unit (own kitchen or kitchenette, not shared communal)
  - Located in an accepted neighborhood (see Geographic Filter below)
- If a listing is ambiguous about private bathroom, laundry, or kitchen (not mentioned either way), note the ambiguity but DO NOT add it to the tracker. Only add listings where these requirements are confirmed.
- Extract all trackable details (see listing format below)
- Only add if it's a real listing worth tracking — do not pad with low-quality or suspicious entries

**Scam detection — flag or skip these:**
- No photos, or only 1-2 stock/generic photos
- Price significantly below market for the area and type (e.g., a 1BR in Nob Hill for $800)
- Duplicate postings (same photos/text reposted under different accounts)
- Poster has no history or the posting uses a generic email relay with suspicious language
- Listing asks for money before viewing, demands wire transfer, or says landlord is "overseas"
- Text is copied from another legitimate listing (compare against already-tracked listings)

### Step 4 — Update listings.md

Write the updated file with all changes from this session. See format below.

**Cap the Active Listings section at 20 entries.** If a session would push the active count above 20, archive the weakest current listings (worst value, most red flags, oldest without verification, etc.) until exactly 20 remain. Below 20 is fine — do not pad with weak listings. Use removal reason like "Pruned — top 20 cap, weaker than alternatives" for cap-driven removals.

### Step 5 — Rank all active listings

After all updates, assign a ranking to every active listing (1 = best, N = worst). Ranking criteria, in rough priority order:
1. Price (lower is better, all else equal)
2. How well it matches requirements (confirmed private bath + laundry > ambiguous)
3. Location quality and commute convenience
4. Amenities (parking, dishwasher, AC, etc.)
5. Listing quality (more photos, detailed description, responsive poster)
6. Posting freshness (newer listings ranked higher, all else equal)

The ranking order must match the order of listings in the Active Listings section of `listings.md` — best deal at the top = rank 1.

### Step 6 — Print a session summary

After updating the file, print a brief summary to the terminal:
- How many active listings are currently tracked
- Any new listings found this session
- Any listings that were removed since last run
- Any listings with price changes
- The single best current listing and why

## listings.md Format

```markdown
# SF Housing Search
Last updated: [DATE TIME]
Total runs: [N]

## Best Current Listing
[Single best listing with one-line reason why]

## Active Listings

### [TITLE] — $[PRICE]/mo — [SOURCE]
- **Rank:** [1..N]
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
- **vs. market:** [brief benchmark — e.g. "avg studio in Sunset is $1,800, this is $1,650 = good deal"]
- **Notes:** [red flags, standout features, anything worth noting]

---

## Expired / No Longer Available

### [TITLE] — $[PRICE]/mo — [SOURCE]
- **Status:** REMOVED / RENTED / EXPIRED / PRICE CHANGED
- **URL:** [url]
- **First found:** [date]
- **Removed:** [date]
- **Notes:** [reason for removal]

---

## Search History
| Run | Date | New Finds | Removed | Best Listing |
|-----|------|-----------|---------|--------------|
| 1   | [date] | [n] | [n] | [listing title] |
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

- Do not add listings that don't confirm private bathroom, laundry, and kitchen — ambiguous is not good enough
- Do not pad the tracker with weak listings that barely meet requirements
- Do not leave browser tabs open between searches
- Do not cache or reuse listing data from prior runs without re-verifying via URL visit
- Do not create code files, plan documents, or anything other than `listings.md`
- Do not commit or push git during a session
- Do not re-add listings from the Expired section — if a listing was removed and reappears, note it as "relisted" in the Active section but with the original first-found date
