# frozen_string_literal: true

# A sample event created for every new user.
class SampleEvent
  COMMENT_SEEDS = YAML.load_file("db/seeds/event_comment_seeds.yml").shuffle

  def self.create_for_group(group)
    new(group).create_sample_event
  end

  def initialize(group)
    @group = group
    @event = nil
    @attendances = []
    @comments = []
  end

  def create_sample_event
    create_event
    add_sample_attendees
    add_sample_comments
  end

  private

    attr_reader :group, :event

    def create_event
      @event = group.events.build(
        organizer_id: group.owner.id,
        title:        event_title,
        description:  event_description,
        website:      event_website,
        start_date:   event_start_date,
        end_date:     event_end_date,
        sample_event: true
      )

      @event.build_address(event_address)
      @event.send(:set_slug)

      # We don't validate because we are not setting the image,
      # so it's going to use the default one set by EventImageUploader.
      @event.save(validate: false)
    end

    def event_title
      I18n.t("sample_event.title")
    end

    def event_description
      I18n.t("sample_event.description")
    end

    def event_website
      I18n.t("sample_event.website")
    end

    def event_start_date
      Time.zone.now + 1.month
    end

    def event_end_date
      Time.zone.now + (1.month + 3.hours)
    end

    def event_address
      {
        place_name: "Playa del Duque",
        street1:    "Costa Adeje",
        city:       "Adeje",
        post_code:  "38660",
        country:    "Spain",
        latitude:   28.0919,
        longitude:  -16.7414
      }
    end

    def add_sample_attendees
      random_members.each do |member|
        @attendances << Attendance.new(attendee: member, attended_event: event)
      end

      Attendance.import(@attendances)
    end

    def random_members
      group.members_with_role.shuffle[0..29]
    end

    def add_sample_comments
      COMMENT_SEEDS.each { |seed| @comments << new_comment_with(seed) }

      TopicComment.import(@comments)
    end

    def new_comment_with(seed)
      attendee = event.attendees.sample

      event_topic.comments.new(
        user:      attendee,
        body:      seed["body"],
        edited_by: attendee
      )
    end

    def event_topic
      event.topic
    end
end
