class Comment < Participation
  belongs_to :content
  has_one :comment_data

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
      :subject         => subject,
      :body            => body
    }
  end

  def publish_participation
    return unless content.present? && self.moderated?

    content.commenters.update_all('comments_count = (comments_count + 1)')

    super

  end
  private :publish_participation
end
