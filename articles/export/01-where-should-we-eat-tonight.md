# Where Should We Eat Tonight?

*Part 1 of the Small Batch Apps series*

Last Saturday, Meriam and I stood in our kitchen at 5pm with no plan. She was hungry. I was hungry. This is not unusual. What was unusual is that I decided to actually try the apps.

I opened Google Maps and typed "restaurants." A constellation of red pins appeared over Center City Philadelphia, each one indistinguishable from the last. I tapped one at random: 4.2 stars, 1,800 reviews. I tapped another: 4.1 stars, 2,400 reviews. A third: 4.3 stars, 900 reviews. Every restaurant within three miles had been compressed into a number between 4.0 and 4.3, which is Google's way of telling you that every restaurant is the same — which is Google's way of telling you nothing at all.

I scrolled through the reviews on the 4.2-star place. A tourist gave it five stars for "great vibes." Someone gave it one star because they waited ten minutes on a Saturday night. A local wrote three paragraphs about the wine list that read like a press release. I suspect it was.

I closed the app. We went to the same place we went last month.

This is a spiral. Every Saturday it comes around, and every Saturday we end up further from an answer. Billions of dollars of restaurant technology, and Meriam and I still can't answer the simplest question we ask each other: *where should we eat tonight?*

So I decided to build something. And here's where it gets interesting — I haven't written a single line of code. Not one. The AI writes every line. I just tell it what I want. I've been calling it "vibe coding," and I have no idea if that makes me a genius or an idiot, but the software works and I'm having a wonderful time.

More on that shortly. First, let me tell you what's broken. All of it.

## Every App You've Ever Tried

Google Maps. Yelp. The Infatuation. Eater. OpenTable. TikTok. Instagram. Each one promises to help you find a great restaurant, and each one is optimized for something that has nothing to do with helping you find a great restaurant.

Google wants you inside Google Maps. Yelp sells ads to the restaurants you're trying to evaluate. OpenTable takes a booking fee. The Infatuation wants page views. TikTok's algorithm promotes whatever is most filmable — the place with the tableside flambé and the $40 milkshake, not the twelve-seat BYOB where the chef is doing the best work of his life. Instagram influencers get paid to post about restaurants, and they don't disclose it, and the restaurant that spends $5,000 on influencer placements looks exactly like the restaurant that earned its reputation by cooking good food.

Every single player in this ecosystem has incentives that point away from you. The person asking the question — *where should we eat tonight?* — is the one person nobody is trying to help.

When you average the opinions of thousands of strangers, you get mush. A romantic French bistro and a raucous sports bar can both land at 4.2 stars. A BYOB gem with twelve tables and a convention-center-sized Italian chain can have identical ratings. The number tells you nothing about whether *you* — specifically you, with your taste, your partner, your mood tonight — would enjoy it.

None of these apps know that Meriam and I love BYOBs because they save us sixty dollars and she likes bringing that bottle of Barolo she's been saving. They don't know that she hates loud restaurants. They don't know that I've already been to every top-rated Italian place within five miles because I am, as my guidance counselor once told me, a person who should pursue careers that have nothing to do with people. She said this to me when I was sixteen. I chose information processing. I've been counting things ever since.

The best restaurant recommendation I've ever received came from a person, not a platform. A friend who knows our taste. Who said "trust me, get the lamb shoulder" and was right.

## The Money Is Facing the Wrong Direction

Think about Yelp for a second. The platform you use to decide where to eat makes its money by selling your attention to the places competing for it. Restaurants that advertise appear higher in search results. Restaurants that don't see their reviews shuffled, their best ratings hidden behind a "not recommended" filter. Yelp denies this. Restaurant owners will tell you all about it if you buy them a drink.

But Yelp is almost beside the point now. The real action has moved to Google and to social media, and the incentives are worse.

Google reviews can be purchased in bulk — a hundred five-star reviews for about five hundred dollars. Many restaurants buy them. The ratings you see are a stew of genuine opinions, fake reviews, vindictive one-stars from people who had a bad day, and strategic five-stars planted by the business. Google's enforcement is a joke. The signal-to-noise ratio is catastrophic. And Google doesn't care, because the reviews aren't the product — your location data is.

