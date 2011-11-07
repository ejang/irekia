class ParticipationsController < ApplicationController
  before_filter :get_participation_class
  before_filter :get_participation, :only => [:show, :update]

  respond_to :html

  def show
    @moderation_status = @participation.moderated?? 'moderated' : 'not_moderated'

    respond_with(@participation) do |format|
      format.html { render :layout => !request.xhr? }
    end


  end

  def create
    participation_params = params[@participation_type]
    participation_params[:user_id] = current_user.id

    @participation = @participation_class.find_or_initialize participation_params

    if @participation.save
      redirect_to @participation
    else
      head :error
    end
  end

  def update
    if @participation.update_attributes params[@participation_type]
      redirect_to @participation
    else
      head :error
    end
  end

  def get_participation_class
    @participation_class = params[:type].constantize
    @participation_type = params[:type].downcase
  end
  private :get_participation_class

  def get_participation
    @participation = @participation_class.where(:id => params[:id]).first
  end
  private :get_participation
end
