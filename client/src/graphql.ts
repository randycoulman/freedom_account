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
  /** How many regular deposits will be made per year? */
  depositsPerYear: Scalars["Int"];
  /** The individual funds in the account */
  funds: Array<Fund>;
  /** The account's unique ID */
  id: Scalars["ID"];
  /** The name of the account */
  name: Scalars["String"];
};

/** Account settings input */
export type AccountInput = {
  /** How many regular deposits will be made per year? */
  depositsPerYear: Scalars["Int"];
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
  /** Log into the application */
  login: User;
  /** Log out of the application */
  logout: Scalars["Boolean"];
  /** Update account settings */
  updateAccount: Account;
};

export type RootMutationTypeLoginArgs = {
  username: Scalars["String"];
};

export type RootMutationTypeUpdateAccountArgs = {
  input: AccountInput;
};

export type RootQueryType = {
  __typename?: "RootQueryType";
  /** My freedom account */
  myAccount: Account;
};

/** A user */
export type User = {
  __typename?: "User";
  /** The user's unique ID */
  id: Scalars["ID"];
  /** The name of the user */
  name: Scalars["String"];
};

export type MyAccountQueryVariables = Exact<{ [key: string]: never }>;

export type MyAccountQuery = {
  __typename?: "RootQueryType";
  myAccount: {
    __typename?: "Account";
    depositsPerYear: number;
    id: string;
    name: string;
    funds: Array<{
      __typename?: "Fund";
      icon: string;
      id: string;
      name: string;
    }>;
  };
};

export type UpdateAccountMutationVariables = Exact<{
  input: AccountInput;
}>;

export type UpdateAccountMutation = {
  __typename?: "RootMutationType";
  updateAccount: {
    __typename?: "Account";
    depositsPerYear: number;
    id: string;
    name: string;
  };
};

export type AccountFieldsFragment = {
  __typename?: "Account";
  depositsPerYear: number;
  id: string;
  name: string;
};

export type FundFieldsFragment = {
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

export type LoginMutationVariables = Exact<{
  username: Scalars["String"];
}>;

export type LoginMutation = {
  __typename?: "RootMutationType";
  login: { __typename?: "User"; id: string };
};

export const AccountFieldsFragmentDoc = gql`
  fragment AccountFields on Account {
    depositsPerYear
    id
    name
  }
`;
export const FundFieldsFragmentDoc = gql`
  fragment FundFields on Fund {
    icon
    id
    name
  }
`;
export const AccountFundsFragmentDoc = gql`
  fragment AccountFunds on Account {
    funds {
      ...FundFields
    }
    id
    name
  }
  ${FundFieldsFragmentDoc}
`;
export const MyAccountDocument = gql`
  query MyAccount {
    myAccount {
      ...AccountFields
      ...AccountFunds
    }
  }
  ${AccountFieldsFragmentDoc}
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
export const UpdateAccountDocument = gql`
  mutation UpdateAccount($input: AccountInput!) {
    updateAccount(input: $input) {
      ...AccountFields
    }
  }
  ${AccountFieldsFragmentDoc}
`;

export function useUpdateAccountMutation() {
  return Urql.useMutation<
    UpdateAccountMutation,
    UpdateAccountMutationVariables
  >(UpdateAccountDocument);
}
export const LoginDocument = gql`
  mutation Login($username: String!) {
    login(username: $username) {
      id
    }
  }
`;

export function useLoginMutation() {
  return Urql.useMutation<LoginMutation, LoginMutationVariables>(LoginDocument);
}
