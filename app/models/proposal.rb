class Proposal < Content
  include PgSearch

  has_one :proposal_data,
          :select => 'id, proposal_id, area_id, title, body, close, participation, in_favor, against'
  has_many :votes,
           :foreign_key => :content_id,
           :dependent   => :destroy,
           :include     => :vote_data
  has_many :arguments,
           :foreign_key => :content_id,
           :dependent   => :destroy,
           :include     => :argument_data,
           :order       => 'published_at'

  pg_search_scope :search_existing_proposals,
                  :associated_against => {
                    :proposal_data => :title
                  },
                  :using => {
                    :tsearch => {:prefix => true, :any_word => true}
                  }

  accepts_nested_attributes_for :proposal_data, :arguments, :votes

  delegate :in_favor, :against, :participation, :title, :body, :target_area, :image, :to => :proposal_data, :allow_nil => true

  def self.by_id(id)
    scoped.includes([{:author => :profile_pictures}, :proposal_data, { :comments => [:author, :comment_data] }]).find(id)
  end

  def self.open
    joins(:proposal_data).where('proposal_data.close' => false)
  end

  def self.close
    joins(:proposal_data).where('proposal_data.close' => true)
  end

  def self.from_politicians
    joins(:author => :role).where('roles.name = ?', 'Politician')
  end

  def self.from_citizens
    joins(:author => :role).where('roles.name = ?', 'Citizen')
  end

  def self.from_area(area)
    joins(:proposal_data => :target_area, :author => :areas).moderated.where('areas.id => ? OR target_areas_proposal_data.id = ?', area.id, area.id)
  end

  def self.from_politician(user)
    joins(:author, :proposal_data => {:target_area => :users}).moderated.where('users.id = ? OR users_areas.id = ?', user.id, user.id)
  end

  def self.from_citizen(user)
    joins(:author).moderated.where('users.id' => user.id)
  end

  def self.approved_by_majority
    joins(:proposal_data).where('proposal_data.in_favor > proposal_data.against')
  end

  def text
    title
  end

  def has_image?
    image.present? && image.content_url.present?
  end

  def percent_in_favor
    return 0 if participation.blank?
    return 0 if participation == 0
    (in_favor * 100 / participation).round || 0
  end

  def percent_against
    100 - percent_in_favor
  end

  def percentage
    [percent_in_favor, percent_against].sort.last
  end

  def as_json(options = {})
    super({
      :title            => title,
      :participation    => participation,
      :in_favor         => in_favor,
      :against          => against,
      :percentage       => percentage,
      :percent_in_favor => percent_in_favor,
      :percent_against  => percent_against,
      :target_area      => {
        :id   => target_area.try(:id),
        :name => target_area.try(:name)
      }
    })
  end

  def update_statistics
    return unless proposal_data && votes

    proposal_data.in_favor      = votes.in_favor.count
    proposal_data.against       = votes.against.count
    proposal_data.participation = votes.count
    proposal_data.save!
  end

  def facebook_share_message
    title.truncate(140)
  end

  def twitter_share_message
    title.truncate(140)
  end

  def email_share_message
    title
  end

  def publish

    return unless self.moderated?

    if target_area
      area_action              = target_area.actions.find_or_create_by_event_id_and_event_type self.id, self.class.name
      area_action.published_at = self.published_at
      area_action.message      = self.to_json
      area_action.save!

      target_area.followers.each do |follower|
        user_action              = follower.private_actions.find_or_create_by_event_id_and_event_type self.id, self.class.name
        user_action.published_at = self.published_at
        user_action.message      = self.to_json
        user_action.save!
      end
    end

  end
  private :publish

  def notification_for(user)
    target_area.team.each{|politician| Notification.for(politician, self)} if target_area
  end

end
