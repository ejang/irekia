class AreasController < ApplicationController

  skip_before_filter :authenticate_user!,    :only => [:show, :actions, :questions, :proposals, :agenda, :team]
  before_filter :get_area_data,              :only => [:show, :update, :actions, :questions, :proposals, :agenda, :team]
  before_filter :get_actions,                :only => [:show, :actions, :questions, :proposals, :agenda, :team]
  before_filter :build_questions_for_update, :only => [:questions]
  before_filter :get_questions,              :only => [:show, :questions]
  before_filter :get_proposals,              :only => [:show, :proposals]
  before_filter :get_agenda,                 :only => [:show, :agenda]

  def show
  end

  def update

    if @area.update_attributes(params[:area])
      flash[:notice] = :question_created if params['area']['questions_attributes'].present?
    else
      flash[:notice] = :question_failed if params['area']['questions_attributes'].present?
    end

    redirect_back_or_default area_path(@area)
  end

  def actions
    render :partial => 'shared/actions_list', :layout => nil if request.xhr?
  end

  def questions
    @question_target    = @area
    session[:return_to] = questions_area_path(@area)
  end

  def proposals
  end

  def agenda
  end

  def team
  end

  private
  def get_area_data
    @area = Area.where(:id => params[:id]).first if params[:id].present?
    @team = @area.team.includes(:title)
  end

  def get_actions
    @actions = @area.actions
    @actions = @actions.where(:event_type => params[:type]) if params[:type].present?
  end

  def build_questions_for_update
    return if current_user.blank?
    @question                  = current_user.questions.build
    @question_data             = @question.build_question_data
    @question_data.target_area = @area
  end

  def get_questions
    @questions = @area.questions.moderated
  end

  def get_proposals
    @proposals = @area.proposals.moderated
  end

  def get_agenda
    case action_name
    when 'show'
      @beginning_of_calendar = Date.current.beginning_of_week
      @end_of_calendar       = Date.current.next_week.end_of_week
    when 'agenda'
      @beginning_of_calendar = Date.current.beginning_of_week
      @end_of_calendar       = Date.current.advance(:weeks => 3).end_of_week
    end

    @agenda = @area.events.moderated.where('event_data.event_date >= ? AND event_data.event_date <= ?', @beginning_of_calendar, @end_of_calendar)
    @days   = @beginning_of_calendar..@end_of_calendar
  end
end
