# Cryptoreal RWA Token

ERC20 token for Real World Asset (RWA) tokenization with on-chain compliance.

## Overview

This contract implements a compliant RWA token for real estate tokenization.
It extends OpenZeppelin ERC20 with KYC verification and asset mapping.

- Only KYC-approved addresses can receive tokens
- Each tokenization is linked to an off-chain Asset ID
- Pausable and capped supply for security

## Deployment

- **Contract Address (Remix VM):** `0xd9145CCE52D386f254917e481eB44e9943F39138`
- **Transaction:** `0x3b51f94b0d99abfe420ed483eeccbc0a25acb357e36e9b438721036e568df13b`
- **Chain:** Tested on Remix VM - Ready for Base Sepolia / Arbitrum Sepolia
- **Compiler:** Solidity ^0.8.20

## Verified Execution
