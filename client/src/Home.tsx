import { useErrorHandler } from "react-error-boundary";
import { gql, useQuery } from "urql";

import FundList, { Fund } from "./FundList";

type FundsResponse = {
  funds: Fund[];
};

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
  const [{ data, error }] = useQuery<FundsResponse>({
    query: fundsQuery,
  });

  useErrorHandler(error);

  return (
    <article>
      <h2>Funds</h2>
      <FundList funds={data!.funds} />
    </article>
  );
};

export default Home;
