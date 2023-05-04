defmodule UpLearn.Crawler do
  @moduledoc """
  This module is responsible for crawling the websites and extracting the data.
  """

  alias UpLearn.{Parsers.HTML, Website}
  alias UpLearn.Finch, as: UpLearnFinch

  @supported_content_types ["text/html; charset=utf-8", "text/html"]

  @spec fetch(String.t()) :: {:ok, Website.t()} | {:error, term()}
  def fetch(url) do
    with {:ok, response} <- do_request(url),
         :ok <- validate_status_code(response.status),
         {:ok, response} <- validate_content_type(response),
         {:ok, website} <- HTML.parse(response.body, url) do
      {:ok, website}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp do_request(url) do
    :get
    |> Finch.build(url)
    |> Finch.request(UpLearnFinch)
  end

  defp validate_status_code(200), do: :ok
  defp validate_status_code(_), do: {:error, :invalid_status_code}

  defp validate_content_type(response) do
    case Enum.find(response.headers, fn {k, _v} -> k == "content-type" end) do
      {_, content_type} when content_type in @supported_content_types ->
        {:ok, response}

      _ ->
        {:error, :unsupported_content_type}
    end
  end
end
