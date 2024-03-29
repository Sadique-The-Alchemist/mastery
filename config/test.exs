import Config

config :mastery_persistence, MasteryPersistence.Repo,
        database: "mastery_test",
        hostname: "localhost",
        pool: Ecto.Adapters.SQL.Sandbox

config :mastery, :persistence_fn, &MasteryPersistence.record_response/2
