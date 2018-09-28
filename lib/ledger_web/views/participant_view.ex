defmodule LedgerWeb.ParticipantView do
  use LedgerWeb, :view
  alias LedgerWeb.ParticipantView

  def render("index.json", %{participants: participants}) do
    %{data: render_many(participants, ParticipantView, "participant.json")}
  end

  def render("show.json", %{participant: participant}) do
    %{data: render_one(participant, ParticipantView, "participant.json")}
  end

  def render("participant.json", %{participant: participant}) do
    %{id: participant.id,
      name: participant.name,
      amount: participant.amount}
  end

  def render("non_neg.json", %{params: params}) do
    %{message: "cannot add a user with a negative amount", params: params}
  end
end
