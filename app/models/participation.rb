class Participation < ActiveRecord::Base
  belongs_to :user
  belongs_to :content

  before_create :update_published_at
  after_save  :publish_participation

  accepts_nested_attributes_for :user

  scope :moderated,     where(:moderated => true)
  scope :not_moderated, where(:moderated => false)

  def self.validate_all_not_moderated
    self.not_moderated.find_each do |participation|
      participation.update_attribute('moderated', true)
    end
  end

  def update_published_at
    self.published_at = Time.now
  end
  private :update_published_at

  def publish_participation
    return unless content.present? && self.moderated?

    content.areas.each do |area|
      area_action = area.actions.new
      area_action.event_id   = self.id
      area_action.event_type = self.class.name.downcase
      area_action.published_at = self.published_at
      area_action.message = self.to_html
      area_action.save!
    end
  end
  private :publish_participation
end
