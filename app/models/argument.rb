class Argument < Participation
  belongs_to :proposal,
             :foreign_key => :content_id

  has_one :argument_data

  scope :in_favor, joins(:argument_data).where('argument_data.in_favor' => true)
  scope :against, joins(:argument_data).where('argument_data.in_favor' => false)
  scope :with_reason, joins(:argument_data).where('argument_data.reason IS NOT NULL')

  delegate :in_favor, :against, :reason, :to => :argument_data
  delegate :title, :to => :proposal

  accepts_nested_attributes_for :argument_data

  def as_json(options = {})
    {
      :author          => {
        :id            => user.id,
        :name          => user.name,
        :profile_image => user.profile_image
      },
      :published_at    => published_at,
      :title            => title,
      :reason          => reason,
      :in_favor        => in_favor,
      :against         => against,
      :comments_count  => comments_count
    }
  end
end
