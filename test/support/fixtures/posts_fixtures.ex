defmodule Blog.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Blog.Posts` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        body: "some body",
        metadata: %{},
        tags: ["option1", "option2"],
        title: "some title"
      })
      |> Blog.Posts.create_post()

    post
  end
end
