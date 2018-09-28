defmodule Ledger.PaymentGroup.Participant do
  use Ecto.Schema
  import Ecto.Changeset


  schema "participants" do
    field :amount, :integer
    field :name, :string
    field :group_id, :id

    timestamps()
  end

  @doc false
  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:name, :amount, :group_id])
    |> validate_required([:name, :amount, :group_id])
  end
end
