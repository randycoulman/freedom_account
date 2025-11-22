defmodule FreedomAccount.LocalTime do
  @moduledoc false
  use Boundary

  @spec today :: Date.t()
  def today do
    NaiveDateTime.to_date(NaiveDateTime.local_now())
  end
end
