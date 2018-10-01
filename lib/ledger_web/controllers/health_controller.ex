defmodule LedgerWeb.HealthController do
  use LedgerWeb, :controller

  @doc """
  Sends a response with 200 status code and no body.

  Allows services e.g. Amazon Elastic Load Balancer, to discover the
  availability of a deployed instance.
  """
  def health(conn, _params) do
    send_resp(conn, :ok, "")
  end
end