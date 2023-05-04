defmodule UpLearn.Parsers.HTML do
  @moduledoc """
  This module is responsible for parsing the HTML and extracting the data to the website structure.
  """
  alias UpLearn.Website

  @spec parse(String.t(), String.t()) :: {:ok, Website.t()} | {:error, term()}
  def parse(body, url) do
    with {:ok, document} <- Floki.parse_document(body),
         %Website{} = website <-
           %Website{url: url} |> extract("img", document) |> extract("a", document) do
      {:ok, website}
    end
  end

  defp extract(website, "img", document) do
    assets =
      document
      |> Floki.find("img")
      |> Enum.map(&Floki.attribute(&1, "src"))
      |> List.flatten()

    %{website | assets: assets}
  end

  defp extract(website, "a", document) do
    links =
      document
      |> Floki.find("a")
      |> Enum.map(&Floki.attribute(&1, "href"))
      |> List.flatten()

    %{website | links: links}
  end
end
