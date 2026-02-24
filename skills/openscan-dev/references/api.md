# OpenScan API Reference

## Base URL

- Production: `https://beta.openscan.ai/api/v1`
- Local: `http://localhost:4000/api/v1`

## Blocks

| Method | Path | Description |
|--------|------|-------------|
| GET | `/blocks` | List blocks (page, limit, order) |
| GET | `/blocks/:number` | Block detail with tx count |
| GET | `/blocks/:number/transactions` | Transactions in block |

## Transactions

| Method | Path | Description |
|--------|------|-------------|
| GET | `/transactions` | List txs (page, limit, address, block) |
| GET | `/txs/:hash` | Transaction detail |
| GET | `/txs/internal` | Internal transactions |
| GET | `/txs/pending` | Mempool (pending txs) |

## Addresses

| Method | Path | Description |
|--------|------|-------------|
| GET | `/address/:hash` | Address info + balance |
| GET | `/address/:hash/transactions` | Address tx history |
| GET | `/address/:hash/tokens` | Token holdings |
| GET | `/address/:hash/logs` | Event logs |

## Tokens

| Method | Path | Description |
|--------|------|-------------|
| GET | `/tokens` | Token list (type, page) |
| GET | `/tokens/:address` | Token detail |
| GET | `/tokens/:address/holders` | Holder list |
| GET | `/tokens/:address/analytics` | Token analytics (ClickHouse) |
| GET | `/tokens/trending` | Trending tokens |

## Contracts

| Method | Path | Description |
|--------|------|-------------|
| GET | `/contracts` | Verified contracts list |
| GET | `/contracts/:address` | Contract detail with ABI |
| GET | `/contracts/:address/proxy` | Detect proxy pattern |
| GET | `/contracts/:address/verify` | Check verification status |
| GET | `/contracts/:address/source` | Fetch source from Sourcify |
| POST | `/verify` | Submit for verification |
| POST | `/verify/reverify` | Force re-verification |

## Gas

| Method | Path | Description |
|--------|------|-------------|
| GET | `/gas` | Current gas price + USD costs |
| GET | `/gas/history` | Gas price history (24h) |

## Decode

| Method | Path | Description |
|--------|------|-------------|
| GET | `/decode/input/:data` | Decode method signature |
| GET | `/decode/event/:topic0` | Decode event topic |
| POST | `/decode/batch` | Batch decode multiple inputs |

## Analytics / Charts

| Method | Path | Description |
|--------|------|-------------|
| GET | `/charts/tps` | Transaction throughput |
| GET | `/charts/gas` | Gas utilization |
| GET | `/analytics/network` | Real-time network stats |
| GET | `/stats/network` | Extended network stats |

## Portfolio

| Method | Path | Description |
|--------|------|-------------|
| POST | `/portfolio` | Create portfolio |
| GET | `/portfolio/:id` | Portfolio with balances |
| GET | `/portfolio/:id/activity` | Activity feed |
| DELETE | `/portfolio/:id` | Delete portfolio |
| GET | `/portfolios` | List all portfolios |

## GraphQL

```
POST /api/v1/graphql
GET  /api/v1/graphql/playground

# Example query
{
  networkStats { latestBlock totalTransactions tps }
  blocks(limit: 5) { number hash timestamp txCount }
}
```

## WebSocket

```
ws://localhost:4000/api/v1/ws/live

# Messages from server:
{ type: "block", data: {...} }
{ type: "transaction", data: {...} }
{ type: "log", data: {...} }

# Subscribe to address
{ action: "subscribe", address: "0x..." }
```

## Watchlist

| Method | Path | Description |
|--------|------|-------------|
| GET | `/watchlist` | Get watched addresses |
| POST | `/watchlist` | Add address |
| DELETE | `/watchlist/:id` | Remove address |

## Etherscan Compatibility

```
GET /api?module=account&action=txlist&address=0x...
GET /api?module=block&action=getblockreward&blockno=123
GET /api?module=gastracker&action=gasoracle
GET /api?module=stats&action=ethsupply
GET /api?module=proxy&action=eth_getBlockByNumber
```

## Response Format

```json
{
  "items": [...],
  "total": 12345,
  "page": 1,
  "limit": 10,
  "next_page_params": { "block_number": 123, "index": 0 }
}
```
