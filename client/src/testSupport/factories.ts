import Faker from "faker";
import { Factory } from "fishery";

import { Account } from "../graphql";

export const accountFactory = Factory.define<Account>(() => ({
  depositsPerYear: Faker.datatype.number(26),
  funds: [],
  id: Faker.datatype.uuid(),
  name: Faker.commerce.productName(),
}));
