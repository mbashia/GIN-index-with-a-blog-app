defmodule Blog.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :body, :text
      add :tags, {:array, :string}
      add :metadata, :map

      timestamps()
    end

    create index(:posts, [:inserted_at])
    create index(:posts, [:tags], using: :gin)
    create index(:posts, [:metadata], using: :gin)
  end
end
