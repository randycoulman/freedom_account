type Props = {
  error: Error;
};

export const ErrorFallback = ({ error }: Props) => (
  <div role="alert">
    <p>Something went wrong:</p>
    <pre style={{ color: "red" }}>{error.message}</pre>
  </div>
);
