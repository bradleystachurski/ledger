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
      username: participant.username,
      amount: participant.amount,
      group_id: participant.group_id}
  end

  def render("delete.json", %{participant: participant}) do
    %{data: render_one(participant, ParticipantView, "removed_participant.json")}
  end

  def render("removed_participant.json", %{participant: particpant}) do
    %{final_amount: particpant.amount}
  end

  def render("non_neg.json", %{params: params}) do
    %{error: "Cannot add a user with a negative amount", params: params}
  end

  def render("insufficient_funds.json", %{params: params}) do
    %{error: "The sender doesn't have enough funds to complete the requested transfer", params: params}
  end

  def render("invalid_transfer_group.json", %{params: params}) do
    %{error: "Must transfer within the same payment group", params: params}
  end
end
