defmodule Server.Database do
  use GenServer

  ## Client API

  def start_link(opts) do
    server = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, server, opts)
  end

  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  def delete(server, name) do
    GenServer.cast(server, {:delete, name})
  end

  def lookup(server, name) do
    case :ets.lookup(server, name) do
      [{^name, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  ## Defining GenServer Callbacks

  @impl true
  def init(table) do
    IO.puts("coucouc #{table}")
    names = :ets.new(table, [:named_table, :public])
    refs = %{}
    {:ok, {names, refs}}
  end

  @impl true
  def handle_cast({:create, name}, {names, refs}) do
    # Read and write to the ETS table
    case lookup(names, name) do
      {:ok, _pid} ->
        {:noreply, {names, refs}}

      :error ->
        {_, {_, pid}} = Server.Database.start_link(name: Server.Database)
        ref = pid
        refs = Map.put(refs, ref, name)
        :ets.insert(names, {name, ref})
        {:noreply, {names, refs}}
    end
  end

  @impl true
  def handle_cast({:delete, name}, {names, refs}) do
    # delete from ETS table
    case lookup(names, name) do
      {:ok, _pid} ->
        {_, {_, pid}} = Server.Database.start_link(name: Server.Database)
        ref = pid
        {name, refs} = Map.pop(refs, ref)
        :ets.delete(names, name)
        {:noreply, {names, refs}}

      :error ->
        {:noreply, {names, refs}}
    end
  end

  def search(database, criteria) do
    Enum.flat_map(criteria, fn x ->
      Enum.filter(database, fn data ->
        data["key"] === elem(x, 1)
      end)
    end)
  end
end
