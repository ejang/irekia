class ModerationMailer < ActionMailer::Base
  default :from => "test@ferdev.com"

  def accepted(item)
    @item = item
    author = item.respond_to?(:users) && item.users.present? ? item.users.first : item.author

    I18n.with_locale author.locale do
      mail(
        :to => author.email,
        :subject => "Irekia - contenido aceptado"
      )
    end
  end

  def rejected(item)
    @item = item
    author = item.respond_to?(:users) && item.users.present? ? item.users.first : item.author

    I18n.with_locale author.locale do
      mail(
        :to => author.email,
        :subject => "Irekia - contenido rechazado"
      )
    end
  end
end
