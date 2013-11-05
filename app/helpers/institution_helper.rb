module InstitutionHelper
  def authentication_form_link(institution_name, institution_id)
    link_to institution_name, institution_authentication_path(institution_id), class: 'text-link'
  end

  def display_institution(institution)
    if institution.is_supported?
      haml_concat authentication_form_link(institution.name.html_safe, institution.institution_id)
    else
      haml_tag :div, class: 'font-italic font-lightgray' do
        haml_concat "* #{institution.name.html_safe}"
      end
    end
  end
end
