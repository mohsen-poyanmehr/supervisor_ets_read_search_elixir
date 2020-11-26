defmodule JsonLoader do
  def load_to_database(database, filename) do
    with {:ok, file_content} <- File.read(filename) do
      mapJson = Poison.decode!(file_content)

      Enum.each(mapJson, fn element ->
        :ets.insert(
          database,
          {element["id"], element}
        )
      end)
    end
  end
end
