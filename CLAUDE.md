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
- **Relobe Real Estate / Metro SF Housing Advisors** (DRE 020 58 474 — spaced digits, invalid license format) — batch-poster flooding CL with $700–$1,300 Nob Hill/Russian Hill listings; "send me your number" script; confirmed Run 191–192
- **Golden Gate Rental Properties / Marcus R. Sterling** (DRE "01 52.21 60" — spaced digits, invalid CA license format) — batch-poster flooding CL with AI-generated identical body text and $29+$85-fee application structure across many SF addresses; 3+ simultaneous URLs per address; confirmed across Runs 211–212. Also operates as **"Zolden Gate Rental Properties Group / Wuthorized Broker Marchus R Sterling"** (DRE "01 52.21.60" and "01.88.73.21" — same invalid dotted format, deliberate misspellings); confirmed alias Run 243 ($1,530 batch at lat 37.763, Inner Sunset — auto-skipped)
- **"$35 app / $200 admin-holding fee" + "Send your phone number" batch operator** (no DRE identified) — flooding CL simultaneously with AI-generated body text under varied neighborhood titles (Lower Pacific Heights, North Beach, Russian Hill, Noe Valley, Cow Hollow, etc.); all listings share identical CL attrs (1BR/1Ba, monthly, cats+dogs OK, w/d in unit, off-street parking, AC, EV charging); closing script: "Interested? ⬤ Send your phone number to schedule a viewing today"; confirmed Run 220 (5+ simultaneous listings same day)
- **1710 Larkin St** (Nob Hill) — confirmed repeat-scam address; flagged/removed 3+ times across Runs 158 (URL 7939717360), 222 (URL 7943170257 — flagged by CL), 223 (2 simultaneous new URLs 856azLWduseaU5ffZMzdSc and 4aupiok9ZPbhd7FKEjocMT both at $1,987, identical coords 37.793558/-122.419597), and 226 (3rd simultaneous URL bSvn2DEzG8brmMHyQyGxCT $1,987, same Nob Hill 500sqft pattern); auto-skip all future listings at this address regardless of listing appearance
- **Madera Valley Property Management / Broker Joseph S. Greenblatt** (license formats "01.06.44.15" / "00.9278.50" — dotted non-standard CA DRE format) — massive batch-scam wave confirmed Run 226, flooding ALL accepted SF neighborhoods with identical AI-generated body text featuring "cherry-tinted floorboards" phrasing; bizarre data-literal titles ("Habitable Zone Overview: Living Quarters, Structural Additions", "Suite Specifications: Interior Finishes, On-Site Amenities, and Lease", "Urban Living Data: Spatial Layout, Building Infrastructure, and Cost"); identical open house dates across all listings; "w/d hookups" not confirmed in-unit laundry; closing script: "Send your phone number if you're ready to take the next step." — auto-skip any listing citing either name/license regardless of neighborhood or price. Also operates as **"Sarah M Evans / entura County Property Management Company"** (space-separated license variants "01 06 44 15" / "00 9278 50" — same numbers, same scam pattern); confirmed Run 245 (1215 Laguna $940 + 225 Fell $950 — identical AI body text with only neighborhood name swapped, both auto-skipped)
- **Oxnard and Ventura Rental Properties Group / "uthorized Broker Marchus R Sterling"** (license formats "0.09 2.78 5.0" / "01.8 8.73.2 1" — dotted non-standard CA DRE format; deliberate "uthorized" typo) — new alias for the Golden Gate Rental Properties / Zolden Gate / Marcus R. Sterling batch scammer confirmed Run 252; same AI-generated body text ("charming 1 bedroom...hardwood floors throughout, a functional fireplace, a separate dining room...large private yard"), same $28/$80 (or $35/$150) app+holding-fee structure, same "Interested renters can message their phone number anytime." closing script; 3+ simultaneous listings in one session (SoMa $899 vhoFAyJV9ZND4qbTWFR5xe, Mission $880 oRB6fQ8xnpv4ZWvqYaAR6T + cQFpfiPnr1U8t8CqDYuMGQ, Inner Sunset $960 6YwZYubSAwRGHpDojGL3ni) — auto-skip any listing citing this entity or these license formats
- **Gallagher & Lindsey, Inc. / Haker Realty Group Management / Mary E. Landeros Inc.** (license formats "CA. Lic. 0 0 8 54412" / "DRE # 0 0 8 4 13 0 5" — spaced non-standard CA DRE format) — new batch-scam operator confirmed Run 252; 2+ simultaneous listings same session (Russian Hill $1,520 3vgJab9CbPFxB9CD3kyTZ8, Hayes Valley $1,575 dX4wzktALfiPNQbKVEAktV); same AI-generated flowery body text with "enchanting neighborhoods", "magical tri-level home" phrasing; "Refundable $35 app $150 holding fee" fee structure; "Interested renters can message their phone number anytime." closing script. New alias "Mary E. Landeros Inc." confirmed Run 324 — same spaced DRE 0 0 8 54412, same batch-flood pattern (10+ simultaneous listings: Marina $1,360, 415 Tehama $1,585, SoMa loft $1,600, 38 Dolores $1,875, Nob Hill $1,300, others) — auto-skip any listing citing any of these entity names or these spaced-digit DRE formats
- **Xlmaden Valley Realty and Leasing dba XVRL / Rrincipal Broker Sarah M Evans** (license formats "01.94.94.72" / "02.04.48.11" — dotted non-standard CA DRE format; "Rrincipal" deliberate double-R typo) — new alias in the Madera Valley / Sarah M Evans scam family confirmed Run 262; 3+ simultaneous listings same session (Chinatown/SoMa $1,200 hwFJ6PFyiTyUTkVLbsHNhQ, Lower Nob Hill $1,540 aayNwdMPD2AZtSEm3ENEPy, Mission $1,520 n8jQJXzdwdNNvUC4drgS77); same AI-generated "THE PROS/THE CONS" or flowery body text format; same "$30 app fee and $89 admin holding fee" fee structure; consecutive 3-day open house schedule; same Sarah M Evans name as principal broker despite different license numbers — auto-skip any listing citing this entity, "XVRL", or these dotted DRE license formats
- **Bay Area Properties Realty, Inc / Martin A. Leon Harper / Ronald K. Ikebe** (license formats "CA DRE Lic. 00. 98. 76. 79" / "Real Estate License 01. 97. 64.17" / "Lic. 02. 15. 44. 46" — dotted non-standard CA DRE format) — new batch-scam operator confirmed Run 291; 3 simultaneous listings same session (Nob Hill 1BR $1,569 mDAVjXyphnRWriPyjh5hB2, SoMa 1BR $1,485 mewiypv8tHYaLKZk1vMomD with mismatched coords, Presidio Heights 1BR $860 hDVfkQuf9SDRAHxWxH64La); same three names appear across all listings as application/broker/listing agent; same AI-generated body text with padding dots; same "If you're interested, please text me your phone number." closing script; same consecutive 3-day open house schedule; prices 40–70% below market — auto-skip any listing citing these three entity names or these dotted DRE license formats
- **"If you're interested, please send me your number." batch operator** (no DRE identified) — confirmed Run 271; flooding CL with 5+ simultaneous listings across ALL accepted SF neighborhoods under varied titles and wildly different prices from the same set of addresses; key identifiers: (1) closing script exactly "If you're interested, please send me your number." (2) consecutive 3-day open house schedule (Wed/Thu/Fri) in CL attrs, (3) short AI-generated generic neighborhood description with no unit-specific details (no address, no unit number, no sq ft, no building name), (4) cats OK + dogs OK + AC + (sometimes EV charging) attrs across all listings. Confirmed examples from Run 271: "Studio - Post street, San Francisco" at $850 (vc3H7BmB6kiQkLFQXve4GR), $1,489 (cqQseUpaVTEkULnzZzECfb), and $1,900 (7XqRAGKA2o1XxRUkgs6fbZ) with IDENTICAL body text; "New Renovation Top Floor Updated Studio Laundry In Unit" $950 Nob Hill (bBSNdbhgisfqv5jmXCPnVm); "Cozy 1BR 1BA Apartment in San Francisco Richmond District" $1,520 (2NpoXDJ9yt4iUoXPPkwCqv); "Sunny Top Floor 1 Bedroom Apartment in San Francisco" $1,500 Noe Valley (6LsmYtob2ETiWAwzxqVKdU); "Charming Russian Hill 1 bedroom" $1,985 (gJ8em5EjbZfGHUrTHEDP66) — all identical closing, all auto-skip on sight
- **"please text me your phone number" batch operator** (no DRE identified) — new variant confirmed Run 278; flooding CL /apa/ section with 5+ simultaneous listings across ALL accepted SF neighborhoods (Russian Hill, Alamo Square/NoPa, Pacific Heights, SoMa, Nob Hill) using AI-generated body text; prices 30-50% below market (e.g. Russian Hill 1BR $1,500, Pacific Heights 1BR $1,450, SoMa Victorian 1BR $1,699, Nob Hill 1BR $1,845, Alamo Square 1BR $1,760); key identifiers: (1) closing script: "If this sounds like the kind of place you've been searching for, tell me a bit about yourself! I'm looking for someone who will truly appreciate the charm of this space. If you're interested, please text me your phone number." (2) no address or cross-streets given in body text, no landlord name, no PM name — just neighborhood description, (3) AI-generated identical structure with only neighborhood name/price swapped, (4) massive price anomaly in premium neighborhoods. Confirmed examples from Run 278: o4zaYkQQRA3ZBRKhqVAdtK (Russian Hill 1BR/1Ba 732sqft $1,500), dNg1DbmMBzkLSoLZUUWW1g (Alamo Square 1BR $1,760 at 1511 Golden Gate Ave), auKYnZ4yPJ59z7qDsKxMQh (Pacific Heights 1BR/1Ba 512sqft $1,450), wZjgaG2wEvDM9uaM3Gqboc (SoMa Victorian 1BR/1Ba 800sqft $1,699), jyZarhzUA5pNChv2jQxy8P (Nob Hill 1BR/1Ba 600sqft $1,845) — all identical closing script, all auto-skip on sight
- **Jones Street Rental Advisors, Inc. / Fairmont View Executive Leasing** (license formats "01.94.9.47 2 Lic. DRE CA." / "02.0.4.4 81.1 BK" — dotted/spaced non-standard CA DRE format) — new batch-scam operator confirmed Run 308; Union Square area studio $1,050 at lat 37.790 / lng -122.406 (Financial District); consecutive 3-day open house (Sat/Sun/Mon); fee structure: "$35 per application + Refundable $29.95 fee + $200 admin holding fee" (multiple upfront fees); closing script: "Text with your name, number, email address" (direct phone/email request); price 60%+ below market for location; AI-generic body text with no address or cross-streets. Do not add any listing citing either entity name or these dotted/spaced DRE license formats
- **Kevin S. Miller / Sunset Properties / North Point Realty Group** (license formats "DRE#: 0.20.8 8.4.93." / "Lic. 0.06.4.4.1.28." — dotted non-standard CA DRE format) — new batch-scam operator confirmed Run 312; Hayes Valley 1BR $1,459 1427sqft (oy6dhs1PBBV3dQjZMaTCAv — absurdly large sqft claim, price anomaly); same consecutive 3-day open house (Sun/Mon/Tue); same "Refundable $45.55 + app + $166.00 holding fee" upfront fee structure; closing script: "Text with your name ,number, email address" (identical to Sarah M Evans variants); same attrs pattern (cats+dogs+AC+EV+w/d in unit+off-street parking); AI-generated body text — auto-skip any listing citing either entity name or these dotted DRE license formats
- **"$39/$200 admin holding fee / please text me your number" batch operator** (no DRE identified) — new batch-scam operator confirmed Run 313; flooding CL /apa/ and /roo/ sections with 7+ simultaneous listings across ALL accepted SF neighborhoods; key identifiers: (1) CL attrs: "$39/app/|/$200/ admin/holding.fee" fee structure, (2) closing script: "If interested, please text me your number." (3) body text contains "Park 80 Apartments" or other wrong property name pasted from unrelated template, (4) consecutive 3-day open house in CL attrs, (5) same cats+dogs+AC+EV+w/d in unit attrs pattern, (6) prices 50-70% below market. Confirmed examples from Run 313: Cole Valley $950 tGpkTYzfyTin7UEZFiVbcn, Mission $899 ra1V8sRXQJEhMyLKi4SHtJ, Nob Hill $900 rDf3mV4efhsKCshYbvA4Zn, Hayes Valley $850 j3qVmYC1DsRYFtMLeoJXEU, Alamo Square/NoPa $950 b9ocXNVh8M5rRE1BPuRLn8, Duboce Triangle $1,100 diJPiUwp9XrFJQ1BzWXCBg — all auto-skip on sight
- **Pacific Plaza Executive Leasing / Mason Hill Property Management** (license formats "0 20.4.4.81 1 CA DRE Lic." / "Pacific Plaza | Executive Leasing BK #02 01.14.5" — dotted/spaced non-standard CA DRE format) — new batch-scam operator confirmed Run 313; flooding CL /apa/ with 5+ simultaneous listings across ALL accepted SF neighborhoods; key identifiers: (1) CL attrs broker_fee field: "0 20.4.4.81 1 CA DRE Lic.|Mason Hill Property Management." (2) listed_by field: "Pacific Plaza | Executive Leasing BK #02 01.14.5" (3) fee structure: "$28 application fee. Refundable: '$40/app/$202 admin/holding fee'" (multiple upfront fees), (4) consecutive 3-day open house (Sun/Mon/Tue), (5) same cats+dogs+AC+EV+w/d in unit attrs pattern, (6) closing script includes "with your name, email address, and the property address"; prices 30-60% below market. Confirmed examples from Run 313: Castro $1,650 g1w1t7P9kUaqhGCHKwdpFU, Lone Mountain/Inner Richmond $1,487 waC4RUm6Tfn4J6WrHjy5Ww, Mission 17th St $1,569 iV4Fvt6LrYqeiPZ7pCiu2z, Potrero Hill $1,820 vkwzcnY2ZrgJNpPybSvFuH — auto-skip any listing citing either entity name or these spaced/dotted DRE license formats
- **Jackson Square Rental Advisors / Pacific Heights Realty Group, Inc. / SF Urban Living / Clay Terrace Executive Leasing** (license formats "CA DRE Lic. 0.177.55 31" / "BK #01.52 2 1.6" — dotted non-standard CA DRE format; the "01.52 2 1.6" is a new spacing variant of the Marcus R. Sterling DRE 01522160) — new batch-scam operator confirmed Run 322; 2+ simultaneous listings same session (SoMa/1188 Mission $1,620 7ySD51hC4qnHGxn6EL5vuW, LNH/925 Sutter $1,540 9MWeV4Yn15FMVJr7evDQuy); key identifiers: (1) CL attrs listed_by: "Jackson Square Rental Advisors | CA DRE Lic. 0.177.55 31" or "Pacific Heights Realty Group, Inc. | CA DRE #0.177.55 31", (2) broker_fee: "SF Urban Living | Executive Leasing Broker#01.52 2 1.6" or "Clay Terrace - Executive Leasing BK #01.52 2 1.6", (3) consecutive 3-day open house (Tue/Wed/Thu or Tue/Wed/Fri), (4) multiple upfront fees ("$52 + $39 app + $199 admin fee" or "$50 + $40 app + $200 admin fee"), (5) "w/d hookups" (not confirmed in-unit laundry), (6) AI-generated body text (vague amenity descriptions, no specific address in body) — auto-skip any listing citing any of these entity names or the DRE format "0.177.55 31" (= 01775531)

