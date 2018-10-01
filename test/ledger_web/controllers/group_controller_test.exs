defmodule LedgerWeb.GroupControllerTest do
  use LedgerWeb.ConnCase

  alias Ledger.PaymentGroup
  alias Ledger.PaymentGroup.Group

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:group) do
    {:ok, group} = PaymentGroup.create_group(@create_attrs)
    group
  end

  def fixture(:group_total) do
    {:ok, %Group{id: group_id}} = PaymentGroup.create_group(@create_attrs)
    {:ok, first_participant} = PaymentGroup.create_participant(%{username: "alice", amount: 100, group_id: group_id})
    {:ok, second_participant} = PaymentGroup.create_participant(%{username: "bob", amount: 100, group_id: group_id})

    [first_participant, second_participant]
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all groups", %{conn: conn} do
      conn = get conn, group_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create group" do
    test "renders group when data is valid", %{conn: conn} do
      conn = post conn, group_path(conn, :create), @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, group_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "name" => "some name"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, group_path(conn, :create), group: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update group" do
    setup [:create_group]

    test "renders group when data is valid", %{conn: conn, group: %Group{id: id} = group} do
      conn = put conn, group_path(conn, :update, group), group: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, group_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "name" => "some updated name"}
    end

    test "renders errors when data is invalid", %{conn: conn, group: group} do
      conn = put conn, group_path(conn, :update, group), group: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete group" do
    setup [:create_group]

    test "deletes chosen group", %{conn: conn, group: group} do
      conn = delete conn, group_path(conn, :delete, group)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, group_path(conn, :show, group)
      end
    end
  end

  describe "group total" do
    setup [:create_group_total]

    test "renders group total when data is valid", %{conn: conn, group_id: group_id, participants: participants} do
      conn = get conn, group_group_path(conn, :total, group_id)
      assert json_response(conn, 200)["data"] ==
        %{"group_total" => Enum.reduce(participants, 0, fn x, acc -> x.amount + acc end)}
    end
  end

  defp create_group(_) do
    group = fixture(:group)
    {:ok, group: group}
  end

  defp create_group_total(_) do
    participants = fixture(:group_total)
    {:ok, group_id: List.first(participants).group_id, participants: participants}
  end
end
