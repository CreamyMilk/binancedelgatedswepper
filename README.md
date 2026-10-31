# Binance Delegated sweep contract analysis 

The Binance ~$5.6–6.3B drain is a masterclass in modern EVM exploitation.
It wasn’t a complex logic bug. It was an EIP-7702 delegation hijack:
	1	Setup: Attacker funds 0x7C8601d4645b93cea45F71e118A729332e6b5CA0 via Tornado Cash, deploys a sweep contract (0x63e842B054Bd624a465454D533C33F573e9c6fAe), and runs three live dry-runs on external wallets.
	2	Execution: Attacker submits an EIP-7702 (type-4) batch (tx 0xad99264d…) with 50 pre-signed authorizations (nonces 18,914,775 to 18,914,824) to hit Binance 14’s moving nonce window.
	3	One authorization hits. Instantly, Binance 14 (0x28C6c06298d514Db089934071355E5743bf21d60, an EOA) is reprogrammed to run the attacker’s contract bytecode (delegation designator 0xef0100 + 0x63e842B054Bd624a465454D533C33F573e9c6fAe).
	4	Execution looks totally organic: Binance 14 sweeps itself clean (first major sweep tx 0x53bd38b8… at ~20:24:23 UTC moved ~167,464 ETH + 63 tokens, including ~1.615B USDT, to receiver 0x5227f603C1eE34CE3C06eFe6477003BDfCCB2f8c). Internal threshold alerts don’t trigger because, from the nodes’ perspective, the hot wallet is just executing its own transaction.
	5	Binance 16 immediately auto-refills / transfers ~28,000–28,005.6 ETH (plus other tokens) due to automated treasury rebalance scripts, feeding the exploit loop to the same receiver.
The cold truth: you cannot forge an EIP-7702 delegation list. For this to execute, the attacker already held the raw private key or unconstrained signing access to Binance 14’s HSM/KMS (or the withdrawal-submission infrastructure that could produce those signatures).
But hey — ~5.6–6.3 billion drained across ETH, BTC, Tron and other chains. ~2.5–2.7+ billion frozen by Tether, Circle, Ripple, and World Liberty (and others) within hours.
Code is law until the stablecoin admin keys log in.
Binance got bailed out by the very centralized choke points the cypherpunks warned you about.
Hardware wallets leak your home address. Centralized exchanges leak the keys to the kingdom.
Self-custody on native, non-delegated chains remains the only honest baseline.
At least you know what to avoid.