- **Bay Area Urban Housing Group / Oliver Grant Residential Management / Chloe Bennett Leasing Consultant** (license formats "Chloe Bennett Leasing Consultant DRE#: 0 19 44 2 17" / "Bay Area Urban Housing Group - Lic. 0 07 66 41 2" — spaced non-standard CA DRE format) — massive new batch-scam operator confirmed Run 326; 7+ simultaneous listings flooding ALL accepted SF neighborhoods in one session (Cow Hollow $990 accYi9H4sNHoaCUN34Aq2Z, Telegraph Hill $1,350 fphXvmKPX3zV49nDdjyxwB, LNH $1,005 8f7fCat9Npf7D3iqUUNNg5, Marina $710 rRYsCE6gt9TqmLZJFsKoe8, Mission Dolores $990 txe3BmugrcrFP29Dx5Em7U, Haight-Ashbury $700 t9RpbZFN36Y6rpbmoF9g7C, Cow Hollow $1,420 n6XRyVcvs9Uf8LbH5K1qCB, and more); key identifiers: (1) CL attrs listed_by: "Bay Area Urban Housing Group - Lic. 0 07 66 41 2", broker_fee: "Chloe Bennett Leasing Consultant DRE#: 0 19 44 2 17", application_fee: "Oliver Grant Residential Management", (2) closing script: "If you are interested kindly provide your number.", (3) identical AI-generated padding body: "This is a straightforward listing for a vacant room in a well-kept building..." followed by Spanish garbage text ("Centro de Yoga, T.V., Gimnasio con area de Pesas, Caminadoras y Spinning. Terraza amueblada con Vista Panoràmica"), (4) consecutive 3-day open house (Wed/Thu/Fri or Thu/Fri/Sat), (5) extreme price anomaly 60–80% below market across all neighborhoods, (6) same cats+dogs+AC+EV charging attrs pattern — auto-skip any listing citing any of these entity names or these spaced-digit DRE/license formats

