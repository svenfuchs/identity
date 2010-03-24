CouchPotato::View::BaseViewSpec.class_eval do
  def design_document
    @design_document.gsub('/', '::') # TODO ask alex
  end
end
