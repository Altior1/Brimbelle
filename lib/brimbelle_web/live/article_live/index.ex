defmodule BrimbelleWeb.ArticleLive.Index do
  use BrimbelleWeb, :live_view

  alias Brimbelle.Journal

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Articles
        <:actions>
          <.button variant="primary" navigate={~p"/articles/new"}>
            <.icon name="hero-plus" /> New Article
          </.button>
        </:actions>
      </.header>

      <.table
        id="articles"
        rows={@streams.articles}
        row_click={fn {_id, article} -> JS.navigate(~p"/articles/#{article}") end}
      >
        <:col :let={{_id, article}} label="Title">{article.title}</:col>
        <:col :let={{_id, article}} label="Article">{article.article}</:col>
        <:action :let={{_id, article}}>
          <div class="sr-only">
            <.link navigate={~p"/articles/#{article}"}>Show</.link>
          </div>
          <.link navigate={~p"/articles/#{article}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, article}}>
          <.link
            phx-click={JS.push("delete", value: %{id: article.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Articles")
     |> stream(:articles, list_articles())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    article = Journal.get_article!(id)
    {:ok, _} = Journal.delete_article(article)

    {:noreply, stream_delete(socket, :articles, article)}
  end

  defp list_articles() do
    Journal.list_articles()
  end
end
