defmodule LedgerWeb.ParticipantControllerTest do
  use LedgerWeb.ConnCase

  alias Ledger.PaymentGroup
  alias Ledger.PaymentGroup.{Group, Participant}

  @create_attrs %{name: "some name", amount: 100}
  @update_attrs %{name: "some updated name", amount: 101}
  @invalid_attrs %{name: nil, amount: nil}

  def fixture(:group) do
    {:ok, group} = PaymentGroup.create_group(%{name: "some name"})
    group
  end

  def fixture(:participant) do
    %Group{id: group_id} = fixture(:group)
    {:ok, participant} = PaymentGroup.create_participant(%{name: "some name", amount: 100, group_id: group_id})
    participant
  end

  def fixture(:transfer_participants) do
    %Group{id: group_id} = fixture(:group)
    {:ok, from_participant} = PaymentGroup.create_participant(%{name: "alice", amount: 100, group_id: group_id})
    {:ok, to_participant} = PaymentGroup.create_participant(%{name: "bob", amount: 100, group_id: group_id})
    {from_participant, to_participant}
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_group]

    test "lists all participants", %{conn: conn, group: %Group{id: id}} do
      conn = get conn, group_participant_path(conn, :index, id)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create participant" do
    setup [:create_group]

    test "renders participant when data is valid", %{conn: conn, group: %Group{id: group_id}} do
      participant_attrs = %{group_id: group_id} |> Enum.into(@create_attrs)
      conn = post conn, group_participant_path(conn, :create, group_id, participant_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, group_participant_path(conn, :show, group_id, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "amount" => 100,
        "name" => "some name",
        "group_id" => group_id}
    end

    test "renders errors when data is invalid", %{conn: conn, group: %Group{id: group_id}} do
      participant_attrs = %{group_id: group_id} |> Enum.into(@invalid_attrs)
      conn = post conn, group_participant_path(conn, :create, group_id, participant_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update participant" do
    setup [:create_participant]

    test "renders participant when data is valid", %{conn: conn, participant: %Participant{id: id} = participant} do
      conn = put conn, group_participant_path(conn, :update, participant.group_id, id), update_params: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, group_participant_path(conn, :show, participant.group_id, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "amount" => 101,
        "name" => "some updated name",
        "group_id" => participant.group_id}
    end

    test "renders errors when data is invalid", %{conn: conn, participant: %Participant{id: id} = participant} do
      conn = put conn, group_participant_path(conn, :update, participant.group_id, id), update_params: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete participant" do
    setup [:create_participant]

    test "deletes chosen participant and renders final amount", %{conn: conn, participant: %Participant{id: id} = participant} do
      conn = delete conn, group_participant_path(conn, :delete, participant.group_id, id)
      assert json_response(conn, 200)["data"] == %{"final_amount" => 100}
      assert_error_sent 404, fn -> get conn, group_participant_path(conn, :show, participant.group_id, id) end
    end
  end

  describe "transfer" do
    setup [:create_transfer_participants]

    test "transfers between two participants when data is valid", %{conn: conn, from_participant: from_participant, to_participant: to_participant} do
      transfer_params = %{from: from_participant.id, to: to_participant.id, amount: 50}
      conn = post conn, group_participant_path(conn, :transfer, from_participant.group_id), transfer_params
      json_result = json_response(conn, 200)["data"]

      assert json_result["from_participant"]["amount"] == 50
      assert json_result["to_participant"]["amount"] == 150
    end

    test "renders errors when sender has insufficient funds", %{conn: conn, from_participant: from_participant, to_participant: to_participant} do
      transfer_params = %{from: from_participant.id, to: to_participant.id, amount: 150}
      conn = post conn, group_participant_path(conn, :transfer, from_participant.group_id), transfer_params
      assert json_response(conn, 403)
    end
  end

  defp create_group(_) do
    group = fixture(:group)
    {:ok, group: group}
  end

  defp create_participant(_) do
    participant = fixture(:participant)
    {:ok, participant: participant}
  end

  defp create_transfer_participants(_) do
    {from_participant, to_participant} = fixture(:transfer_participants)
    {:ok, from_participant: from_participant, to_participant: to_participant}
  end
end
