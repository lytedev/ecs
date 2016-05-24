defprotocol ECS.Component do
  @moduledoc """
  A protocol to allow specific component type checking.

  This protocol is intended to be used for a module with a struct representative
  of a component data structure, with the core `value` key as the "raw" data. A
  `type` key atom value is also expected for consistent component typing.

  ## Examples

      # Define a custom "name" component.
      defmodule Component.Name do
        defstruct type: :name, value: nil

        def new(name), do: %Component.Name{value: name}
      end
  """

  @fallback_to_any true

  @doc "Returns the type of component as an atom."
  def type_of(component)

  @doc "Updates `component`'s `value` with `update_fun`."
  def update(component, update_fun)

  @doc "Returns the raw `value` of the component."
  def value_of(component)
end

defimpl ECS.Component, for: Any do
  def type_of(%{type: type}), do: type

  def update(%{value: value} = cmp, update_fun) do
    %{cmp | value: update_fun.(value)}
  end

  def value_of(%{value: value}), do: value
end
