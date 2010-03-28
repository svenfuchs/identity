module Identity::Helpers
  def identity_links(identity)
    links = [identity_link(identity)] + profile_links(identity)
    links.compact
  end

  def identity_link(identity)
    %(<a class="name" href="#{identity.url}">#{identity.url}</a>) if identity.url
  end

  def profile_links(identity)
    identity.profiles.map { |name, profile| profile_link(name, profile_url(name, profile)) }.compact
  end

  def profile_link(name, url)
    %(<a href="#{url}" class="profile #{name}">#{url}</a>) if url
  end

  def profile_url(name, profile)
    Identity::Sources[name].profile_url(profile)
  end
end