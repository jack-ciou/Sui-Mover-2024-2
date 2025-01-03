import Image from "next/image";
import { Geist, Geist_Mono } from "next/font/google";
import { useEffect, useState } from "react";
import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { fromHex, toHex } from "@mysten/sui/utils";
import {
  useCurrentWallet,
  ConnectButton,
  useSuiClient,
  useDisconnectWallet,
  useSignAndExecuteTransaction,
} from "@mysten/dapp-kit";
import "@mysten/dapp-kit/dist/index.css";

import { Transaction } from "@mysten/sui/transactions";
import {
  createGift,
  withdrawGift,
} from "@/giveaway/giveaway/giveaway/functions";
import { useRouter } from "next/router";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export default function Home() {
  const { currentWallet, connectionStatus } = useCurrentWallet();
  const address = currentWallet?.accounts?.[0].address;

  const router = useRouter();
  const { secretKey } = router.query;

  const { mutate: disconnectWallet } = useDisconnectWallet();
  const { mutateAsync: signAndExecuteTransaction } =
    useSignAndExecuteTransaction();

  const [publicKey, setPublicKey] = useState<number[]>([]);
  const [giftValue, setGiftValue] = useState<number>(0);

  const suiClient = useSuiClient();

  useEffect(() => {
    const run = async () => {};
    run();
  }, [address]);

  useEffect(() => {
    if (!secretKey) return;
    const keypair = Ed25519Keypair.fromSecretKey(secretKey as string);
    const publicKey = keypair.getPublicKey();
    setPublicKey(Array.from(publicKey.toRawBytes()));
    const run = async () => {
      const giftManager = await suiClient.getObject({
        id: process.env.NEXT_PUBLIC_GIFT_MANAGER_ID || "",
        options: {
          showContent: true,
        },
      });
      const objectBagId = (giftManager.data as any).content.fields.gifts.fields
        .id.id;
      const objectBag = await suiClient.getDynamicFieldObject({
        parentId: objectBagId,
        name: {
          type: "vector<u8>",
          value: Array.from(publicKey.toRawBytes()),
        },
      });
      const value = (objectBag.data as any).content.fields.value;
      console.log({ giftManager, objectBagId, objectBag, value });
      setGiftValue(Number(BigInt(value) / BigInt(10 ** 9)));
    };
    run();
  }, [secretKey]);

  const claimGift = async () => {
    if (!secretKey || !address) return;
    const tx = new Transaction();
    const keypair = Ed25519Keypair.fromSecretKey(secretKey as string);
    const publicKey = keypair.getPublicKey();
    const messageBytes = fromHex(address);
    const signature = await keypair.sign(messageBytes);
    withdrawGift(tx, "0x2::sui::SUI", {
      giftManager: process.env.NEXT_PUBLIC_GIFT_MANAGER_ID || "",
      address,
      vecU81: Array.from(signature),
      vecU82: Array.from(publicKey.toRawBytes()),
    });
    const result = await signAndExecuteTransaction({
      transaction: tx,
    });
    console.log(result);
  };

  if (!currentWallet)
    return (
      <div className="h-screen w-full flex items-center justify-center">
        <ConnectButton />
      </div>
    );
  return (
    <div
      className={`${geistSans.variable} ${geistMono.variable} flex items-center justify-center min-h-screen p-8 pb-20 gap-16 sm:p-20 font-[family-name:var(--font-geist-sans)] bg-gray-900 text-white`}
    >
      <div className="flex flex-col gap-4 w-full max-w-md">
        <div className="flex flex-col gap-2">
          <p className="text-lg font-bold">Gift Value {giftValue} SUI</p>
        </div>
        <button
          className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
          onClick={async () => {
            await claimGift();
          }}
        >
          Claim Gift
        </button>
        <button
          className="px-4 py-2 bg-gray-500 text-white rounded hover:bg-gray-600"
          onClick={() => disconnectWallet()}
        >
          Disconnect
        </button>
      </div>
    </div>
  );
}
