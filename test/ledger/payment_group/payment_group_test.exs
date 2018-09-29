defmodule Ledger.PaymentGroupTest do
  use Ledger.DataCase

  alias Ledger.PaymentGroup
  alias Ledger.PaymentGroup.{Group, Participant}

  describe "groups" do
    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def group_fixture(attrs \\ %{}) do
      {:ok, group} =
        attrs
        |> Enum.into(@valid_attrs)
        |> PaymentGroup.create_group()

      group
    end

    test "list_groups/0 returns all groups" do
      group = group_fixture()
      assert PaymentGroup.list_groups() == [group]
    end

    test "get_group!/1 returns the group with given id" do
      group = group_fixture()
      assert PaymentGroup.get_group!(group.id) == group
    end

    test "create_group/1 with valid data creates a group" do
      assert {:ok, %Group{} = group} = PaymentGroup.create_group(@valid_attrs)
      assert group.name == "some name"
    end

    test "create_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = PaymentGroup.create_group(@invalid_attrs)
    end

    test "update_group/2 with valid data updates the group" do
      group = group_fixture()
      assert {:ok, group} = PaymentGroup.update_group(group, @update_attrs)
      assert %Group{} = group
      assert group.name == "some updated name"
    end

    test "update_group/2 with invalid data returns error changeset" do
      group = group_fixture()
      assert {:error, %Ecto.Changeset{}} = PaymentGroup.update_group(group, @invalid_attrs)
      assert group == PaymentGroup.get_group!(group.id)
    end

    test "delete_group/1 deletes the group" do
      group = group_fixture()
      assert {:ok, %Group{}} = PaymentGroup.delete_group(group)
      assert_raise Ecto.NoResultsError, fn -> PaymentGroup.get_group!(group.id) end
    end

    test "change_group/1 returns a group changeset" do
      group = group_fixture()
      assert %Ecto.Changeset{} = PaymentGroup.change_group(group)
    end
  end

  describe "participants" do
    @valid_attrs %{amount: 42, name: "some name"}
    @update_attrs %{amount: 43, name: "some updated name"}
    @invalid_attrs %{group_id: nil, amount: nil, name: nil}

    def participant_fixture(attrs \\ %{}) do
      %Group{id: group_id} = group_fixture()
      {:ok, participant} =
        attrs
        |> Enum.into(%{group_id: group_id})
        |> Enum.into(@valid_attrs)
        |> PaymentGroup.create_participant()

      {participant, group_id}
    end

    test "list_participants/1 returns all participants" do
      {participant, group_id} = participant_fixture()
      assert PaymentGroup.list_participants(group_id) == [participant]
    end

    test "get_participant!/1 returns the participant with given id" do
      {participant, _group_id} = participant_fixture()
      assert PaymentGroup.get_participant!(participant.id) == participant
    end

    test "create_participant/1 with valid data creates a participant" do
      %Group{id: group_id} = group_fixture()
      assert {:ok, %Participant{} = participant} =
        %{group_id: group_id}
        |> Enum.into(@valid_attrs)
        |> PaymentGroup.create_participant()

      assert participant.amount == 42
      assert participant.name == "some name"
    end

    test "create_participant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = PaymentGroup.create_participant(@invalid_attrs)
    end

    test "update_participant/2 with valid data updates the participant" do
      {participant, _group_id} = participant_fixture()
      assert {:ok, participant} = PaymentGroup.update_participant(participant, @update_attrs)
      assert %Participant{} = participant
      assert participant.amount == 43
      assert participant.name == "some updated name"
    end

    test "update_participant/2 with invalid data returns error changeset" do
      {participant, _group_id} = participant_fixture()
      assert {:error, %Ecto.Changeset{}} = PaymentGroup.update_participant(participant, @invalid_attrs)
      assert participant ==  PaymentGroup.get_participant!(participant.id)
    end

    test "delete_participant/1 deletes the participant" do
      {participant, _group_id} = participant_fixture()
      assert {:ok, %Participant{}} = PaymentGroup.delete_participant(participant)
      assert_raise Ecto.NoResultsError, fn -> PaymentGroup.get_participant!(participant.id) end
    end

    test "change_participant/1 returns a participant changeset" do
      {participant, _group_id} = participant_fixture()
      assert %Ecto.Changeset{} = PaymentGroup.change_participant(participant)
    end
  end
end
