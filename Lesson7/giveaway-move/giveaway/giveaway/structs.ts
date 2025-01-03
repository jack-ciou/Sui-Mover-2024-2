import * as reified from "../../_framework/reified";
import {Balance} from "../../_dependencies/onchain/0x2/balance/structs";
import {ObjectBag} from "../../_dependencies/onchain/0x2/object-bag/structs";
import {UID} from "../../_dependencies/onchain/0x2/object/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, StructClass, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, fieldToJSON, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType, parseTypeName} from "../../_framework/util";
import {Vector} from "../../_framework/vector";
import {PKG_V1} from "../index";
import {bcs} from "@mysten/sui/bcs";
import {SuiClient, SuiObjectData, SuiParsedData} from "@mysten/sui/client";
import {fromB64} from "@mysten/sui/utils";

/* ============================== Gift =============================== */

export function isGift(type: string): boolean { type = compressSuiType(type); return type.startsWith(`${PKG_V1}::giveaway::Gift` + '<'); }

export interface GiftFields<T0 extends PhantomTypeArgument> { id: ToField<UID>; publicKey: ToField<Vector<"u8">>; value: ToField<Balance<T0>> }

export type GiftReified<T0 extends PhantomTypeArgument> = Reified< Gift<T0>, GiftFields<T0> >;

export class Gift<T0 extends PhantomTypeArgument> implements StructClass { __StructClass = true as const;

 static readonly $typeName = `${PKG_V1}::giveaway::Gift`; static readonly $numTypeParams = 1; static readonly $isPhantom = [true,] as const;

 readonly $typeName = Gift.$typeName; readonly $fullTypeName: `${typeof PKG_V1}::giveaway::Gift<${PhantomToTypeStr<T0>}>`; readonly $typeArgs: [PhantomToTypeStr<T0>]; readonly $isPhantom = Gift.$isPhantom;

 readonly id: ToField<UID>; readonly publicKey: ToField<Vector<"u8">>; readonly value: ToField<Balance<T0>>

 private constructor(typeArgs: [PhantomToTypeStr<T0>], fields: GiftFields<T0>, ) { this.$fullTypeName = composeSuiType( Gift.$typeName, ...typeArgs ) as `${typeof PKG_V1}::giveaway::Gift<${PhantomToTypeStr<T0>}>`; this.$typeArgs = typeArgs;

 this.id = fields.id;; this.publicKey = fields.publicKey;; this.value = fields.value; }

 static reified<T0 extends PhantomReified<PhantomTypeArgument>>( T0: T0 ): GiftReified<ToPhantomTypeArgument<T0>> { return { typeName: Gift.$typeName, fullTypeName: composeSuiType( Gift.$typeName, ...[extractType(T0)] ) as `${typeof PKG_V1}::giveaway::Gift<${PhantomToTypeStr<ToPhantomTypeArgument<T0>>}>`, typeArgs: [ extractType(T0) ] as [PhantomToTypeStr<ToPhantomTypeArgument<T0>>], isPhantom: Gift.$isPhantom, reifiedTypeArgs: [T0], fromFields: (fields: Record<string, any>) => Gift.fromFields( T0, fields, ), fromFieldsWithTypes: (item: FieldsWithTypes) => Gift.fromFieldsWithTypes( T0, item, ), fromBcs: (data: Uint8Array) => Gift.fromBcs( T0, data, ), bcs: Gift.bcs, fromJSONField: (field: any) => Gift.fromJSONField( T0, field, ), fromJSON: (json: Record<string, any>) => Gift.fromJSON( T0, json, ), fromSuiParsedData: (content: SuiParsedData) => Gift.fromSuiParsedData( T0, content, ), fromSuiObjectData: (content: SuiObjectData) => Gift.fromSuiObjectData( T0, content, ), fetch: async (client: SuiClient, id: string) => Gift.fetch( client, T0, id, ), new: ( fields: GiftFields<ToPhantomTypeArgument<T0>>, ) => { return new Gift( [extractType(T0)], fields ) }, kind: "StructClassReified", } }

 static get r() { return Gift.reified }

 static phantom<T0 extends PhantomReified<PhantomTypeArgument>>( T0: T0 ): PhantomReified<ToTypeStr<Gift<ToPhantomTypeArgument<T0>>>> { return phantom(Gift.reified( T0 )); } static get p() { return Gift.phantom }

 static get bcs() { return bcs.struct("Gift", {

 id: UID.bcs, public_key: bcs.vector(bcs.u8()), value: Balance.bcs

}) };

 static fromFields<T0 extends PhantomReified<PhantomTypeArgument>>( typeArg: T0, fields: Record<string, any> ): Gift<ToPhantomTypeArgument<T0>> { return Gift.reified( typeArg, ).new( { id: decodeFromFields(UID.reified(), fields.id), publicKey: decodeFromFields(reified.vector("u8"), fields.public_key), value: decodeFromFields(Balance.reified(typeArg), fields.value) } ) }

