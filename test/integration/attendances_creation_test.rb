require 'test_helper'

class AttendancesCreationTest < ActionDispatch::IntegrationTest
  def setup
    @user  = users(:penny)
    @event = events(:one)
  end

  test "user not logged in can't attend an event" do
    visit event_path(@event)

    assert page.has_no_link? "Attend"
  end

  test "user can attend an event" do
    log_in_as(@user)
    visit event_path(@event)

    click_on "Attend"

    assert page.has_content? "You are attending this event!"
    assert page.has_link? "Cancel attendance"
  end

  test "user can cancel it's attendance to an event" do
    log_in_as(@user)
    visit event_path(@event)

    click_on "Attend"
    click_on "Cancel attendance"

    assert page.has_content? "has been cancelled"
    assert page.has_link? "Attend"
  end
end
