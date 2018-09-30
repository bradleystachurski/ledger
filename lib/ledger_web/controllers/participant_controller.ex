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
    case PaymentGroup.create_participant(params) do
      {:error, :neg_amount} ->
        conn
        |> put_status(:forbidden)
        |> render("non_neg.json", params: params)
      {:ok, %Participant{} = participant} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", group_participant_path(conn, :show, params["group_id"], participant))
        |> render("show.json", participant: participant)
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

    case PaymentGroup.transfer(from_participant, to_participant, params) do
      {:ok, %Participant{} = from_participant, %Participant{} = to_participant} ->
        conn
        |> render("show_transfer.json", from_participant: from_participant, to_participant: to_participant)
      {:error, :insufficient_funds} ->
        conn
        |> put_status(:forbidden)
        |> render("insufficient_funds.json", params: params)
      {:error, :invalid_group} ->
        conn
        |> put_status(:forbidden)
        |> render("invalid_transfer_group.json", params: params)
    end
  end
end
