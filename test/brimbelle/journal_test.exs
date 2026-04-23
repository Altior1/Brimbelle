defmodule Brimbelle.JournalTest do
  use Brimbelle.DataCase

  alias Brimbelle.Journal

  describe "articles" do
    alias Brimbelle.Journal.Article

    import Brimbelle.JournalFixtures

    @invalid_attrs %{title: nil, article: nil}

    test "list_articles/0 returns all articles" do
      article = article_fixture()
      assert Journal.list_articles() == [article]
    end

    test "get_article!/1 returns the article with given id" do
      article = article_fixture()
      assert Journal.get_article!(article.id) == article
    end

    test "create_article/1 with valid data creates a article" do
      valid_attrs = %{title: "some title", article: "some article"}

      assert {:ok, %Article{} = article} = Journal.create_article(valid_attrs)
      assert article.title == "some title"
      assert article.article == "some article"
    end

    test "create_article/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Journal.create_article(@invalid_attrs)
    end

    test "update_article/2 with valid data updates the article" do
      article = article_fixture()
      update_attrs = %{title: "some updated title", article: "some updated article"}

      assert {:ok, %Article{} = article} = Journal.update_article(article, update_attrs)
      assert article.title == "some updated title"
      assert article.article == "some updated article"
    end

    test "update_article/2 with invalid data returns error changeset" do
      article = article_fixture()
      assert {:error, %Ecto.Changeset{}} = Journal.update_article(article, @invalid_attrs)
      assert article == Journal.get_article!(article.id)
    end

    test "delete_article/1 deletes the article" do
      article = article_fixture()
      assert {:ok, %Article{}} = Journal.delete_article(article)
      assert_raise Ecto.NoResultsError, fn -> Journal.get_article!(article.id) end
    end

    test "change_article/1 returns a article changeset" do
      article = article_fixture()
      assert %Ecto.Changeset{} = Journal.change_article(article)
    end
  end
end