- **Mary Wilson / Silver Sage Realty Pros / Mary Management Corporation / Wilson Real Estate** (license formats "Mary Wilson - Silver Sage Realty Pros - B.143533" / "Wilson Real Estate, DRE License: 02241060" / "Mary Management Corporation (DRE #00353466)") — new batch-scam operator confirmed Run 335; 3+ simultaneous listings flooding ALL accepted SF neighborhoods (Marina 2835 Van Ness $940 ddhEgnMUT95gtJriCiqnxC, Dolores area 1BR $1,750 cFWej2QTSGoiZcHJ26n1fB, Eureka Valley 4250 21st St $1,995 fZdb8jz8y12T4waYghRJer); key identifiers: (1) CL attrs application_fee: "Wilson Real Estate, DRE License: 02241060", broker_fee: "Mary Management Corporation (DRE #00353466).", listed_by: "Mary Wilson - Silver Sage Realty Pros - B.143533", (2) closing script: "To apply, text me your number and I will contact you as soon as possible. Thank you." (3) consecutive 3-day open house (Fri/Sat/Sun or Sat/Sun/Mon), (4) cats+dogs+AC attrs pattern, (5) prices 30–75% below market — auto-skip any listing citing any of these entity names or these license/DRE formats

- **Jane Properties / Jessica Properties / 02.04.48.14 License / Mark Robart Properties / Bay Area City Homes / Bernal Heights Residential Advisors** (license formats "02.04.48.14 License Jane Properties" / "02.04.48.14 License Jessica Properties" / "02.04.48.11 Jessica Properties" / "02.04.48.14 Mark Robart Properties" / "04.48.14 Mark Robart" / "02.04.48.14 License Bay Area City Homes" / "02.04.48.14 I Bernal Heights Residential Advisors" — dotted non-standard CA DRE format) — new batch-scam operator confirmed Run 335; "Jessica Properties" alias confirmed Run 338; scale escalating — 15+ simultaneous listings flooding ALL accepted SF neighborhoods by Runs 339–341 (Russian Hill, SoMa, Pacific Heights, Hayes Valley, Divisadero, Marina, Nob Hill, Potrero Hill, etc.); "Mark Robart Properties / Mark Robart" alias confirmed Run 360 — 6 simultaneous listings (858 Washington $1,600 sQFhveVJX, 959 Capp Mission $1,400 eTjamx98, 959 Capp Mission $1,200 gT918PZp8, 1033 Minna SoMa $1,120 3ecUPJhH, 254 Ivy Hayes Valley $1,320 jPkcZ5Kq, 1053 Oak NoPa $1,000 vS8f3EWgh) all sharing identical DRE "02.04.48.14", consecutive Fri/Sat/Sun open house, "$35 application fee and $250 admin holding fee" structure, "If interested, please send your phone number" closing; "Bay Area City Homes" + "Bernal Heights Residential Advisors" aliases confirmed Run 376 — 10+ simultaneous listings across all SF nbhds (LNH 1114 Sutter $1,520 phekeXVCabMfCoyxrS1NwH, Nob Hill 737 Pine $1,570 7EQGa3qrTFdDEDKsgsTdbn, SoMa 1201 4th $1,540 hpzFqWnQGgcPARmDNL4yyF, Mission 1128 Valencia $1,530 jX5R5YLA14YE3p2RpvQWMj, and more); same DRE "02.04.48.14 I Bernal Heights Residential Advisors" in application_fee, "Listed (by) Broker: 02.04.48.14 License Bay Area City Homes" in listed_by, same "$31/person + $47 app + $105 admin holding fee" structure, same Tue/Wed/Thu 3-day open house, same AI-generated fictional-personal-story body text, same "Send over a fast text message with your phone number" closing; key identifiers: (1) CL attrs broker_fee / listed_by: "02.04.48.14 License Jane/Jessica Properties" / "02.04.48.14 Mark Robart Properties" / "04.48.14 Mark Robart" or "02.04.48.11 Jessica Properties" or "02.04.48.14 License Bay Area City Homes" or "02.04.48.14 I Bernal Heights Residential Advisors", (2) closing script: "To apply, text me your number and I will contact you as soon as possible. Thank you." or "If interested, please send your phone number" or "Send over a fast text message with your phone number" or similar "text me your number" variant, (3) consecutive 3-day open house (any 3-day window), (4) cats+dogs+AC+EV+w/d attrs pattern, (5) application_fee: "Refundable+$100 application fee and \"/$200 admin holding fee" or "$35 application fee and $250 admin holding fee" or "$31/person + $47 app + $105 admin holding fee", (6) AI-generated vague body text with no specific address detail, (7) prices 20–75% below market across all neighborhoods — auto-skip any listing citing any of these entity names or the dotted DRE format "02.04.48.14" or "02.04.48.11"

