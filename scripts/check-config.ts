import {
  KAPY_ADVENTURE_PACKGE_ID,
  KAPY_WORLD_OBJECT_ID,
  KAPY_GOD_POWER_OBJECT_ID,
  signer,
  client,
  recipients,
} from "./config";

async function main() {
  console.log("KAPY_ADVENTURE_PACKGE_ID:", KAPY_ADVENTURE_PACKGE_ID);
  console.log("KAPY_WORLD_OBJECT_ID:", KAPY_WORLD_OBJECT_ID);
  console.log("KAPY_GOD_POWER_OBJECT_ID:", KAPY_GOD_POWER_OBJECT_ID);
  console.log(
    "KapyWorld:",
    await client.getObject({ id: KAPY_WORLD_OBJECT_ID }),
  );
  console.log("signer:", signer.toSuiAddress());
  console.log("recipients:", recipients);
}

main().catch((err) => console.log(err));
