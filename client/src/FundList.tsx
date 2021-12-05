import { prop, sortBy } from "ramda";
import { useState } from "react";
import { gql } from "urql";

import { Fund } from "./Fund";
import { FundEditForm } from "./FundEditForm";
import { Fund as FundType, FundInput } from "./graphql";

export type Props = {
  funds: FundType[];
  onAddFund?: (_values: FundInput) => void;
};

const defaultOnAddFund = (_values: FundInput) => {};

export const FundList = ({ funds, onAddFund = defaultOnAddFund }: Props) => {
  const [isAdding, beAdding] = useState(false);
  const sortedFunds = sortBy(prop("name"), funds);

  const handleAddFund = () => {
    beAdding(true);
  };
  const handleSave = (values: FundInput) => {
    onAddFund(values);
    beAdding(false);
  };
  const handleCancel = () => {
    beAdding(false);
  };

  return (
    <>
      <button disabled={isAdding} onClick={handleAddFund} type="button">
        Add Fund
      </button>
      {funds.length === 0 && !isAdding ? (
        <div>
          This account has no funds yet. Use the Add Fund button to add one.
        </div>
      ) : (
        <ul>
          {isAdding && (
            <FundEditForm onCancel={handleCancel} onSave={handleSave} />
          )}
          {sortedFunds.map((fund) => (
            <Fund fund={fund} key={fund.id} />
          ))}
        </ul>
      )}
    </>
  );
};

FundList.fragments = {
  fund: Fund.fragments.fund,
  funds: gql`
    fragment AccountFunds on Account {
      funds {
        ...FundFields
      }
      id
      name
    }

    ${Fund.fragments.fund}
  `,
};
