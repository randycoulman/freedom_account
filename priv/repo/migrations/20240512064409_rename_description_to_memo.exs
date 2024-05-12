defmodule FreedomAccount.Repo.Migrations.RenameDescriptionToMemo do
  use Ecto.Migration

  @spec change :: any()
  def change do
    rename table(:transactions), :description, to: :memo
  end
end
