defmodule FreedomAccountWeb.Card do
  @moduledoc false
  use Phoenix.Component

  # credo:disable-for-this-file Credo.Check.Readability.Specs
  # Reason: All component functions take a map of assigns that is fully
  # specified and checked at compile time by `attr` and `slot`, and they all
  # return a HEEx template, so no spec is necessary here.

  attr :balance, Money, required: true
  attr :class, :string
  attr :icon, :string, required: true
  attr :name, :string, required: true
  attr :rest, :global

  slot :action
  slot :details

  def card(assigns) do
    ~H"""
    <div
      class={[
        " bg-white flex group items-center justify-between max-w-screen-md mx-auto p-4 rounded-xl shadow-sm w-full",
        @class
      ]}
      {@rest}
    >
      <div>
        <div class="flex items-center">
          <div class="w-10 flex justify-center text-2xl" data-testid="icon">
            {@icon}
          </div>
          <div class="flex items-center ml-2 gap-2">
            <div class="text-lg font-semibold text-gray-900" data-testid="name">
              {@name}
            </div>
            <div class="hidden group-hover:flex gap-1 text-md">
              <span :for={action <- @action} class="text-gray-400 hover:text-gray-600">
                {render_slot(action)}
              </span>
            </div>
          </div>
        </div>
        {render_slot(@details)}
      </div>
      <div class="flex flex-col items-end">
        <div class="text-xl font-semibold text-gray-900 tabular-nums" data-testid="balance">
          {@balance}
        </div>
      </div>
    </div>
    """
  end
end
