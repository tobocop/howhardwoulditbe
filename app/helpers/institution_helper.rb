module InstitutionHelper
  def authentication_form_link(institution_name, institution_id)
    link_to institution_name, institution_authentication_path(institution_id), class: 'text-link'
  end
end
