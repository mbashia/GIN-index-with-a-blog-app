alias Blog.Repo
alias Blog.Posts.Post

tag_pool = ~w(elixir postgres phoenix liveview backend career testing otp ecto deployment)
categories = ~w(tech career tutorial opinion)
authors = for _ <- 1..200, do: Faker.Person.name()

now = DateTime.utc_now() |> DateTime.truncate(:second)
total = 500_000
batch_size = 5_000

1..total
|> Stream.chunk_every(batch_size)
|> Task.async_stream(
  fn chunk ->
    entries =
      Enum.map(chunk, fn _ ->
        %{
          title: Faker.Lorem.sentence(4),
          body: Faker.Lorem.paragraph(5),
          tags: Enum.take_random(tag_pool, Enum.random(1..3)),
          metadata: %{
            "author" => Enum.random(authors),
            "category" => Enum.random(categories),
            "featured" => Enum.random([true, false])
          },
          inserted_at: now,
          updated_at: now
        }
      end)

    Repo.insert_all(Post, entries, log: false)
  end,
  max_concurrency: System.schedulers_online(),
  timeout: :infinity
)
|> Stream.run()

IO.puts("Seeded #{Repo.aggregate(Post, :count)} posts")
