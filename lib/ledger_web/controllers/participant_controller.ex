defmodule LedgerWeb.ParticipantController do
  use LedgerWeb, :controller

  alias Ledger.PaymentGroup
  alias Ledger.PaymentGroup.Participant

  action_fallback LedgerWeb.FallbackController

  def index(conn, _params) do
    participants = PaymentGroup.list_participants()
    render(conn, "index.json", participants: participants)
  end

  def create(conn, params) do
    check_non_neg_amount(conn, params)

    updated_params = %{
      "group_id" => params["group_id"],
      "name" => params["participant"]["name"],
      "amount" => params["participant"]["amount"]
    }

    with {:ok, %Participant{} = participant} <- PaymentGroup.create_participant(updated_params) do
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
      send_resp(conn, :no_content, "")
    end
  end

  defp check_non_neg_amount(conn, params) do
    if params["participant"]["amount"] < 0 do
      render(conn, "non_neg.json", params: params)
      raise "Amount must be non negative"
    end
  end
end
