defmodule FreedomAccount.Paging do
  @moduledoc false
  use Boundary
  use TypedStruct

  @opaque cursor :: Paginator.Page.Metadata.opaque_cursor()

  typedstruct do
    field :next_cursor, cursor()
    field :prev_cursor, cursor()
  end
end
