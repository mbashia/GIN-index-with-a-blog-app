defmodule BlogWeb.PostLive.Index do
  use BlogWeb, :live_view

  alias Blog.Posts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :all_tags, Posts.all_tags())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    search = params["search"] || ""
    tag = params["tag"] || ""
    sort_by = params["sort_by"] || "newest"
    page = params["page"] || "1"

    result = Posts.list_posts(Map.put(params, "page", page))

    {:noreply,
     socket
     |> assign(:search, search)
     |> assign(:tag, tag)
     |> assign(:sort_by, sort_by)
     |> assign(:posts, result.entries)
     |> assign(:page, result.page_number)
     |> assign(:total_pages, result.total_pages)
     |> assign(:total_entries, result.total_entries)
     |> assign(:page_title, "Posts")}
  end

  @impl true
  def handle_event("filter", %{"search" => search, "tag" => tag, "sort_by" => sort_by}, socket) do
    query_params = %{"search" => search, "tag" => tag, "sort_by" => sort_by, "page" => "1"}

    {:noreply, push_patch(socket, to: ~p"/posts?#{query_params}")}
  end

  @impl true
  def handle_event("paginate", %{"page" => page}, socket) do
    query_params = %{
      "search" => socket.assigns.search,
      "tag" => socket.assigns.tag,
      "sort_by" => socket.assigns.sort_by,
      "page" => page
    }

    {:noreply, push_patch(socket, to: ~p"/posts?#{query_params}")}
  end
end
