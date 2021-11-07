import { prop, sortBy } from "ramda";
import { gql } from "urql";

import { Fund } from "./Fund";
import { Fund as FundType } from "./graphql";

type Props = {
  funds: FundType[];
};

export const FundList = ({ funds }: Props) => {
  const sortedFunds = sortBy(prop("name"), funds);

  return (
    <ul>
      {sortedFunds.map((fund) => (
        <Fund fund={fund} key={fund.id} />
      ))}
    </ul>
  );
};

export const FundListQuery = gql`
  query Funds {
    funds {
      ...FundParts
    }
  }

  ${Fund.fragments.fund}
`;
