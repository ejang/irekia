class Document < Content
  def as_json(options = {})
    {
      :author          => {
        :id            => author.id,
        :name          => author.name,
        :fullname      => author.fullname,
        :profile_image => author.profile_image
      },
      :published_at    => published_at
    }
  end
end
