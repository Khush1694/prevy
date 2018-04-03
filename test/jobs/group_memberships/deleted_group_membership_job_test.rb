require 'test_helper'

class DeletedGroupMembershipJobTest < ActiveJob::TestCase
  def setup
    @user  = users(:phil)
    @group = groups(:one)
  end

  test "queues job" do
    assert_enqueued_jobs 1 do
      DeletedGroupMembershipJob.perform_later(@user, @group)
    end
  end

  test "job delivers email" do
    assert_difference("ActionMailer::Base.deliveries.size", +1) do
      DeletedGroupMembershipJob.perform_now(@user, @group)
    end
  end
end