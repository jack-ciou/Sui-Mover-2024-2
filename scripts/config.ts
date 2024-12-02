import config from "./config.json";
import { SuiClient, getFullnodeUrl } from "@mysten/sui/client";
import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";

export const KAPY_ADVENTURE_PACKGE_ID =
  "0xc00d69e58132d45903419bd1734cf0ce6b61352d9eedb241cfd2d0cad32e1de8";
export const KAPY_WORLD_OBJECT_ID =
  "0x068d5ff571b34d02fbe1cd0a8f748d496e3f626a4833bb238900e090343482e4";
export const KAPY_GOD_POWER_OBJECT_ID =
  "0x855da207a12b73330555a738694ad189b87fc859f287ebc0b36feb919ea96893";

export const signer = Ed25519Keypair.fromSecretKey(config.privateKey);
export const client = new SuiClient({
  url: config.rpcUrl ?? getFullnodeUrl("mainnet"),
});

export const recipients = config.recipients;
