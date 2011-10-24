class Comment < Participation
  belongs_to :content,
             :counter_cache => true
  has_one :comment_data,
          :select => 'comment_id, body'

  delegate :subject, :body, :to => :comment_data

  accepts_nested_attributes_for :comment_data

  def create_with_body(body)
    self.comment_data = CommentData.create :body => body
    self.save!
    self
  end

  def as_json(options = {})
    {
      :author          => {
        :id            => user.id,
        :name          => user.name,
        :fullname      => user.fullname,
        :profile_image => user.profile_image
      },
      :published_at    => published_at,
      :body            => body
    }
  end

  def publish_participation
    return unless content.present? && self.moderated?

    content.commenters.each { |user| User.increment_counter('comments_count', user.id) }

    super

  end
  private :publish_participation
end
