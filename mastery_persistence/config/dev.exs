import Config

config :mastery_persistence, MasteryPersistence.Repo,
  database: "mastery_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432"
