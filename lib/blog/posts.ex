defmodule Blog.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Blog.Repo

  alias Blog.Posts.Post

  def list_posts(params \\ %{}) do
    Post
    |> filter_by_search(params["search"])
    |> filter_by_tag(params["tag"])
    |> sort_posts(params["sort_by"])
    |> Repo.paginate(page: params["page"] || 1, page_size: 20)
  end

  defp filter_by_search(query, nil), do: query
  defp filter_by_search(query, ""), do: query

  defp filter_by_search(query, search) do
    term = "%#{search}%"
    from p in query, where: ilike(p.title, ^term) or ilike(p.body, ^term)
  end

  defp filter_by_tag(query, nil), do: query
  defp filter_by_tag(query, ""), do: query

  defp filter_by_tag(query, tag) do
    from p in query, where: fragment("? @> ?", p.tags, ^[tag])
  end

  defp sort_posts(query, "oldest"), do: from(p in query, order_by: [asc: p.inserted_at])
  defp sort_posts(query, "title"), do: from(p in query, order_by: [asc: p.title])
  defp sort_posts(query, _newest), do: from(p in query, order_by: [desc: p.inserted_at])

  def all_tags do
    Post
    |> select([p], fragment("DISTINCT unnest(?)", p.tags))
    |> Repo.all()
    |> Enum.sort()
  end
end
