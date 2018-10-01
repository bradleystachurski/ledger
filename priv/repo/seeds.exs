# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Ledger.Repo.insert!(%Ledger.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Ledger.Repo
alias Ledger.PaymentGroup
alias Ledger.PaymentGroup.{Group, Participant}

{:ok, %Group{id: ef_group_id}} =
  %{name: "Ethereum Foundation"}
  |> PaymentGroup.create_group()

{:ok, %Group{id: csys_group_id}} =
  %{name: "ConsenSys"}
  |> PaymentGroup.create_group()

Repo.insert! %Participant{
  username: "Vitalik",
  group_id: ef_group_id,
  amount: 100
}

Repo.insert! %Participant{
  username: "Vlad",
  group_id: ef_group_id,
  amount: 100
}

Repo.insert! %Participant{
  username: "Gavin",
  group_id: ef_group_id,
  amount: 100
}

Repo.insert! %Participant{
  username: "Danny",
  group_id: ef_group_id,
  amount: 100
}

Repo.insert! %Participant{
  username: "Joe",
  group_id: csys_group_id,
  amount: 100
}

Repo.insert! %Participant{
  username: "Dudley",
  group_id: csys_group_id,
  amount: 100
}

Repo.insert! %Participant{
  username: "Kevin",
  group_id: csys_group_id,
  amount: 100
}
