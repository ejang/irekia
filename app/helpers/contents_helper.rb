module ContentsHelper
  include ApplicationHelper

  def render_partial_for_content
    case params[:type]
    when 'Question'
      @questions = @contents
      render 'shared/questions'
    end
  end

  def link_for_questions(filters = {})
    filters[:more_polemic] = params[:more_polemic] unless filters.key?(:more_polemic)
    filters[:answered]     = params[:answered] unless filters.key?(:answered)

    questions_path(filters)
  end
end
