# ERC20 Token Project (Test Task)

## Overview
- ERC20 token implementation with mint functionality.
- Unit tests for all major features.
- Viem + Vite browser frontend with owner-only mint enforcement.

## Setup
```bash
npm install
npx hardhat node
npx hardhat run scripts/deploy.cjs --network localhost
```


## Viem Browser Frontend
```bash
cd frontend
npm install
npm run dev
```

Then open your browser at:

```
http://localhost:5173
```
---

## MetaMask Localhost Setup (Hardhat)

1. Open MetaMask → Networks → Add Network manually
2. Fill in the following:
   - **Network Name**: Hardhat Localhost
   - **New RPC URL**: http://127.0.0.1:8545
   - **Chain ID**: 31337
   - **Currency Symbol**: ETH
3. Save and switch to the Hardhat Localhost network
4. Import a private key from one of the test accounts printed by `npx hardhat node`
5. You should now see 10000 ETH in that account

---

Make sure to set the deployed token address in `frontend/.env`:
```env
VITE_TOKEN_ADDRESS=0xYourDeployedTokenAddress
```

## Tests
```bash
npx hardhat test
```

## Notes
- Written from scratch without OpenZeppelin.
- All standard ERC20 functions plus `mint`, `approve`, and `transferFrom`.
- Owner-restricted `mint()` enforced both on-chain and in the frontend.
- Clean, auditable, and fully Viem-integrated.
