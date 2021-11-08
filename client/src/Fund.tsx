import { gql } from "urql";

import { Fund as FundType } from "./graphql";

type Props = {
  fund: FundType;
};

export const Fund = ({ fund }: Props) => (
  <li>
    {fund.icon} {fund.name}
  </li>
);

Fund.fragments = {
  fund: gql`
    fragment FundParts on Fund {
      icon
      id
      name
    }
  `,
};
