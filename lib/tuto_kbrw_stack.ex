defmodule TutoKbrwStack do
  @moduledoc """
  Documentation for `TutoKbrwStack`.
  """
  require Server.Supervisor
  require Server.Database
  require JsonLoader

  orders = [
    %{"id" => "toto", "key" => 42},
    %{"id" => "test", "key" => "42"},
    %{"id" => "tata", "key" => "Apero?"},
    %{"id" => "kbrw", "key" => "Oh yeah"}
  ]

  {:ok, my_supervisor} = Server.Supervisor.start_link([])
  # Server.Database.create(Server.Database, "ali")
  JsonLoader.load_to_database(
    Server.Database,
    "/home/mohsen/tuto_kbrw_stack/orders_dump/orders_chunk0.json"
  )

  orders_filter = Server.Database.search(orders, [{"key", 42}, {"key", "42"}, {"key", "Oh yeah"}])
  IO.inspect(orders_filter)
end
