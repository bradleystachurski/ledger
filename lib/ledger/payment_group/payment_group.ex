defmodule Ledger.PaymentGroup do
  @moduledoc """
  The PaymentGroup context.
  """

  import Ecto.Query, warn: false
  alias Ledger.Repo

  alias Ledger.PaymentGroup.{Group, Participant}

  @doc """
  Returns the list of groups.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  def list_groups do
    Repo.all(Group)
  end

  @doc """
  Gets a single group.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group!(123)
      %Group{}

      iex> get_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group!(id), do: Repo.get!(Group, id)

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group(attrs \\ %{}) do
    %Group{}
    |> Group.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group(%Group{} = group, attrs) do
    group
    |> Group.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group(%Group{} = group) do
    Repo.delete(group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group changes.

  ## Examples

      iex> change_group(group)
      %Ecto.Changeset{source: %Group{}}

  """
  def change_group(%Group{} = group) do
    Group.changeset(group, %{})
  end

  @doc """
  Returns the list of participants within the payment group.

  ## Examples

      iex> list_participants(1)
      [%Participant{}, ...]

  """
  def list_participants(group_id) do
    Repo.all(from p in Participant, where: p.group_id == ^group_id)
  end

  @doc """
  Gets a single participant.

  Raises `Ecto.NoResultsError` if the Participant does not exist.

  ## Examples

      iex> get_participant!(123)
      %Participant{}

      iex> get_participant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_participant!(id), do: Repo.get!(Participant, id)

  @doc """
  Creates a participant if amount is non negative.

  ## Examples

      iex> create_participant(%{field: value})
      {:ok, %Participant{}}

      iex> create_participant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_participant(attrs \\ %{}) do
    if attrs["amount"] < 0 do
      {:error, :neg_amount}
    else
      %Participant{}
      |> Participant.changeset(attrs)
      |> Repo.insert()
    end
  end

  @doc """
  Updates a participant.

  ## Examples

      iex> update_participant(participant, %{field: new_value})
      {:ok, %Participant{}}

      iex> update_participant(participant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_participant(%Participant{} = participant, attrs) do
    participant
    |> Participant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Participant.

  ## Examples

      iex> delete_participant(participant)
      {:ok, %Participant{}}

      iex> delete_participant(participant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_participant(%Participant{} = participant) do
    Repo.delete(participant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking participant changes.

  ## Examples

      iex> change_participant(participant)
      %Ecto.Changeset{source: %Participant{}}

  """
  def change_participant(%Participant{} = participant) do
    Participant.changeset(participant, %{})
  end

  @doc """
  Transfers `amount` from one participant to another, if both participants are in the
  same group and `from_participant` has enough funds to make the transfer.
  """
  def transfer(%Participant{} = from_participant, %Participant{} = to_participant, params) do
    cond do
      invalid_transfer_amount?(from_participant, params["amount"]) -> {:error, :insufficient_funds}
      invalid_transfer_group?(from_participant, to_participant) -> {:error, :invalid_group}
      true -> do_transfer(from_participant, to_participant, params["amount"])
    end
  end

  defp invalid_transfer_amount?(from_participant, amount), do: from_participant.amount < amount

  defp invalid_transfer_group?(from_particiapnt, to_participant) do
    from_particiapnt.group_id != to_participant.group_id
  end

  defp do_transfer(from_participant, to_participant, amount) do
    {:ok, updated_from_participant} =
      from_participant
      |> update_participant(%{amount: from_participant.amount - amount})

    {:ok, updated_to_participant} =
      to_participant
      |> update_participant(%{amount: to_participant.amount + amount})

    {:ok, updated_from_participant, updated_to_participant}
  end

  @doc """
  Returns the total value of all participants within a group.
  """
  def group_total(group_id) do
    query = from p in Participant,
      where: p.group_id == ^group_id,
      select: sum(p.amount)
    total = Repo.all(query) |> List.first()
    {:ok, total}
  end
end
