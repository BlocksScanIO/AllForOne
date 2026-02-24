---
name: openscan-dev
description: "OpenScan.ai blockchain explorer development assistant (OsAi). Use when working on the OpenScan.ai / XDCScan.io platform — building, deploying, debugging, or extending the Web3 blockchain explorer for XDC Network. Covers Next.js frontend, Fastify API, Go indexer, Prisma/PostgreSQL, Redis, ClickHouse, GraphQL, WebSocket feeds, contract verification, DEX indexing, and PM2 deployment on the live server (65.21.71.4). Use for any task related to XDCScan, openscan-platform monorepo, or XDC Network."
---

# OpenScan.ai Development Intelligence (OsAi)

**Mission:** Ship the world's best Web3 blockchain explorer for XDC Network.

## Stack at a Glance

| Layer | Tech |
|-------|------|
| Frontend | Next.js 14 App Router, Tailwind, shadcn/ui |
| API | Fastify + Prisma + PostgreSQL 17 |
| Indexer | Go (high-perf, XDPoS 2.0 aware) |
| Cache | Redis 7 |
| Analytics | ClickHouse |
| Monorepo | Turborepo + pnpm workspaces |
| Process mgr | PM2 |
| CI/CD | GitHub Actions |

## Server (65.21.71.4)

- OS: Ubuntu 24.04 LTS
- Data: `/mnt/data` (1.9TB NVMe) — Docker + PostgreSQL + project data
- Repo: `/tmp/openscan-platform`
- SSH: `ssh root@65.21.71.4`

**CRITICAL:** PostgreSQL runs in Docker (`openscan-postgres` container, port 5432). Always use Docker exec for DB operations, NOT native psql.

```bash
# Correct — Docker container
docker exec -i openscan-postgres psql -U openscan -d openscan < query.sql

# Wrong — native postgres (different instance)
sudo -u postgres psql openscan  # ← data lives elsewhere!
```

## PM2 Services

| Name | Port | What |
|------|------|------|
| `openscan-web` | 3000 | Next.js frontend |
| `openscan-api` | 4000 | Fastify REST + GraphQL + WebSocket |
| `openscan-indexer` | — | Go block indexer |
| `openscan-price` | — | XDC price fetcher |
| `old-api` | 5001 | Blockscout compat (bscompat schema) |

```bash
# Deploy cycle
cd /tmp/openscan-platform
npx prisma generate           # after schema changes
npm run build                 # or: cd apps/api && npm run build
pm2 restart openscan-api
pm2 restart openscan-web

# Start fresh from ecosystem
pm2 delete openscan-api && pm2 start ecosystem.config.js --only openscan-api
```

## Git Identity Rules

```bash
# PRIVATE repos → anilchinchawale
git config user.name "anilchinchawale"
git config user.email "anil24593@gmail.com"

# PUBLIC repos → BlocksScanIO
git config user.name "BlocksScanIO"
git config user.email "blocksscanio@gmail.com"
```

## Key Architecture Decisions

- **Cursor pagination only** — never OFFSET at scale
- **Redis for TTL cache** — all hot endpoints cache 5–30s
- **ClickHouse for analytics** — block_stats, tx_stats tables
- **Go indexer** — targets 500+ blocks/sec; XDPoS 2.0 epoch-aware
- **Sourcify for verification** — `POST /api/v1/verify`
- **4byte.directory** — fallback for method signature decoding
- **Port 5432 = Docker** — always, not native PostgreSQL

## API Route Map

```
/api/v1/
  blocks, transactions, addresses, tokens, contracts
  gas, gas/history
  decode/input/:data, decode/event/:topic0
  contracts/:address/proxy
  contracts/:address/verify, contracts/:address/source
  verify, verify/reverify
  portfolio, portfolios
  graphql (Apollo Server)
  ws/live (WebSocket real-time feed)
  charts/tps, charts/gas
  watchlist
```

See `references/api.md` for full endpoint reference.

## Prisma Schema Notes

- Model name → `@@map` controls actual table name
- `Block`, `Transaction`, `Address`, `Token`, `Contract` are PascalCase in schema
- After schema changes: `npx prisma generate && npm run build`
- New tables: create in Docker PostgreSQL with SQL file, then add model to schema

```bash
# Create table in correct DB
cat > /tmp/migration.sql << 'SQL'
CREATE TABLE IF NOT EXISTS my_table (...);
SQL
docker exec -i openscan-postgres psql -U openscan -d openscan < /tmp/migration.sql
```

## XDC Network Facts

- Chain ID: 50 (mainnet), 51 (Apothem testnet)
- Consensus: XDPoS 2.0 (EVM-compatible)
- Block time: ~2 seconds
- Epoch: 900 blocks, 108 masternodes
- Native token: XDC (18 decimals)
- XDPoS2 switch block: ~1,000,000
- System contracts: `0x...0088` (ValidatorSet), `0x...0090` (Staking)

## Common Debugging

```bash
# Check API is live
curl http://localhost:4000/api/v1/stats

# Check indexer block height
redis-cli get indexer:progress

# Check Docker DB tables
docker exec openscan-postgres psql -U openscan -d openscan -c "\dt"

# API logs (recent)
tail -50 ~/.pm2/logs/openscan-api-out.log
tail -50 ~/.pm2/logs/openscan-api-error.log

# Indexer logs
tail -50 ~/.pm2/logs/openscan-indexer-out.log
```

## References

- `references/api.md` — Full endpoint reference
- `references/schema.md` — Database schema overview
- `references/xdposv2.md` — XDPoS 2.0 consensus details
- `scripts/create_table.sh` — Helper to create tables in Docker PostgreSQL
