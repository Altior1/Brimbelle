defmodule Brimbelle.JournalFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Brimbelle.Journal` context.
  """

  @doc """
  Generate a article.
  """
  def article_fixture(attrs \\ %{}) do
    {:ok, article} =
      attrs
      |> Enum.into(%{
        article: "some article",
        title: "some title"
      })
      |> Brimbelle.Journal.create_article()

    article
  end
end
