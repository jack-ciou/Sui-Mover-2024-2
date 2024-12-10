import { Transaction } from "@mysten/sui/transactions";
import {
  KAPY_ADVENTURE_PACKGE_ID,
  KAPY_WORLD_OBJECT_ID,
  KAPY_GOD_POWER_OBJECT_ID,
  signer,
  client,
  recipients,
} from "./config";

async function main() {
  const tx = new Transaction();
  for (const recipient of recipients) {
    const [kapyCrew] = tx.moveCall({
      target: `${KAPY_ADVENTURE_PACKGE_ID}::kapy_crew::build_crew_by_god`,
      arguments: [
        tx.object(KAPY_WORLD_OBJECT_ID),
        tx.object(KAPY_GOD_POWER_OBJECT_ID),
        tx.pure.string(""),
      ],
    });
    tx.transferObjects([kapyCrew], recipient);
  }

  const res = await client.signAndExecuteTransaction({
    transaction: tx,
    signer,
    options: {
      showEffects: true,
    },
  });
  console.log(res.effects?.created?.length);
}

main().catch((err) => console.log(err));