On TikTok and Instagram, the incentive structure is even more naked. A restaurant pays an influencer $500 to post a video. The influencer posts a video. You see the video. You think it's a genuine recommendation. It isn't. It's an ad that doesn't look like an ad, served to you by an algorithm that rewards engagement over accuracy. The most-recommended restaurants on social media are not the best restaurants. They're the most photogenic, the most spectacle-forward, the best at buying attention.

Every one of these platforms has a business model that sits between you and the answer to your question, skimming something on the way through. None of them are trying to answer "where should we eat tonight?" They're trying to monetize the fact that you're asking.

## The New Place Problem

Every few months a new place opens near us. Good chef, interesting food, no reputation yet. It has seven Google reviews, three of which are from friends of the owner (you can tell). No TikTok presence. The Infatuation hasn't written about it.

Meanwhile, the mediocre pasta place that's been open for fifteen years has 1,800 reviews and a 4.1-star rating that will never change. The new place doesn't appear in any "top rated" search. It won't for months. By the time it accumulates enough reviews to surface, the algorithm will treat it the same as every other restaurant: a number between 3.5 and 4.5, stripped of context and personality and the thing that actually makes it worth visiting.

Every platform is biased toward the established, the optimized, the safe. The interesting places — the ones worth finding — are the hardest to discover through any of them.

And yet we keep opening the app, because what else is there?

## What I Actually Want

Strip all that away and the question is simple. I want to know: is this place good *for us*, *tonight*?

"For us" means it fits our taste, our price range, our mood. Not an averaged opinion from strangers — a specific recommendation from someone who knows what we like.

"Tonight" means it accounts for what we've done recently. Don't suggest the place we went to last week. Maybe suggest the place we loved four months ago and haven't been back to. Or the award-winning place we've been meaning to try for two years.

No app can answer this because no app has the data. Our visit history is scattered across credit card statements, Instagram stories, and Meriam's memory (which is considerably better than mine). Our taste profile doesn't exist in any database. The information we need to answer "where should we eat tonight?" lives entirely in our own experience.

Nobody has built a tool that uses it. So I am.

## Starting from Good Data

Here in Philadelphia, there's a useful counterpoint to the Yelp model: the Philly Mag 50 Best Restaurants list, published every year. It's curated by a small team of critics who eat at hundreds of restaurants a year. The list is opinionated, specific, and occasionally wrong — which makes it more trustworthy, not less. A human with biases is more useful than an algorithm pretending not to have them.

Then there's *Check, Please! Philly* on WHYY. Real diners recommending real restaurants to other real diners, on camera, with enthusiasm and specificity. Forty-one episodes. A hundred and twenty restaurant appearances. Six seasons of people telling you exactly why they love a place.

These are better than Yelp. They're curated by people with identifiable taste and no direct financial stake in the restaurants they cover. But they're one-directional — experts broadcasting to an audience. They can't tell me which of their 50 picks matches our mood tonight. They can't remember that we went to #12 last month and thought it was overpriced.

The data is good. The personalization is missing. What if I took that curated data — really good data — and married it to our own visit history and taste?

## Software for Two

There's a category of software that almost nobody builds: tools for two people.

Software for one person is a notebook. Software for a million people is a platform. But software for two people — shared state, shared decisions, two perspectives on the same data — that occupies a strange middle ground that the industry ignores completely.

It's too small to be a business. Too specific for a framework. Too intimate for venture capital. No VC fund is going to invest in an app for two people. No startup is going to build one. The economics don't work at that scale.

But the *engineering* works beautifully. Two users means no scaling problems. Known users means no abuse prevention. Shared taste means the recommendation algorithm can be simple and accurate. Owned data means no privacy concerns whatsoever.

The constraints that make "software for two" unviable as a business make it *ideal* as a product.

I learned this building TrueBlocks. Ten years of open-source blockchain tools. When you stop building for everyone and just build the thing you actually need, the design gets simple and the software gets good. The smaller the audience, the sharper the tool.

## The Part Where the AI Does Everything

Here's what I've been doing for the past couple weeks. I sit with the AI — currently GitHub Copilot in my editor, same tool I use for everything — and I *design*. I describe what I want. I talk about data models and user interfaces and how the recommendation engine should work. I argue about architecture. I sketch out database schemas.

