import { prop, sortBy } from "ramda";

const fakeFunds = [
  {
    icon: "🏚️",
    id: 1,
    name: "Home Repairs",
  },
  {
    icon: "🚘",
    id: 2,
    name: "Car Repairs",
  },
  {
    icon: "💸",
    id: 3,
    name: "Property Taxes",
  },
];

const FundList = () => {
  const funds = sortBy(prop("name"), fakeFunds);

  return (
    <article>
      <h2>Funds</h2>
      <ul>
        {funds.map((fund) => (
          <li key={fund.id}>
            {fund.icon} {fund.name}
          </li>
        ))}
      </ul>
    </article>
  );
};

export default FundList;
