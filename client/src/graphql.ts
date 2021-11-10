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

/** A Freedom Account */
export type Account = {
  __typename?: "Account";
  /** The individual funds in the account */
  funds: Array<Fund>;
  /** The account's unique ID */
  id: Scalars["ID"];
  /** The name of the account */
  name: Scalars["String"];
};

/** Account settings input */
export type AccountInput = {
  /** The account's unique ID */
  id: Scalars["ID"];
  /** The name of the account */
  name: Scalars["String"];
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

export type RootMutationType = {
  __typename?: "RootMutationType";
  /** Update account settings */
  updateAccount: Account;
};

export type RootMutationTypeUpdateAccountArgs = {
  input: AccountInput;
};

export type RootQueryType = {
  __typename?: "RootQueryType";
  /** My freedom account */
  myAccount: Account;
};

export type MyAccountQueryVariables = Exact<{ [key: string]: never }>;

export type MyAccountQuery = {
  __typename?: "RootQueryType";
  myAccount: {
    __typename?: "Account";
    name: string;
    id: string;
    funds: Array<{
      __typename?: "Fund";
      icon: string;
      id: string;
      name: string;
    }>;
  };
};

export type FundPartsFragment = {
  __typename?: "Fund";
  icon: string;
  id: string;
  name: string;
};

export type AccountFundsFragment = {
  __typename?: "Account";
  id: string;
  name: string;
  funds: Array<{ __typename?: "Fund"; icon: string; id: string; name: string }>;
};

export const FundPartsFragmentDoc = gql`
  fragment FundParts on Fund {
    icon
    id
    name
  }
`;
export const AccountFundsFragmentDoc = gql`
  fragment AccountFunds on Account {
    funds {
      ...FundParts
    }
    id
    name
  }
  ${FundPartsFragmentDoc}
`;
export const MyAccountDocument = gql`
  query MyAccount {
    myAccount {
      ...AccountFunds
      name
    }
  }
  ${AccountFundsFragmentDoc}
`;

export function useMyAccountQuery(
  options: Omit<Urql.UseQueryArgs<MyAccountQueryVariables>, "query"> = {}
) {
  return Urql.useQuery<MyAccountQuery>({
    query: MyAccountDocument,
    ...options,
  });
}
