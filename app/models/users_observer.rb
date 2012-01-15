class UsersObserver < ActiveRecord::Observer
  observe :user

  def after_save(user)
    IrekiaMailer.welcome(user).deliver if user.just_created?
  end

  def after_destroy(user)
    IrekiaMailer.deleted_account(user).deliver
  end
end