- **"If you are interest please send your email!!!" batch operator** (no DRE/license identified) — new batch-scam operator confirmed Run 394; 10+ simultaneous SF /apa/ listings flooding ALL accepted SF neighborhoods in a single session (Noe Valley $1,255 1BR/860sqft tSB2EmZZxQackaQwd7T66v, NoPa/Alamo Square $1,258 1BR/472sqft gvuVP8jps2zqizJx5JnPNX, North Beach $1,175 1BR 8MEt4xHJEgDXHWocZ1gEJT + 9Pjms9bvQPoRmpV3VnjQqb — 2 parallel URLs, Marina $1,290 1BR pFCDHX6WW2XbBvE6HMj4dm, Cow Hollow $1,675 1BR udhPgGbYX54d6zw78jqRUB, Telegraph Hill $1,977 1BR/1354 Kearny 2QVHcVcvA71XH5A36fUZhV, Hayes Valley $1,625 1BR 15NR9zkaGXXQVPktRWWhiC + $1,499 studio 14TCPfnEjWnnYKt5YN6yAQ, Nob Hill $1,520 1BR rttvgwgiCW2AMwx8K1ed5o, Mission $1,725 1BR bSP1ePsrKqeneLs7PFVZKk, Castro/SoMa $1,725 1BR kPdJcw31a4pMQiDp7T4FTG, and more); key identifiers: (1) closing script exactly "If you are interest please send your email!!!" or "If you are interest please send your email!!" (broken English — "interest" instead of "interested", 2–3 exclamation marks), (2) preamble: "There is no fee to apply. Prior to the open house (not currently scheduled), the apartment will only be shown to people who have completed the application. Email inquiries will be replied to in the order they are received.", (3) AI-scrambled/copied body text — e.g. listing advertised as "1BR" but body says "5 bedrooms and 3.0 bathrooms"; or body copied from non-SF template ("2 blocks from the new Montgomery County Municipal Center"), (4) same CL attrs pattern: cats OK + dogs OK + w/d in unit + off-street parking + AC + EV charging, (5) no consecutive open house scheduled (unlike most batch scammers), (6) prices 10–60% below market across all premium SF neighborhoods; no upfront fee structure visible (distinguishes from DRE-format scammers); no visible PM/broker name in listings — auto-skip any listing with this exact closing script on sight

