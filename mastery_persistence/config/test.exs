import Config

config :mastery_persistence, MasteryPersistence.Repo,
  database: "mastery_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432",
  pool: Ecto.Adapters.SQL.Sandbox
