import { gql } from "urql";
import * as Urql from "urql";

export type Maybe<T> = T | null;
export type Exact<T extends { [key: string]: unknown }> = {
  [K in keyof T]: T[K];
};
export type MakeOptional<T, K extends keyof T> = Omit<T, K> & {
  [SubKey in K]?: Maybe<T[SubKey]>;
};
export type MakeMaybe<T, K extends keyof T> = Omit<T, K> & {
  [SubKey in K]: Maybe<T[SubKey]>;
};
export type Omit<T, K extends keyof T> = Pick<T, Exclude<keyof T, K>>;
/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: string;
  String: string;
  Boolean: boolean;
  Int: number;
  Float: number;
};

/** A savings fund */
export type Fund = {
  __typename?: "Fund";
  /** An icon for the fund (in the form of an emoji) */
  icon: Scalars["String"];
  /** The fund's unique identifier */
  id: Scalars["ID"];
  /** The name of the fund */
  name: Scalars["String"];
};

export type RootQueryType = {
  __typename?: "RootQueryType";
  /** List all funds */
  funds: Array<Fund>;
};

export type FundPartsFragment = {
  __typename?: "Fund";
  icon: string;
  id: string;
  name: string;
};

export type FundsQueryVariables = Exact<{ [key: string]: never }>;

export type FundsQuery = {
  __typename?: "RootQueryType";
  funds: Array<{ __typename?: "Fund"; icon: string; id: string; name: string }>;
};

export const FundPartsFragmentDoc = gql`
  fragment FundParts on Fund {
    icon
    id
    name
  }
`;
export const FundsDocument = gql`
  query Funds {
    funds {
      ...FundParts
    }
  }
  ${FundPartsFragmentDoc}
`;

export function useFundsQuery(
  options: Omit<Urql.UseQueryArgs<FundsQueryVariables>, "query"> = {}
) {
  return Urql.useQuery<FundsQuery>({ query: FundsDocument, ...options });
}
