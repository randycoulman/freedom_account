import { useErrorHandler } from "react-error-boundary";

import { FundList } from "./FundList";
import { useFundsQuery } from "./graphql";

export const Account = () => {
  const [{ data, error }] = useFundsQuery();

  useErrorHandler(error);

  return (
    <>
      <section>
        <h2>My Freedom Account</h2>
      </section>
      <article>
        <h3>Funds</h3>
        <FundList funds={data!.funds} />
      </article>
    </>
  );
};
