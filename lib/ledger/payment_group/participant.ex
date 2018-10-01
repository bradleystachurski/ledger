defmodule Ledger.PaymentGroup.Participant do
  use Ecto.Schema
  import Ecto.Changeset


  schema "participants" do
    field :amount, :integer
    field :username, :string
    field :group_id, :id

    timestamps()
  end

  @doc false
  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:username, :amount, :group_id])
    |> validate_required([:username, :amount, :group_id])
  end
end
