type Props = {
  error: Error;
};

const ErrorFallback = ({ error }: Props) => (
  <div role="alert">
    <p>Something went wrong:</p>
    <pre style={{ color: "red" }}>{error.message}</pre>
  </div>
);

export default ErrorFallback;
