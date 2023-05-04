defmodule UpLearn.Website do
  @moduledoc """
  Website data structure that is populated by crawler.
  """

  @type t :: %__MODULE__{
          assets: [String.t()],
          links: [String.t()],
          url: String.t()
        }

  defstruct assets: [], links: [], url: ""
end
