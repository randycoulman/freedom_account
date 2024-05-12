defmodule FreedomAccount.Repo.Migrations.ModifyLineItemsOnDeleteForFund do
  use Ecto.Migration

  @spec change :: any()
  def change do
    alter table(:line_items) do
      modify :fund_id, references(:funds, on_delete: :restrict),
        from: references(:funds, on_delete: :delete_all)
    end
  end
end
