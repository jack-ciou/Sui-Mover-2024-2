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
import { createGift } from "@/giveaway/giveaway/giveaway/functions";
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
  const [suiBalance, setSuiBalance] = useState(0);
  const [suiAmountToSend, setSuiAmountToSend] = useState("0");

  const { mutate: disconnectWallet } = useDisconnectWallet();
  const { mutateAsync: signAndExecuteTransaction } =
    useSignAndExecuteTransaction();

  const router = useRouter();

  const suiClient = useSuiClient();
  useEffect(() => {
    const run = async () => {
      if (!address) return;
      const data = [];
      let cursor: string | null = null;
      while (true) {
        const result = await suiClient.getCoins({
          owner: address,
          coinType: "0x2::sui::SUI",
          cursor,
        });
        data.push(...result.data);
        cursor = result.nextCursor ?? null;
        if (!cursor) break;
      }

      console.log({ data });
      let totalBalance = 0;
      for (const coin of data) {
        totalBalance += Number(coin.balance);
      }
      totalBalance = totalBalance / 1e9;
      setSuiBalance(totalBalance);
    };
    run();
  }, [address]);

  const sendSui = async () => {
    if (!address) return;
    const keypair = Ed25519Keypair.generate();
    const publicKey = keypair.getPublicKey();
    const secretKey = keypair.getSecretKey();
    const tx = new Transaction();
    const coinInput = tx.splitCoins(tx.gas, [
      Number(suiAmountToSend) * 10 ** 9,
    ]);
    createGift(tx, "0x2::sui::SUI", {
      giftManager: process.env.NEXT_PUBLIC_GIFT_MANAGER_ID || "",
      coin: coinInput,
      vecU8: Array.from(publicKey.toRawBytes()),
    });
    const result = await signAndExecuteTransaction({
      transaction: tx,
    });
    router.push(`/claim/${secretKey}`);
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
        <div className="flex flex-col">
          <label className="text-sm mb-2">Current SUI Balance</label>
          <input
            type="text"
            readOnly
            value={`${suiBalance} SUI`}
            className="p-2 border rounded bg-gray-800 border-gray-700 text-white"
          />
        </div>

        <div className="flex flex-col">
          <label className="text-sm mb-2">Enter SUI Amount</label>
          <div className="flex gap-2">
            <input
              type="number"
              min="0"
              step="0.1"
              value={suiAmountToSend || ""}
              onChange={(e) => {
                setSuiAmountToSend(e.target.value);
              }}
              placeholder="Enter amount"
              className="p-2 border rounded flex-1 bg-gray-800 border-gray-700 text-white placeholder-gray-400"
            />
            <button
              className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
              onClick={sendSui}
            >
              Send
            </button>
          </div>
        </div>
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
