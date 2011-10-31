class AreasController < ApplicationController

  around_filter :benchmark_area, :only => :show
  skip_before_filter :authenticate_user!,    :only => [:show, :actions, :questions, :proposals, :agenda, :team]
  before_filter :get_area,                   :only => [:show, :update, :actions, :questions, :proposals, :agenda, :team]
  before_filter :get_area_data,              :only => [:show, :actions, :questions, :proposals, :agenda, :team]
  before_filter :get_counters,               :only => [:show, :actions, :questions, :proposals, :agenda, :team]
  before_filter :get_actions,                :only => [:show, :actions, :questions, :proposals, :agenda, :team]
  before_filter :get_questions,              :only => [:show, :questions]
  before_filter :get_proposals,              :only => [:show, :proposals]
  before_filter :get_agenda,                 :only => [:show, :agenda]
  before_filter :paginate,                   :only => [:show, :actions, :questions, :proposals]

  respond_to :html, :json

  def benchmark_area
    self.class.benchmark("Area loading benchmark...") do
      yield
    end
  end

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
    render :partial => 'shared/questions_list',
           :layout  => nil and return if request.xhr?

    session[:return_to] = questions_area_path(@area)
  end

  def proposals
    render :partial => 'shared/proposals_list', :layout => nil and return if request.xhr?
  end

  def agenda
    render :partial => 'shared/agenda_list',
           :layout  => nil and return if request.xhr?
  end

  def team
  end

  def get_area
    @area = Area.by_id(params[:id])
  end
  private :get_area

  def get_area_data
    if current_user.blank? || current_user.not_following(@area)
      @follow          = @area.follows.build
      @follow.user     = current_user
    else
      @follow = current_user.followed_item(@area)
    end
    @follow_parent   = @area
    @team            = @area.team.all
  end
  private :get_area_data

  def get_counters
    @followers_count = @area.followers.count
    @news_count      = @area.news_count
    @questions_count = @area.questions_count
    @proposals_count = @area.proposals_count
    @photos_count    = @area.photos_count
    @videos_count    = @area.videos_count
  end
  private :get_counters

  def get_actions
    @actions = @area.actions
    @actions = @actions.where(:event_type => params[:type]) if params[:type].present?

    @actions = if params[:more_polemic] == 'true'
      @actions.more_polemic
    else
      @actions.more_recent
    end
  end
  private :get_actions

  def get_questions
    @questions = @area.questions.moderated
    @questions = @questions.answered if params[:answered]

    @questions = if params[:more_polemic] == 'true'
      @questions.more_polemic
    else
      @questions.more_recent
    end

    @question                  = Question.new
    @question_data             = @question.build_question_data
    @question_data.target_area = @area
  end
  private :get_questions

  def get_proposals
    @proposals = @area.proposals.moderated
    @proposals = @proposals.from_politicians if params[:from_politicians]
    @proposals = @proposals.from_citizens if params[:from_citizens]

    @proposals = if params[:more_polemic] == 'true'
      @proposals.more_polemic
    else
      @proposals.more_recent
    end

    @proposal                  = Proposal.new
    @proposal_data             = @proposal.build_proposal_data
    @proposal_data.target_area = @area
  end
  private :get_proposals

  def get_agenda
    calendar_date = Date.current
    if params[:next_month].present?
      calendar_date = Date.current.advance(:months => params[:next_month].to_i)
    end
    beginning_of_calendar = calendar_date.beginning_of_week

    case action_name
    when 'show'
      end_of_calendar = calendar_date.next_week.end_of_week
    when 'agenda'
      end_of_calendar = calendar_date.advance(:weeks => 3).end_of_week
    end

    events = @area.agenda_between(beginning_of_calendar, end_of_calendar)

    @agenda = events.group_by{|e| e.event_date.day }
    @days   = beginning_of_calendar..end_of_calendar
    @agenda_json = JSON.generate(events.map{|event| {
      :title => event.title,
      :date  => l(event.event_date, :format => '%d, %B de %Y'),
      :when  => event.event_date.strftime('%H:%M'),
      :where => nil,
      :lat   => event.latitude,
      :lon   => event.longitude
    }}.group_by{|event| [event[:lat], event[:lon]]}.values).html_safe
  end
  private :get_agenda

  def paginate
    if action_name == 'show' || params[:referer] == 'show'
      @actions   = @actions.page(1).per(4).all   if @actions
      @questions = @questions.page(1).per(4).all if @questions
      @proposals = @proposals.page(1).per(4).all if @proposals
    else
      @actions   = @actions.page(params[:page]).per(10).all   if @actions
      @questions = @questions.page(params[:page]).per(10).all if @questions
      @proposals = @proposals.page(params[:page]).per(10).all if @proposals
    end
  end
  private :paginate

end
