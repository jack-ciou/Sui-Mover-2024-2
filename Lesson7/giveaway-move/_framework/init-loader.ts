import * as package_onchain_1 from "../_dependencies/onchain/0x1/init";
import * as package_onchain_2 from "../_dependencies/onchain/0x2/init";
import * as package_onchain_f55c5d376d418f6f2f254f934b5c8056187458e7c1884e9830307fce08ee2fdf from "../giveaway/init";
import {StructClassLoader} from "./loader";

function registerClassesOnchain(loader: StructClassLoader) { package_onchain_1.registerClasses(loader);
package_onchain_2.registerClasses(loader);
package_onchain_f55c5d376d418f6f2f254f934b5c8056187458e7c1884e9830307fce08ee2fdf.registerClasses(loader);
 }

export function registerClasses(loader: StructClassLoader) { registerClassesOnchain(loader); }
