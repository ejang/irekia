class Admin::UsersController < Admin::AdminController
  before_filter :get_user, :only => [:show, :edit, :update, :destroy]
  before_filter :get_roles, :only => [:new, :create, :edit, :update]
  before_filter :get_titles, :only => [:new, :create, :edit, :update]

  def index
    @users = User.oldest_first.all
  end

  def new
    @user = User.new
    @user.areas_users.build
    @user.build_profile_picture
  end

  def create
    @user = User.new(params[:user])
    @user.password              = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]

    if @user.save
      redirect_to admin_user_path(@user)
    else
      render :new
    end
  end

  def edit
    @user.areas_users.build
    @user.build_profile_picture
  end

  def update
    params[:user].delete(:password) if params[:user][:password].blank?
    params[:user].delete(:password_confirmation) if params[:user][:password_confirmation].blank?

    if @user.update_attributes(params[:user])
      redirect_to admin_user_path(@user)
    else
      render :edit
    end
  end

  def show
  end

  def destroy
    @user.destroy

    redirect_to admin_users_path
  end

  private
  def get_user
    @user = User.includes(:areas_users, :profile_picture).find(params[:id])
  end

  def get_roles
    @roles = Role.where(:name_i18n_key => [:administrator, :politician, :citizen])
  end

  def get_titles
    @titles = Title.all
  end
end
