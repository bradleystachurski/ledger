defmodule LedgerWeb.ParticipantView do
  use LedgerWeb, :view
  alias LedgerWeb.ParticipantView

  def render("index.json", %{participants: participants}) do
    %{data: render_many(participants, ParticipantView, "participant.json")}
  end

  def render("show.json", %{participant: participant}) do
    %{data: render_one(participant, ParticipantView, "participant.json")}
  end

  def render("show_transfer.json", %{from_participant: from_participant, to_participant: to_participant}) do
    %{data: %{
        from_participant: render_one(from_participant, ParticipantView, "participant.json"),
        to_participant: render_one(to_participant, ParticipantView, "participant.json")
    }}
  end

  def render("participant.json", %{participant: participant}) do
    %{id: participant.id,
      name: participant.name,
      amount: participant.amount,
      group_id: participant.group_id}
  end

  def render("non_neg.json", %{params: params}) do
    %{message: "Cannot add a user with a negative amount", params: params}
  end

  def render("invalid_transfer_amount.json", %{params: params}) do
    %{message: "Cannot transfer an amount greater than current balance", params: params}
  end

  def render("invalid_transfer_group.json", %{params: params}) do
    %{message: "Must transfer within the same payment group", params: params}
  end
end
