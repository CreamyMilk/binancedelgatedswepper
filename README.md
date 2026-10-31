# The Binance ~$5.6–6.3B Drain: A Modern EVM Exploitation

It wasn't a complex logic bug. It was an **EIP-7702 delegation hijack**.

## How It Happened

1. **Setup**
   The attacker funds `0x7C8601d4645b93cea45F71e118A729332e6b5CA0` via Tornado Cash, deploys a sweep contract (`0x63e842B054Bd624a465454D533C33F573e9c6fAe`), and runs three live dry-runs on external wallets.

2. **Execution**
   The attacker submits an EIP-7702 (type-4) batch (tx `0xad99264d…`) with **50 pre-signed authorizations** (nonces `18,914,775` to `18,914,824`) to hit Binance 14's moving nonce window.

3. **One authorization hits**
   Instantly, Binance 14 (`0x28C6c06298d514Db089934071355E5743bf21d60`, an EOA) is reprogrammed to run the attacker's contract bytecode:

   ```
   0xef0100 + 0x63e842B054Bd624a465454D533C33F573e9c6fAe
   ```

   *(delegation designator + sweep contract address)*

4. **Execution looks totally organic**
   Binance 14 sweeps itself clean. The first major sweep tx (`0x53bd38b8…`, at ~20:24:23 UTC) moved:

   - ~**167,464 ETH**
   - **63 tokens**, including ~**1.615B USDT**

   All of it went to receiver `0x5227f603C1eE34CE3C06eFe6477003BDfCCB2f8c`.

   Internal threshold alerts don't trigger because, from the nodes' perspective, the hot wallet is just executing its own transaction.

5. **Binance 16 feeds the loop**
   Automated treasury rebalance scripts make Binance 16 auto-refill / transfer ~**28,000–28,005.6 ETH** (plus other tokens), which feeds the exploit loop and goes to the same receiver.

## The Cold Truth

> **You cannot forge an EIP-7702 delegation list.**

For this to execute, the attacker already held the raw private key, or unconstrained signing access to Binance 14's HSM/KMS (or to the withdrawal-submission infrastructure that could produce those signatures).

## The Aftermath

- **~$5.6–6.3B** drained across ETH, BTC, Tron, and other chains.
- **~$2.5–2.7B+** frozen within hours by Tether, Circle, Ripple, World Liberty, and others.

*Code is law until the stablecoin admin keys log in.*

Binance got bailed out by the very centralized choke points the cypherpunks warned you about.