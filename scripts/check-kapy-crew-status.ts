import { EventId } from "@mysten/sui/client";
import { KAPY_ADVENTURE_PACKGE_ID, client } from "./config";

async function main() {
  const scoreMap = new Map<number, number>([]);
  let cursor: EventId | null | undefined = null;
  let hasNextPage = true;
  while (hasNextPage) {
    const res = await client.queryEvents({
      query: {
        MoveEventType: `${KAPY_ADVENTURE_PACKGE_ID}::events::Recruit`,
      },
      cursor,
    });
    for (const data of res.data) {
      const fields = data.parsedJson as any;
      const pirateKind = Number(fields.pirate_kind);
      scoreMap.set(pirateKind, (scoreMap.get(pirateKind) ?? 0) + 1);
    }
    hasNextPage = res.hasNextPage;
    cursor = res.nextCursor;
  }

  console.log(
    Array.from(scoreMap.entries()).map((entry) =>
      console.log(`${entry[0]}: ${entry[1]}`),
    ),
  );
}

main().catch((err) => console.log(err));
