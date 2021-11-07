// import { useErrorHandler } from "react-error-boundary";
import { gql, useQuery } from "urql";

import FundList, { Fund } from "./FundList";

type FundsResponse = {
  funds: Fund[];
};

const fakeFunds: Fund[] = [
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

const fundsQuery = gql`
  query Funds {
    funds {
      icon
      id
      name
    }
  }
`;

const Home = () => {
  const [{ data }] = useQuery<FundsResponse>({
    query: fundsQuery,
  });
  // const [{ data, error }] = useQuery<FundsResponse>({
  //   query: fundsQuery,
  // });

  // Deal with GraphQL errors too
  // useErrorHandler(error?.networkError);

  const funds = data?.funds || fakeFunds;

  return (
    <article>
      <h2>Funds</h2>
      <FundList funds={funds} />
    </article>
  );
};

export default Home;
