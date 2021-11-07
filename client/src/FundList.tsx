import { prop, sortBy } from "ramda";

export type Fund = {
  icon: string;
  id: string;
  name: string;
};

type Props = {
  funds: Fund[];
};

const FundList = ({ funds }: Props) => {
  const sortedFunds = sortBy(prop("name"), funds);

  return (
    <ul>
      {sortedFunds.map((fund) => (
        <li key={fund.id}>
          {fund.icon} {fund.name}
        </li>
      ))}
    </ul>
  );
};

export default FundList;