- **The Housing Guild Management Co. / Erston Pearcy Real Estate Agent** (license formats "01.39.87.68 License Erston Pearcy Real Estate Agent | Rentals" / "01.39.87.68 I Real Rstate Agent | The Housing Guild Management Co." — dotted non-standard CA DRE format; deliberate "Rstate" misspelling) — new batch-scam operator confirmed Run 396; 5+ simultaneous listings flooding ALL accepted SF neighborhoods (Inner Richmond 1BR $895 kgvMTemxCgkHMVK8eULzc5, Castro 1BR $1,425 s48BtcXWyYf4LMgh1EDBQk + tNeddNAiBo4MfJctqYuER9, and others); key identifiers: (1) closing script: "If you are interest please send your email and number!!!" (broken English — "interest" instead of "interested", adds "and number" — a variant of the Run 394 email-only operator), (2) preamble: "There is no fee to apply. Prior to the open house (not currently scheduled), the apartment will only be shown to people who have completed the application. Email inquiries will be replied to in the order they are received.", (3) CL attrs listed_by: "01.39.87.68 License Erston Pearcy Real Estate Agent | Rentals", broker_fee: "01.39.87.68 I Real Rstate Agent | The Housing Guild Management Co.", (4) application_fee: "Refundable:+/'$30.95 application fee and '//$100 admin holding fee" (non-standard punctuation formatting), (5) consecutive 3-day open house (any combination), (6) same cats+dogs+AC+w/d in unit+off-street parking attrs pattern, (7) prices 50-65% below market across all accepted SF neighborhoods, (8) AI-generated body text with no specific address — auto-skip any listing citing either entity name or the DRE format "01.39.87.68"

