import {PUBLISHED_AT} from "..";
import {obj, pure} from "../../_framework/util";
import {Transaction, TransactionArgument, TransactionObjectInput} from "@mysten/sui/transactions";

export function init( tx: Transaction, ) { return tx.moveCall({ target: `${PUBLISHED_AT}::giveaway::init`, arguments: [ ], }) }

export interface CreateGiftArgs { giftManager: TransactionObjectInput; coin: TransactionObjectInput; vecU8: Array<number | TransactionArgument> | TransactionArgument }

export function createGift( tx: Transaction, typeArg: string, args: CreateGiftArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::giveaway::create_gift`, typeArguments: [typeArg], arguments: [ obj(tx, args.giftManager), obj(tx, args.coin), pure(tx, args.vecU8, `vector<u8>`) ], }) }

export interface WithdrawGiftArgs { giftManager: TransactionObjectInput; address: string | TransactionArgument; vecU81: Array<number | TransactionArgument> | TransactionArgument; vecU82: Array<number | TransactionArgument> | TransactionArgument }

export function withdrawGift( tx: Transaction, typeArg: string, args: WithdrawGiftArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::giveaway::withdraw_gift`, typeArguments: [typeArg], arguments: [ obj(tx, args.giftManager), pure(tx, args.address, `address`), pure(tx, args.vecU81, `vector<u8>`), pure(tx, args.vecU82, `vector<u8>`) ], }) }
