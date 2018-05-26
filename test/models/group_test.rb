require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  test "is valid" do
    group = fake_group

    assert group.valid?
  end

  test "is invalid without location" do
    group = fake_group(location: "")
    refute group.valid?
  end

  test "is invalid without name" do
    group = fake_group(name: "")
    refute group.valid?
  end

  test "is invalid with short name" do
    group = fake_group(name: "Gr")
    refute group.valid?
  end

  test "is invalid without description" do
    group = fake_group(description: "")
    refute group.valid?
  end

  test "is invalid with short description" do
    group = fake_group(description: "Our group")
    refute group.valid?
  end

  test "is invalid without an image" do
    group = fake_group(image: "")
    refute group.valid?
  end

  test ".unhidden" do
    groups = Group.unhidden

    assert groups.none? { |group| group.hidden? }
  end

  test ".unhidden_without" do
    group = groups(:one)

    groups_selection = Group.unhidden_without(group)

    refute groups_selection.include?(group)
  end

  test "#owner" do
    group = fake_group(owner: users(:penny))

    assert_equal group.owner.name, "Penny"
  end

  test "#members" do
    group   = groups(:one)
    penny   = users(:penny)
    woodell = users(:woodell)

    assert_equal [penny, woodell], group.members
  end

  test "#events" do
    group = groups(:one)

    assert group.events.count > 1
  end

  test "titleizes name before saving" do
    group = fake_group(name: "john's group")

    group.save

    assert_equal "John's Group", group.name
  end

  test "titleizes location before saving" do
    group = fake_group(location: "the universe")

    group.save

    assert_equal "The Universe", group.location
  end

  test "capitalizes description before saving" do
    description = "no one saves us but ourselves. No one can and no one may. We ourselves must walk the path."
    description_capitalized = "No one saves us but ourselves. No one can and no one may. We ourselves must walk the path."

    group = fake_group(description: description)

    group.save

    assert_equal description_capitalized, group.description
  end

  test "adds owner as organizer after creation" do
    group = fake_group
    owner = group.owner

    assert_empty group.organizers

    group.save

    assert_equal owner, group.organizers.last
  end

  private

    def fake_group(params = {})
      Group.new(
        owner:        params[:owner]        || users(:phil),
        name:         params[:name]         || "Test group",
        location:     params[:location]     || Faker::Address.city,
        description:  params[:description]  || Faker::Lorem.paragraph,
        image:        params[:image]        || valid_image,
        sample_group: params[:sample_group] || false,
        hidden:       params[:hidden]       || true,
        all_members_can_create_events:
          params[:all_members_can_create_events] || true
      )
    end
end
