class UserPrivateStream < ActiveRecord::Base
  belongs_to :user
  belongs_to :author,
             :class_name => 'User'
  belongs_to :event,
             :polymorphic => true
  after_save  :increment_user_counter
  after_destroy :decrement_user_counter

  def self.moderated
    where(:moderated => true)
  end

  def self.moderated_or_author_is(user)
    where('(moderated = ? OR (moderated = ? AND author_id = ?))', true, false, user.id)
  end

  def self.questions
    where(:event_type => 'Question')
  end

  def self.answers
    where(:event_type => 'Answer')
  end

  def self.answer_requests
    where(:event_type => 'AnswerRequest')
  end

  def self.proposals
    where(:event_type => 'Proposal')
  end

  def self.votes
    where(:event_type => 'Vote')
  end

  def self.arguments
    where(:event_type => 'Argument')
  end

  def self.news
    where(:event_type => 'News')
  end

  def self.photos
    where(:event_type => 'Photo')
  end

  def self.videos
    where(:event_type => 'Video')
  end

  def self.events
    where(:event_type => 'Event')
  end

  def self.status_messages
    where(:event_type => %w(StatusMessage Tweet))
  end

  def self.tweets
    where(:event_type => 'Tweet')
  end

  def self.comments
    where(:event_type => 'Comment')
  end

  def self.contents_users
    where(:event_type => 'ContentUser')
  end

  def self.more_recent
    order('published_at desc')
  end

  def self.more_polemic
    joins(<<-SQL
      INNER JOIN (
        SELECT p.content_id, count(p.content_id) AS count
        FROM contents c
        LEFT JOIN participations p ON p.content_id = c.id AND p.type = 'Comment'
        GROUP BY p.content_id
      ) comments_count ON comments_count.content_id = user_private_streams.event_id
                       AND user_private_streams.event_type IN ('Question', 'Answer', 'Proposal', 'Event', 'News', 'Tweet')
    SQL
    ).order('comments_count.count desc, published_at desc')
  end

  def item
    JSON.parse(self.message).hashes2ostruct if self.message.present?
  rescue
  end

  def send_notification
    return if notification_sent || event.blank? || event.not_moderated?
    Notification.for(user, event)
    update_attribute(:notification_sent, true)
  end
  private :send_notification

  def increment_user_counter
    User.increment_counter("private_#{event_type.underscore.pluralize}_count", user_id) if moderated_changed? && moderated
  end
  private :increment_user_counter

  def decrement_user_counter
    User.decrement_counter("private_#{event_type.underscore.pluralize}_count", user_id)
  end
  private :decrement_user_counter

end
