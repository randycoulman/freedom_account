import { useErrorHandler } from "react-error-boundary";
import { gql } from "urql";

import FundList from "./FundList";
import { useFundsQuery } from "./graphql";

const Home = () => {
  const [{ data, error }] = useFundsQuery();

  useErrorHandler(error);

  return (
    <article>
      <h2>Funds</h2>
      <FundList funds={data!.funds} />
    </article>
  );
};

Home.query = gql`
  query Funds {
    funds {
      icon
      id
      name
    }
  }
`;

export default Home;
