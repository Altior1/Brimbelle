defmodule BrimbelleWeb.ArticleLive.Show do
  use BrimbelleWeb, :live_view

  alias Brimbelle.Journal

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Article {@article.id}
        <:subtitle>This is a article record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/articles"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/articles/#{@article}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit article
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@article.title}</:item>
        <:item title="Article">{@article.article}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Article")
     |> assign(:article, Journal.get_article!(id))}
  end
end
