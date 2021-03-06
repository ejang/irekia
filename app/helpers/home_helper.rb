module HomeHelper

  def link_for_actions(filters = {})
    filters[:more_polemic] = params[:more_polemic] unless filters.key?(:more_polemic)
    filters[:type]         = params[:type] unless filters.key?(:type)

    root_path(filters)
  end

  def link_for_agenda(filters = {})
    agenda_path(@area, filters)
  end
end