- **Bayview Executive Properties / Golden Gate Leasing & Management** (license formats "DRE #01.89.42.73" / "Broker Lic: 01.43.89.21" — dotted non-standard CA DRE format) — new batch-scam operator confirmed across Runs 403–404; key identifiers: (1) CL attrs listed_by / broker_fee citing "Bayview Executive Properties" or "Golden Gate Leasing & Management" with these dotted DRE formats, (2) TL-zone and premium-neighborhood simultaneous listings (Run 403: 225 Taylor St TL zone; Run 404: 474 Vallejo Russian Hill $1,755 45sfobFcXaegiKJb3zkSqC — auto-skipped), (3) prices 15–40% below market, (4) standard scam attrs pattern — auto-skip any listing citing either entity name or these dotted DRE license formats

- **"Text with name/email/number + body-paste" unnamed batch operator** (no DRE/license identified) — new batch-scam operator confirmed Run 404; 4+ simultaneous listings flooding CL /apa/ section across accepted SF neighborhoods; key identifiers: (1) closing script: "text with your name, email, and number." or "please send me your phone number." or similar direct phone/email/name request, (2) body text is pasted verbatim from another legitimate active CL listing (confirmed by matching text to real tracked listings) followed by irrelevant padding content including phrases like "female in my 30's" or similar unrelated personal context from a different posting context, (3) body text contains obvious copy-paste artifacts — mid-sentence topic breaks, neighborhood name mismatches, or content that doesn't describe the advertised unit, (4) no PM/broker name cited, no DRE, no application fee structure described, (5) no specific address given — just neighborhood label and price. Confirmed examples from Run 404: Inner Richmond 1BR, Van Ness-area unit, Jones St LNH (copy of 620 Jones St listing body), Mill Building-address unit — all auto-skipped on sight. Auto-skip any listing where body text appears pasted from unrelated source + closing requests phone/email/name.

