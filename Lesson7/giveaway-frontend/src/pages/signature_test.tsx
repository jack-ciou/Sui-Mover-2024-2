import Image from "next/image";
import { Geist, Geist_Mono } from "next/font/google";
import { useEffect } from "react";
import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { fromHex, toHex } from "@mysten/sui/utils";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export default function Home() {
  useEffect(() => {
    const run = async () => {
      const keypair = Ed25519Keypair.generate();

      const secretKey = keypair.getSecretKey();
      const keypair2 = Ed25519Keypair.fromSecretKey(secretKey);
      console.log(
        keypair2.getPublicKey().toBase64() == keypair.getPublicKey().toBase64()
      );
      const publicKey = keypair.getPublicKey();
      const receiverAddress =
        "0x96d9a120058197fce04afcffa264f2f46747881ba78a91beb38f103c60e315ae";
      const messageBytes = fromHex(receiverAddress);
      const signature = await keypair.sign(messageBytes);

      const isValid = await publicKey.verify(messageBytes, signature);

      console.log({
        keypair,
        publicKey: toHex(publicKey.toRawBytes()),
        isValid,
        signature: toHex(signature),
      });
    };
    run();
  }, []);
  return (
    <div
      className={`${geistSans.variable} ${geistMono.variable} grid grid-rows-[20px_1fr_20px] items-center justify-items-center min-h-screen p-8 pb-20 gap-16 sm:p-20 font-[family-name:var(--font-geist-sans)]`}
    >
      Hello
    </div>
  );
}
