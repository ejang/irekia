module UsersHelper
  include ApplicationHelper

  def page_title
    @title = ['IREKIA']
    if @user.present?
      @title << @user.fullname
      @title << t(params[:action], :scope => "users.#{@viewing_access}.navigation_menu") if params[:action]
    end
    @title.join(' - ')
  end

  def link_for_actions(filters = {})
    filters[:more_polemic] = params[:more_polemic] unless filters[:more_polemic].present?
    filters[:type]         = params[:type] unless filters[:type].present?

    actions_user_path(@user, filters)
  end

  def link_for_proposals(filters = {})
    filters[:more_polemic]     = params[:more_polemic] unless filters.key?(:more_polemic)
    filters[:from_politicians] = params[:from_politicians] unless filters.key?(:from_politicians)
    filters[:from_citizens]    = params[:from_citizens] unless filters.key?(:from_citizens)
    filters[:as_author]        = params[:as_author] unless filters.key?(:as_author)

    proposals_user_path(@user, filters)
  end

  def link_for_questions(filters = {})
    filters[:more_polemic] = params[:more_polemic] unless filters.key?(:more_polemic)
    filters[:answered]     = params[:answered] unless filters.key?(:answered)
    filters[:to_you]       = params[:to_you] unless filters.key?(:to_you)
    filters[:to_your_area] = params[:to_your_area] unless filters.key?(:to_your_area)

    questions_user_path(@user, filters)
  end

  def link_for_agenda(filters = {})
    agenda_user_path(@user, filters)
  end

  def current_section?(section = nil)
    'selected' if params[:section] == section
  end

end
