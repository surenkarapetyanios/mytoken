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