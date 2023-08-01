import Config

config :mastery_persistence, MasteryPersistense.Repo,
  database: "mastery_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432"