- **East Bay Residential Group / Kevin R. Collins - Metro Alameda Leasing / David L. Carter - Bay Area Leasing** (license formats "008 2.214.9" / "02.2 77 1.03" / "02 144 70.5" — spaced non-standard CA DRE format) — new batch-scam operator confirmed Run 407; 3+ simultaneous CL listings flooding accepted SF neighborhoods (jRzx2Mzz3j9ZrGt6MK1V7N $1,600 "True STUDIO" at 1401 10th Ave Inner Sunset, ezPNewiboLWDhUSsG9pvPm $1,500 "1825 Mission", uMUPtmjyide1TGN1ugX9A6 $1,920 Inner Sunset 1BR); all listings share same fake coordinates (lat 37.762128, lng -122.467253 — matches no SF streets); key identifiers: (1) CL attrs application_fee / listed_by / broker_fee citing "East Bay Residential Group", "Kevin R. Collins - Metro Alameda Leasing", or "David L. Carter - Bay Area Leasing" with these spaced DRE formats, (2) closing script: "Respond with a contact number" or "Leave a number" or similar direct phone request, (3) identical fake coords 37.762128/-122.467253 across all listings (lat puts them in Outer Sunset / west Inner Sunset; no intersection matches address claims), (4) prices 20–50% below market; (5) AI-generated body text with no verifiable unit details — auto-skip any listing citing any of these entity names or these spaced-digit DRE formats

- **Hotspot Apartment Rentals LLC / Dorothy Moody / IL RES Broker #481.011892 / Designated Managing Broker Dorothy Moody #471.006436** (Illinois real estate license format — not CA DRE; also co-uses "02.04.48.11 License Principal/Rrincipal Broker Sarah M Evans" in broker_fee field) — confirmed batch-scam operator across Runs 414–415; 6+ simultaneous CL /apa/ listings flooding ALL accepted SF neighborhoods in a single session (Run 415: Cow Hollow 1BR $1,459 jcgoy7tM, North Beach studio $1,795 ufd7v3oX + ddrPDXD6, Beautiful Studio $1,350 ntWBKEE1, 1BR garage $1,325 w7uMD9AC, and others; Run 414: 1221 Waller $1,250 Haight, 2361 Union $1,550 Cow Hollow); key identifiers: (1) CL attrs listed_by: "Hotspot Apartment Rentals LLC - IL RES Broker #481.011892." (2) broker_fee: "Designated Managing Broker - Dorothy Moody #471.006436." or "02.04.48.11 License Principal/Rrincipal Broker Sarah M Evans" (3) fee structure: "Refundable+/'$38. application fee and |//$150. admin holding fee." or "$100/$200" variant, (4) consecutive 3-day open house (Sat/Sun/Mon or similar), (5) closing script: "For more information text with your phone number." or "Contact: Any interested parties please provide full names (including middle initial)..." (6) body text sometimes contains out-of-state content ("snow removal," "Waukesha water" in prior runs) or is plausible-looking SF description, (7) prices 20–50% below market; uses both IL license AND the 02.04.48.11 Sarah Evans CA DRE format (already blocklisted) — auto-skip any listing citing "Hotspot Apartment Rentals LLC," "Dorothy Moody," IL license #481.011892 or #471.006436, or these fee/closing patterns

