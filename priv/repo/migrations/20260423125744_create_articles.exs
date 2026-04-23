defmodule Brimbelle.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :title, :string
      add :article, :text

      timestamps(type: :utc_datetime)
    end
  end
end
