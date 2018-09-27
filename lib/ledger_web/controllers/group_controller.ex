defmodule LedgerWeb.GroupController do
  use LedgerWeb, :controller

  alias Ledger.PaymentGroup
  alias Ledger.PaymentGroup.Group

  action_fallback LedgerWeb.FallbackController

  def index(conn, _params) do
    groups = PaymentGroup.list_groups()
    render(conn, "index.json", groups: groups)
  end

  def create(conn, %{"group" => group_params}) do
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
end
