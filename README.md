# Blog — GIN vs B-tree Index Demo

A small Phoenix LiveView blog built to answer one question: **why does a B-tree index do nothing for tag/JSON filtering in Postgres, and what does GIN actually fix?**

This repo is the companion code for [the article](https://medium.com/@mbashiavictor/why-my-postgres-queries-were-slow-a-b-tree-vs-gin-index-6305a7f54ed0) walking through that problem — seeded with 500,000 posts, each with an array of tags and a JSONB metadata field, so you can reproduce the `EXPLAIN ANALYZE` results yourself.

## Stack

- Phoenix LiveView
- Ecto + Postgres
- Scrivener for pagination

## Setup

```bash
mix deps.get
mix ecto.create
mix ecto.migrate
mix run priv/repo/seeds.exs
mix phx.server
```

Visit `localhost:4000/posts`. Search, tag filtering, sorting, and pagination all work against the seeded data.

## Reproducing the B-tree vs GIN comparison

The `tags` and `metadata` columns are indexed with GIN by default (see the migration in `priv/repo/migrations/`). To see the *before* state for yourself:

```sql
-- swap to B-tree and see the seq scan
DROP INDEX posts_tags_idx;
CREATE INDEX posts_tags_idx ON posts USING btree (tags);

EXPLAIN ANALYZE SELECT * FROM posts WHERE tags @> ARRAY['elixir'];
```

```sql
-- swap back to GIN and see the bitmap index scan
DROP INDEX posts_tags_idx;
CREATE INDEX posts_tags_idx ON posts USING gin (tags);

EXPLAIN ANALYZE SELECT * FROM posts WHERE tags @> ARRAY['elixir'];
```

Same query, same data — the plan is what changes.

## Notes

- Seeding uses `Task.async_stream/3` for concurrent batch inserts. If you're re-seeding, drop the GIN indexes first and rebuild them after — it's dramatically faster than maintaining them row-by-row during a bulk load.
- `Repo.paginate/2` (Scrivener) runs a `COUNT(*)` alongside the main query — worth its own `EXPLAIN ANALYZE` if you're benchmarking further.

## License

MIT