The AI writes all the code. Every line. I haven't looked at a single line of source code. Not once.

I've been building software for over forty years. I started on an Apple IIe in 1981. I've written C, C++, Go, TypeScript, Solidity, and probably a dozen other languages I've mercifully forgotten. And now I'm building an entire application — desktop app, mobile PWA, API server, database, recommendation engine — without writing code.

It's like being an architect who can actually live in the house he designs. I draw the plans. I describe the rooms. I say "the kitchen should face east" and "I want built-in bookshelves in the study." And then the house *builds itself*.

I don't know what to call this exactly. "Vibe coding" is the term people are using. I think it's more like "vibe designing" — the code is a byproduct of the design conversation. The AI is not my assistant. It's more like a contractor who happens to be infinitely patient, never gets tired, and builds exactly what I describe. Sometimes it builds something slightly wrong and I say "no, not like that" and it fixes it immediately.

I have never enjoyed building software more than I do right now. Forty years in, and I finally feel like I'm just designing — which is all I ever wanted to do.

## What If Software Started This Small?

Here's the question I keep coming back to. What if this is how all software should start?

Not as a platform seeking users. Not as a startup seeking product-market fit. But as a tool built for two people, solving one specific problem, with zero ambition to scale.

What if that tool could, later, connect to another tool built by another person for another couple — not by merging into a platform, but by forming a direct peer-to-peer link? What if software grew sideways, through trust, the way restaurant recommendations actually travel?

Meriam's friend Jen loves restaurants. Jen has taste we trust. What if Jen built her own version of this thing, for herself and her husband, and then one day our two little apps just talked to each other? Shared favorites. Flagged disagreements. Not a social network. Not a platform. Just two households comparing notes, the way people have always done it, except now the software remembers.

Software that grows the way trust grows — one connection at a time, from the inside out. Like a spiral.

I don't know if that's a better world. But I know it's a different one. And I know that the restaurant app on my phone right now — the one with a billion reviews and a 4.2-star rating on the place I'd never go — isn't working.

Over the next few articles, I'm going to build this thing. A restaurant app for Meriam and me. I'll do the designing. The AI will do the coding. I won't look at the code. And I'll tell you how it goes, because I think this way of building software is going to change everything, and right now almost nobody is talking about it.

If you've ever closed Google Maps in frustration and gone to the same place you always go, you'll understand why.

---

*Next in the series: "Small Batch Apps: Software for Two" — on building software that doesn't scale, and why that's exactly the point.*

---

## Notes

Research and sources consulted during drafting and revision. Dated, with what we were looking for and what we found (or didn't).

**2026-05-17 — Does anyone still use Yelp?**

Attempted to verify current restaurant discovery habits. Searched for usage data from Statista, Pew Research, TODAY.com, Eater, Washington Post, Restaurant Dive, Forbes, NRN, and Yelp's own annual report. Most URLs returned 404s, paywalls, or redirects. Author confirmed: they use Google Maps, not Yelp. Nobody they know uses Yelp. This prompted a full rewrite — broadening the attack from Yelp specifically to the entire landscape (Google Maps, Yelp, TikTok, Instagram influencers, The Infatuation, OpenTable). The thesis shifted from "Yelp is broken" to "every player in this ecosystem has incentives that point away from the person asking the question."

**2026-05-17 — Revision 2: Broadened target, Google Maps opener**

Title changed from "The Problem with Yelp" to "Where Should We Eat Tonight?" Opening rewritten to use Google Maps (the app the author actually uses). Added TikTok/Instagram influencer economics section. Moved review-buying detail into the Google section. Removed fabricated restaurant "Helm" — replaced with generic [TODO] placeholder for author to fill with a real restaurant. Yelp demoted from main villain to one example among many.

**Sources still needed:**
- Current Yelp MAU/DAU numbers (are they declining?)
- Survey data on how people actually discover restaurants (Google Maps share vs. social media vs. review platforms)
- TikTok/Instagram restaurant influencer economics (how much of it is paid?)
- Google review fraud enforcement data
- Specific real restaurant to replace the [TODO] section