- **Houston Residential Management LLC / Lone Star Property Services** (license formats "TREC Lic. #90 05 67 8" / "Executive Leasing Broker #067 891 2" — Texas Real Estate Commission license format; not CA DRE) — new batch-scam operator confirmed Run 415; 2+ simultaneous CL listings in a single session (875 Bush $1,855 u2EyYctvHP — body text copied verbatim from a Miami Beach/Belle Isle condo listing including FL zip codes 33139–33180 and "Whatsapp 305" contact; Studio/Pool complex $1,700 5VRtYzgmS — TL-zone coords 37.784/-122.409); key identifiers: (1) CL attrs broker_fee: "Houston Residential Management LLC\"TREC Lic. #90 05 67 8" (2) listed_by: "Lone Star Property Services\"Executive Leasing Broker #067 891 2" (3) fee structure: "Background charge: $40 per applicant+Unit holding fee: $175." (4) closing script: "Send a number we can use for a quick conversation." or "text your name, email, and contact number" (5) body text is copy-pasted from unrelated out-of-state listing (FL condo with Miami Beach zip codes, Interealty Exchange Inc./Robert Rice contact) — auto-skip any listing citing "Houston Residential Management LLC," "Lone Star Property Services," these Texas TREC license formats, or listing body containing "Interealty Exchange" or Florida zip codes (33139, 33140, etc.)

- **"wine refrigerator / en suite / please leave your name and phone number" unnamed batch operator** (no DRE/license identified) — new batch-scam operator confirmed Run 420; 3+ simultaneous CL /apa/ listings flooding accepted SF neighborhoods in a single session (Noe Valley $1,150 kVgbzUyr, North Beach $1,100 dnGGjKjn, Potrero Hill $875 pc9Psgsy); key identifiers: (1) closing script: "Please leave your name, phone number, preferred move-in date, and a little about yourself for a faster response." (2) AI-generated body text with identical luxury amenity list across all listings: "wine refrigerator," "en suite bathroom," "central air conditioning," "dedicated private laundry room" — verbatim across different neighborhoods and price points, (3) no PM/DRE/broker name in any CL attrs field, (4) same cats+dogs+AC+EV charging+w/d in unit+off-street parking attrs pattern across all listings, (5) prices 50–65% below market across all neighborhoods (Noe Valley 1BR at $1,150, North Beach 1BR at $1,100, Potrero Hill at $875 — all extreme anomalies), (6) no specific address given in body — only neighborhood label and generic luxury description. Also cross-posts with Palm Breeze listed_by + Mary Management Corp / Mary Wilson DRE #00353466 in broker_fee for same-session listings (Telegraph Hill $1,765 hVa3VXAqA, Lone Mountain $1,800 xfpTfQAo — auto-skipped via Palm Breeze + Mary Wilson blocklist entries) — auto-skip any listing with this exact closing script on sight

- **Olivia Ramirez / Coldwell Banker Realty / License #00951613** (license format "Listing Agent Olivia Ramirez Coldwell Banker Realty License #00951613" / CL listed_by: "Coldwell Banker Realty" — real brokerage name used as cover; #00951613 may be a real CalDRE number but used across batch scam operation) — massive new batch-scam operator confirmed Run 429; 6+ simultaneous CL listings flooding ALL accepted SF neighborhoods in a single session (Pacific Heights $1,005 cKCuaGo3 + ky93jHau ×2, 1415 Franklin St 2BR $1,395 uhdDN6frz6, 1140 Brussels St 1BR $1,395 w4rbjhCty4, 520 Buchanan $1,095 5gD8tKBojH + 5vxWPNZHGsq ×2, 555 Bartlett Mission $1,995 jguAdfWv1k, 121 San Carlos $1,050 2xbLw93ymU); key identifiers: (1) CL attrs application_fee: "Refundable:: /||$38. application fee and |//$150. admin holding fee." (non-standard double-colon + pipe characters — distinctive formatting), (2) listed_by: "Coldwell Banker Realty" (3) body cites "Listing Agent Olivia Ramirez Coldwell Banker Realty License #00951613" as closing, (4) consecutive 3-day open house (Tue/Wed/Thu 2026-08-18/19/20), (5) same cats+dogs+AC+EV charging+w/d in unit attrs pattern across all listings, (6) prices 50-65% below market across all neighborhoods, (7) AI-generated body text with no specific street-level detail — auto-skip any listing citing "Olivia Ramirez," "Coldwell Banker Realty" in CL attrs listed_by, or the "Refundable:: /||$38. application fee and |//$150. admin holding fee." fee format

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
