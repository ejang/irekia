module PoliticsHelper
  include ApplicationHelper

  def link_for_actions
    actions_politic_path(@politic)
  end

  def link_for_proposals
    proposals_politic_path(@politic)
  end

  def link_for_questions
    questions_politic_path(@politic)
  end

  def link_for_agenda
    agenda_politic_path(@politic)
  end

  def agenda_for_day(agenda, day)
    day_events = agenda.select{|e| e.event_date.to_date.eql?(day.to_date)}
    html= []
    day_events.each do |event|
      html << content_tag(:div, event.subject)
    end
    html.join
  end
end