defmodule ECS.Entity do
  @moduledoc """
  Functions to work with entities.

  An entity is an agent-based container for a map of components.

  ## Examples

      # Create a monster entity.
      monster = ECS.Entity.new([
        Component.Health.new(100),
        Component.Name.new("monster")
      ])

      # Output its name.
      IO.puts ECS.Entity.get(monster, :name) # "monster"

      # Attach an attack component to the monster.
      ECS.Entity.attach(monster, Component.Attack.new(:melee, 24))
  """

  @doc "Attaches a `component` to an `entity`."
  def attach(entity, component) do
    cmp_type = ECS.Component.type_of(component)
    :ok = Agent.update(entity, &Map.put_new(&1, cmp_type, component))
    entity
  end

  @doc "Detaches a component of type `cmp_type` from an `entity`."
  def detach(entity, cmp_type) do
    :ok = Agent.update(entity, &Map.delete(&1, cmp_type))
    entity
  end

  @doc "Retrieves a component's value of type `cmp_type` from an `entity`."
  def get(entity, cmp_type) do
    Agent.get(entity, &Map.get(&1, cmp_type))
    |> ECS.Component.value_of
  end

  @doc "Checks whether an `entity` has a component of `cmp_type`."
  def has?(entity, cmp_type) do
    Agent.get(entity, &(&1))
    |> Map.has_key?(cmp_type)
  end

  @doc "Checks whether `entity` has component types `cmp_types`."
  def has_all?(entity, cmp_types) do
    List.foldl(cmp_types, true, &(&2 && has?(entity, &1)))
  end

  @doc "Returns a new agent pid wrapping `components` as a map."
  def new(components) do
    {:ok, entity} = Agent.start(fn ->
      components
      |> Enum.map(&({ECS.Component.type_of(&1), &1}))
      |> Enum.into(%{})
    end)
    entity
  end

  @doc "Sets `entity` component of `cmp_type` to `value`."
  def set(entity, cmp_type, value) do
    update(entity, cmp_type, fn(_) -> value end)
  end

  @doc "Updates `entity` using `update_fun`."
  def update(entity, cmp_type, update_fun) do
    :ok = Agent.update(entity, fn(cmps) ->
      Map.update!(cmps, cmp_type, fn(cmp) ->
        ECS.Component.update(cmp, update_fun)
      end)
    end)
  end
end
