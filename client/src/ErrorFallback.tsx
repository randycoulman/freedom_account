import { useEffect, useRef } from "react";
import { FallbackProps } from "react-error-boundary";
import { Redirect, useLocation } from "react-router-dom";
import { CombinedError } from "urql";

const isUnauthorizedError = (error: Error) => {
  if (!(error instanceof CombinedError)) return false;

  const [gqlError] = error.graphQLErrors;

  return gqlError.message === "unauthorized";
};

export const ErrorFallback = ({ error, resetErrorBoundary }: FallbackProps) => {
  const { pathname } = useLocation();
  const originalPathname = useRef(pathname);

  useEffect(() => {
    if (pathname !== originalPathname.current) {
      resetErrorBoundary();
    }
  }, [pathname, resetErrorBoundary]);

  if (isUnauthorizedError(error)) {
    return (
      <Redirect
        to={{ pathname: "/login", state: { from: originalPathname.current } }}
      />
    );
  }
  return (
    <div role="alert">
      <p>Something went wrong:</p>
      <pre style={{ color: "red" }}>{error.message}</pre>
    </div>
  );
};
