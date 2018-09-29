defmodule LedgerWeb.GroupView do
  use LedgerWeb, :view
  alias LedgerWeb.GroupView

  def render("index.json", %{groups: groups}) do
    %{data: render_many(groups, GroupView, "group.json")}
  end

  def render("show.json", %{group: group}) do
    %{data: render_one(group, GroupView, "group.json")}
  end

  def render("show_total.json", %{group_total: group_total}) do
    %{data: render_one(group_total, GroupView, "total.json", as: :group_total)}
  end

  def render("group.json", %{group: group}) do
    %{id: group.id,
      name: group.name}
  end

  def render("total.json", %{group_total: group_total}) do
    %{group_total: group_total}
  end
end
