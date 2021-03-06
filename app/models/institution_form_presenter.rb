class InstitutionFormPresenter

  attr_reader :email, :home_url, :institution, :phone_number, :raw_form_data

  def initialize(intuit_institution_data)
    @institution = intuit_institution_data.fetch(:institution)
    @email = intuit_institution_data[:institution_detail][:email_address]
    @home_url = intuit_institution_data[:institution_detail][:home_url]
    @phone_number = intuit_institution_data[:institution_detail][:phone_number]
    @raw_form_data = intuit_institution_data[:institution_detail][:keys][:key]
  end

  delegate :logo_url, :intuit_institution_id, :name, to: :institution

  def form_fields
    valid_ordered_fields = display_fields.sort_by { |field| field[:display_order].to_i }

    valid_ordered_fields.each_with_index.map do |field, index|
      {
        field_name: field[:name],
        label: field[:description],
        field_tag: field_tag(field, "auth_#{index+1}")
      }
    end
  end

  def contact_phone_number
    return nil if @phone_number.blank?
    @home_url.nil? ? "(#{@phone_number})" : "or (#{@phone_number})"
  end

private

  def field_tag(intuit_field, field_name)
    description = intuit_field[:description]
    length = intuit_field[:value_length_max].to_i == 0 ? nil : intuit_field[:value_length_max].to_i

    field_tag = {
      method: :text_field_tag,
      arguments: [field_name, nil, {
        class: 'form-field input required',
        placeholder: description,
        length: length
      }]
    }
    field_tag.merge!(method: :password_field_tag) if intuit_field[:mask] == 'true'

    field_tag
  end

  def display_fields
    @raw_form_data.reject {|field| field[:display_flag] == 'false' }
  end
end
