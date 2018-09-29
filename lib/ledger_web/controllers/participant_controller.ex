defmodule LedgerWeb.ParticipantController do
  use LedgerWeb, :controller

  alias Ledger.PaymentGroup
  alias Ledger.PaymentGroup.Participant

  action_fallback LedgerWeb.FallbackController

  def index(conn, params) do
    participants = params["group_id"] |> String.to_integer() |> PaymentGroup.list_participants()
    render(conn, "index.json", participants: participants)
  end

  def create(conn, params) do
    check_non_neg_amount(conn, params)

    with {:ok, %Participant{} = participant} <- PaymentGroup.create_participant(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", group_participant_path(conn, :show, params["group_id"], participant))
      |> render("show.json", participant: participant)
    end
  end

  defp check_non_neg_amount(conn, params) do
    if params["amount"] < 0 do
      render(conn, "non_neg.json", params: params)
      raise "Amount must be non negative"
    end
  end

  def show(conn, %{"id" => id}) do
    participant = PaymentGroup.get_participant!(id)
    render(conn, "show.json", participant: participant)
  end

  def update(conn, %{"id" => id, "participant" => participant_params}) do
    participant = PaymentGroup.get_participant!(id)

    with {:ok, %Participant{} = participant} <- PaymentGroup.update_participant(participant, participant_params) do
      render(conn, "show.json", participant: participant)
    end
  end

  def delete(conn, %{"id" => id}) do
    participant = PaymentGroup.get_participant!(id)
    with {:ok, %Participant{}} <- PaymentGroup.delete_participant(participant) do
      render(conn, "delete.json", participant: participant)
    end
  end

  def transfer(conn, params) do
    from_participant = PaymentGroup.get_participant!(params["from"])
    to_participant = PaymentGroup.get_participant!(params["to"])

    check_invalid_transfer_amount(conn, from_participant, params)
    check_invalid_transfer_group(conn, from_participant, to_participant, params)

    with {:ok, %Participant{} = from_participant, %Participant{} = to_participant} <-
           PaymentGroup.transfer(from_participant, to_participant, params) do
      render(conn, "show_transfer.json",
        from_participant: from_participant,
        to_participant: to_participant
      )
    end
  end

  defp check_invalid_transfer_amount(conn, %Participant{} = participant, params) do
    if params["amount"] > participant.amount do
      render(conn, "invalid_transfer_amount.json", params: params)
      raise "Cannot transfer an amount greater than current balance"
    end
  end

  defp check_invalid_transfer_group(conn, from_participant, to_participant, params) do
    if from_participant.group_id != to_participant.group_id do
      render(conn, "invalid_transfer_group.json", params: params)
      raise "Must transfer within the same payment group"
    end
  end
end