 static fromFieldsWithTypes<T0 extends PhantomReified<PhantomTypeArgument>>( typeArg: T0, item: FieldsWithTypes ): Gift<ToPhantomTypeArgument<T0>> { if (!isGift(item.type)) { throw new Error("not a Gift type");

 } assertFieldsWithTypesArgsMatch(item, [typeArg]);

 return Gift.reified( typeArg, ).new( { id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), publicKey: decodeFromFieldsWithTypes(reified.vector("u8"), item.fields.public_key), value: decodeFromFieldsWithTypes(Balance.reified(typeArg), item.fields.value) } ) }

 static fromBcs<T0 extends PhantomReified<PhantomTypeArgument>>( typeArg: T0, data: Uint8Array ): Gift<ToPhantomTypeArgument<T0>> { return Gift.fromFields( typeArg, Gift.bcs.parse(data) ) }

 toJSONField() { return {

 id: this.id,publicKey: fieldToJSON<Vector<"u8">>(`vector<u8>`, this.publicKey),value: this.value.toJSONField(),

} }

 toJSON() { return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() } }

 static fromJSONField<T0 extends PhantomReified<PhantomTypeArgument>>( typeArg: T0, field: any ): Gift<ToPhantomTypeArgument<T0>> { return Gift.reified( typeArg, ).new( { id: decodeFromJSONField(UID.reified(), field.id), publicKey: decodeFromJSONField(reified.vector("u8"), field.publicKey), value: decodeFromJSONField(Balance.reified(typeArg), field.value) } ) }

 static fromJSON<T0 extends PhantomReified<PhantomTypeArgument>>( typeArg: T0, json: Record<string, any> ): Gift<ToPhantomTypeArgument<T0>> { if (json.$typeName !== Gift.$typeName) { throw new Error("not a WithTwoGenerics json object") }; assertReifiedTypeArgsMatch( composeSuiType(Gift.$typeName, extractType(typeArg)), json.$typeArgs, [typeArg], )

 return Gift.fromJSONField( typeArg, json, ) }

 static fromSuiParsedData<T0 extends PhantomReified<PhantomTypeArgument>>( typeArg: T0, content: SuiParsedData ): Gift<ToPhantomTypeArgument<T0>> { if (content.dataType !== "moveObject") { throw new Error("not an object"); } if (!isGift(content.type)) { throw new Error(`object at ${(content.fields as any).id} is not a Gift object`); } return Gift.fromFieldsWithTypes( typeArg, content ); }

 static fromSuiObjectData<T0 extends PhantomReified<PhantomTypeArgument>>( typeArg: T0, data: SuiObjectData ): Gift<ToPhantomTypeArgument<T0>> { if (data.bcs) { if (data.bcs.dataType !== "moveObject" || !isGift(data.bcs.type)) { throw new Error(`object at is not a Gift object`); }

 const gotTypeArgs = parseTypeName(data.bcs.type).typeArgs; if (gotTypeArgs.length !== 1) { throw new Error(`type argument mismatch: expected 1 type argument but got '${gotTypeArgs.length}'`); }; const gotTypeArg = compressSuiType(gotTypeArgs[0]); const expectedTypeArg = compressSuiType(extractType(typeArg)); if (gotTypeArg !== compressSuiType(extractType(typeArg))) { throw new Error(`type argument mismatch: expected '${expectedTypeArg}' but got '${gotTypeArg}'`); };

 return Gift.fromBcs( typeArg, fromB64(data.bcs.bcsBytes) ); } if (data.content) { return Gift.fromSuiParsedData( typeArg, data.content ) } throw new Error( "Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request." ); }

 static async fetch<T0 extends PhantomReified<PhantomTypeArgument>>( client: SuiClient, typeArg: T0, id: string ): Promise<Gift<ToPhantomTypeArgument<T0>>> { const res = await client.getObject({ id, options: { showBcs: true, }, }); if (res.error) { throw new Error(`error fetching Gift object at id ${id}: ${res.error.code}`); } if (res.data?.bcs?.dataType !== "moveObject" || !isGift(res.data.bcs.type)) { throw new Error(`object at id ${id} is not a Gift object`); }

 return Gift.fromSuiObjectData( typeArg, res.data ); }

 }

/* ============================== GiftManager =============================== */

export function isGiftManager(type: string): boolean { type = compressSuiType(type); return type === `${PKG_V1}::giveaway::GiftManager`; }

export interface GiftManagerFields { id: ToField<UID>; gifts: ToField<ObjectBag> }

export type GiftManagerReified = Reified< GiftManager, GiftManagerFields >;

export class GiftManager implements StructClass { __StructClass = true as const;

 static readonly $typeName = `${PKG_V1}::giveaway::GiftManager`; static readonly $numTypeParams = 0; static readonly $isPhantom = [] as const;

