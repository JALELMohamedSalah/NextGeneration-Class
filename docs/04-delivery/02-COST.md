# Delivery 02. Cost: what "free first" really means

The client's principle stays: **prefer free and open-source tools, and never add a paid service without approval.** But a production app with file uploads cannot run at exactly 0 € with no limits. This file shows the real floor so the client can decide (Q11).

## Priority order for any technical choice
1. What the project already has
2. A free, open-source library
3. A free tier of a service
4. A simple custom implementation
5. A paid service, only when nothing free is reasonable, and only with written approval

## Running costs

| Need | Free option | Possible cost |
|---|---|---|
| Backend, database | Supabase free tier (limits on size, paused if inactive) | small VPS about 5 to 8 € per month (recommended) |
| File storage | included in the VPS disk or free tier | grows with photo submissions; a bigger disk or S3-compatible bucket later |
| HTTPS certificate | Let's Encrypt | free |
| Domain name | subdomain of the host | about 10 to 15 € per year for a custom domain (`.tn` or `.com`) |
| Push notifications | Firebase Cloud Messaging | free |
| Email | Gmail SMTP or a free transactional tier | free within daily limits |
| Video | Google Meet with the teacher's account | free |
| PDF, math rendering, charts | open-source libraries | free |
| Logo | Gemini + Figma free plan or Inkscape | free |
| Uptime monitoring | free monitoring tier | free |
| Android store | Google Play developer account | 25 USD once |
| iOS store | Apple Developer Program | 99 USD per year (avoidable: web version) |
| AI (later) | none really free at scale | pay per use with a cap, or the teacher's own key |

Free tier limits change often: check them on the day the backend is chosen.

## Three budget scenarios

| Scenario | Monthly | One-time / yearly | Trade-offs |
|---|---|---|---|
| **Strict 0 €** | 0 € | 0 € | Supabase free tier, web only (no Play Store), host subdomain, limits on storage, project may pause in holidays |
| **Recommended** | about 5 to 8 € | domain about 15 € per year, Play Store 25 USD once | no usage limits, Android app, own domain |
| **Full** | about 5 to 8 € | + Apple 99 USD per year | native iPhone app |

## Paid service approval template

Before adding anything paid, write this and get the client's written OK:

```
Service:
Why it is needed:
Free alternatives considered, and why they are not enough:
Estimated cost per month / per year:
Can it be postponed? Until when?
How to remove it later:
```

Nothing paid is added silently.
