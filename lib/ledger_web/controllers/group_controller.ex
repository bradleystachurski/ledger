defmodule LedgerWeb.GroupController do
  use LedgerWeb, :controller

  alias Ledger.PaymentGroup
  alias Ledger.PaymentGroup.Group

  action_fallback LedgerWeb.FallbackController

  def index(conn, _params) do
    groups = PaymentGroup.list_groups()
    render(conn, "index.json", groups: groups)
  end

  def create(conn, group_params) do
    with {:ok, %Group{} = group} <- PaymentGroup.create_group(group_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", group_path(conn, :show, group))
      |> render("show.json", group: group)
    end
  end

  def show(conn, %{"id" => id}) do
    group = PaymentGroup.get_group!(id)
    render(conn, "show.json", group: group)
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    group = PaymentGroup.get_group!(id)

    with {:ok, %Group{} = group} <- PaymentGroup.update_group(group, group_params) do
      render(conn, "show.json", group: group)
    end
  end

  def delete(conn, %{"id" => id}) do
    group = PaymentGroup.get_group!(id)
    with {:ok, %Group{}} <- PaymentGroup.delete_group(group) do
      send_resp(conn, :no_content, "")
    end
  end

  def total(conn, group_params) do
    group_id = group_params["group_id"] |> String.to_integer()
    with {:ok, group_total} <- PaymentGroup.group_total(group_id) do
      render(conn, "show_total.json", group_total: group_total)
    end
  end
end