 readonly $typeName = GiftManager.$typeName; readonly $fullTypeName: `${typeof PKG_V1}::giveaway::GiftManager`; readonly $typeArgs: []; readonly $isPhantom = GiftManager.$isPhantom;

 readonly id: ToField<UID>; readonly gifts: ToField<ObjectBag>

 private constructor(typeArgs: [], fields: GiftManagerFields, ) { this.$fullTypeName = composeSuiType( GiftManager.$typeName, ...typeArgs ) as `${typeof PKG_V1}::giveaway::GiftManager`; this.$typeArgs = typeArgs;

 this.id = fields.id;; this.gifts = fields.gifts; }

 static reified( ): GiftManagerReified { return { typeName: GiftManager.$typeName, fullTypeName: composeSuiType( GiftManager.$typeName, ...[] ) as `${typeof PKG_V1}::giveaway::GiftManager`, typeArgs: [ ] as [], isPhantom: GiftManager.$isPhantom, reifiedTypeArgs: [], fromFields: (fields: Record<string, any>) => GiftManager.fromFields( fields, ), fromFieldsWithTypes: (item: FieldsWithTypes) => GiftManager.fromFieldsWithTypes( item, ), fromBcs: (data: Uint8Array) => GiftManager.fromBcs( data, ), bcs: GiftManager.bcs, fromJSONField: (field: any) => GiftManager.fromJSONField( field, ), fromJSON: (json: Record<string, any>) => GiftManager.fromJSON( json, ), fromSuiParsedData: (content: SuiParsedData) => GiftManager.fromSuiParsedData( content, ), fromSuiObjectData: (content: SuiObjectData) => GiftManager.fromSuiObjectData( content, ), fetch: async (client: SuiClient, id: string) => GiftManager.fetch( client, id, ), new: ( fields: GiftManagerFields, ) => { return new GiftManager( [], fields ) }, kind: "StructClassReified", } }

 static get r() { return GiftManager.reified() }

 static phantom( ): PhantomReified<ToTypeStr<GiftManager>> { return phantom(GiftManager.reified( )); } static get p() { return GiftManager.phantom() }

 static get bcs() { return bcs.struct("GiftManager", {

 id: UID.bcs, gifts: ObjectBag.bcs

}) };

 static fromFields( fields: Record<string, any> ): GiftManager { return GiftManager.reified( ).new( { id: decodeFromFields(UID.reified(), fields.id), gifts: decodeFromFields(ObjectBag.reified(), fields.gifts) } ) }

 static fromFieldsWithTypes( item: FieldsWithTypes ): GiftManager { if (!isGiftManager(item.type)) { throw new Error("not a GiftManager type");

 }

 return GiftManager.reified( ).new( { id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), gifts: decodeFromFieldsWithTypes(ObjectBag.reified(), item.fields.gifts) } ) }

 static fromBcs( data: Uint8Array ): GiftManager { return GiftManager.fromFields( GiftManager.bcs.parse(data) ) }

 toJSONField() { return {

 id: this.id,gifts: this.gifts.toJSONField(),

} }

 toJSON() { return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() } }

 static fromJSONField( field: any ): GiftManager { return GiftManager.reified( ).new( { id: decodeFromJSONField(UID.reified(), field.id), gifts: decodeFromJSONField(ObjectBag.reified(), field.gifts) } ) }

 static fromJSON( json: Record<string, any> ): GiftManager { if (json.$typeName !== GiftManager.$typeName) { throw new Error("not a WithTwoGenerics json object") };

 return GiftManager.fromJSONField( json, ) }

 static fromSuiParsedData( content: SuiParsedData ): GiftManager { if (content.dataType !== "moveObject") { throw new Error("not an object"); } if (!isGiftManager(content.type)) { throw new Error(`object at ${(content.fields as any).id} is not a GiftManager object`); } return GiftManager.fromFieldsWithTypes( content ); }

 static fromSuiObjectData( data: SuiObjectData ): GiftManager { if (data.bcs) { if (data.bcs.dataType !== "moveObject" || !isGiftManager(data.bcs.type)) { throw new Error(`object at is not a GiftManager object`); }

 return GiftManager.fromBcs( fromB64(data.bcs.bcsBytes) ); } if (data.content) { return GiftManager.fromSuiParsedData( data.content ) } throw new Error( "Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request." ); }

 static async fetch( client: SuiClient, id: string ): Promise<GiftManager> { const res = await client.getObject({ id, options: { showBcs: true, }, }); if (res.error) { throw new Error(`error fetching GiftManager object at id ${id}: ${res.error.code}`); } if (res.data?.bcs?.dataType !== "moveObject" || !isGiftManager(res.data.bcs.type)) { throw new Error(`object at id ${id} is not a GiftManager object`); }

 return GiftManager.fromSuiObjectData( res.data ); }

 }
