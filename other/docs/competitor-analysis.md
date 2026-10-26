# Competitor Analysis — SilaiSetu

Research date: 2026-10-22  
Method: Public Google Play Store listings and visible descriptions only. Apps were **not** installed or functionally tested. Screenshot UX notes are limited to what the store page exposes.

**Brand note:** SilaiSetu is a provisional name. Trademark, app-store name, and domain availability still need verification before commercial launch.

---

## Comparison table

| Competitor | Publicly verified features | Observed UX patterns | Potential strengths | Potential gaps | Evidence / access limitations | Opportunities for SilaiSetu |
|---|---|---|---|---|---|---|
| **Tailor Wala** (`com.tailorwalaapp.shop`) | Customer names/phones; permanent measurements; stitching orders; monthly/yearly income; order totals; customer history; calendar on All Orders; custom measurements with reordering; invoice share via WhatsApp | Simple UI emphasis; order cards with stitching/fabric cost; calendar date filtering | Clear focus on digital register replacement; WhatsApp invoice sharing; recent calendar + custom measurement polish | Multi-shop SaaS / platform admin not mentioned; staff roles unclear from listing; web dashboard not claimed | Listing + What’s New accessible; screenshots not deeply audited | Premium multi-tenant SaaS with web + mobile; role-based staff; audited payments; platform admin |
| **TailorMate** (`com.tailormate`) | Shop profile; orders with multi-items + cloth/pattern images; customers; multiple measurements; active/past-due/upcoming/delivered views; search; daily/monthly reports; stitch gallery; invoices; inventory; worker access; cloud backup; free trial; customizable measurement options | Simple WhatsApp-like UX claim; Android + mentioned web version in review reply | Mature CRM/ERP positioning; cloud backup; rich garment options for Indian dresses | Reviews request stronger worker task assignment / barcodes; SaaS platform-admin depth unclear from listing | Listing + reviews accessible; app not functionally tested | Emphasize staff assignment + web dashboard quality; keep measurement templates shop-configurable |
| **Silai Saathi - Smart Tailoring** (`com.silaisaathi.tailormate`) | Customer profiles + photos; garment-wise templates (Kurti, Blouse, Shirt, Pant, Suit, Sherwani…); measurement history; order stages Pending→Cutting→Stitching→Ready→Delivered; delivery urgency; fabric/design photos; advances + PDF receipts; WhatsApp share; daily collections; staff assign; **EN/HI/GU**; offline claim | Mobile-first workshop workflow; urgency badges; multilingual India focus | Strong feature overlap with our vision; multilingual; staff allocation; offline angle | SaaS multi-tenant web portal / platform owner tools not mentioned; subscription model unknown from listing | Listing accessible; offline behavior not verified | Differentiate with secure multi-tenant backend, web dashboard, platform admin, measurement snapshots, Decimal money integrity, RLS |
| **SewTrack - Tailor Manager** (`com.sewtrack.sewtrackapp`) | Orders, customers, measurements, revenue monitoring (high-level listing) | All-in-one mobile positioning | Broad “full control” messaging | Listing text is thinner on concrete workflows; India-specific localization not highlighted in fetched summary | Listing accessible but sparse on feature detail; developer contact Nigeria-based phone in listing | Win India shops with GU/HI/EN + INR-first + local workflows |

---

## Verified takeaways (evidence-based)

1. **Core loop is universal:** customers → measurements → orders → payments/dues → delivery dates.
2. **Configurable measurements** and garment-wise templates are table stakes (Tailor Wala What’s New; Silai Saathi templates).
3. **Status pipelines** similar to ours appear publicly (Silai Saathi stages).
4. **WhatsApp sharing** of invoices/summaries is a common expectation — integrate later without claiming delivery unless confirmed.
5. **Multilingual EN/HI/GU** is already used by at least one competitor (Silai Saathi) — we must match quality, not English-only UI.
6. **Calendar / due-date filtering** is valued (Tailor Wala calendar update).

## Assumptions (not verified)

- Depth of offline sync quality for Silai Saathi.
- Whether competitors enforce true multi-tenant isolation or are single-shop installs.
- Pricing, subscription models, and data export quality.
- Exact measurement versioning / immutable order snapshots.

## Product decisions informed by research

- Ship **web dashboard + mobile** (many listings are mobile-only).
- Invest in **measurement templates + version history + order snapshots**.
- Match **GU/HI/EN** localization quality.
- Keep **platform admin** as a SaaS differentiator (not seen as a public focus in these listings).
- Defer WhatsApp/SMS until a real provider is configured; keep in-app notifications first.

## Access limitations

- TailorMate listing was blocked during one fetch attempt; treat that row as incomplete until manually reviewed.
- No competitor APKs were reverse-engineered or tested. No branding/assets copied.
