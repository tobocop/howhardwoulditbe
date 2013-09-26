class TrackingObject

  attr_reader :affiliate_id,
              :sub_id,
              :sub_id_two,
              :sub_id_three,
              :sub_id_four,
              :path_id,
              :campaign_hash,
              :ip,
              :campaign_id,
              :landing_page_id

  def initialize(options)
    defaults = self.class.defaults

    @affiliate_id = options.fetch(:affiliate_id, defaults['AID'])
    @sub_id = options.fetch(:sub_id, defaults['SUBID'])
    @sub_id_two = options.fetch(:sub_id_two, defaults['SUBID2'])
    @sub_id_three = options.fetch(:sub_id_three, defaults['SUBID3'])
    @sub_id_four = options.fetch(:sub_id_four, defaults['SUBID4'])
    @path_id = options.fetch(:path_id, defaults['PATHID'])
    @campaign_hash = options.fetch(:campaign_hash, defaults['C'])
    @campaign_id = options.fetch(:campaign_id, defaults['CAMPAIGIN_ID'])
    @landing_page_id = options.fetch(:landing_page_id, defaults['LANDING_PAGE_ID'])
    @ip = options.fetch(:ip, '0.0.0.0')
  end

  def self.from_params(mixed_case_params = {})
    options = {}
    mixed_case_params.each do |key, value|
      options[key.upcase] = value
    end

    options = self.defaults.merge(options)

    self.new(
      affiliate_id: options.fetch('AID'),
      sub_id: options.fetch('SUBID'),
      sub_id_two: options.fetch('SUBID2'),
      sub_id_three: options.fetch('SUBID3'),
      sub_id_four: options.fetch('SUBID4'),
      path_id: options.fetch('PATHID'),
      campaign_hash: options.fetch('C'),
      campaign_id: options.fetch('CAMPAIGN_ID'),
      landing_page_id: options.fetch('LANDING_PAGE_ID')
    )
  end

  def to_hash
    {
      affiliate_id: affiliate_id,
      sub_id: sub_id,
      sub_id_two: sub_id_two,
      sub_id_three: sub_id_three,
      sub_id_four: sub_id_four,
      path_id: path_id,
      campaign_hash: campaign_hash,
      campaign_id: campaign_id,
      landing_page_id: landing_page_id,
      ip: ip
    }
  end

  def steelhouse_additional_info(virtual_currency_id)
    additional_info_params = {
      affiliateid: affiliate_id,
      subid: sub_id || '',
      subid2: sub_id_two || '',
      subid3: sub_id_three || '',
      subid4: sub_id_four || '',
      campaignid: campaign_id || '',
      pathid: path_id,
      virtualcurrencyid: virtual_currency_id
    }

    additional_info = ''

    additional_info_params.each do |key, value|
      additional_info += "&#{key}=#{value.to_s.downcase},"
    end

    additional_info.html_safe
  end

  private

  def self.defaults
    {
      'AID' => '1',
      'SUBID' => nil,
      'SUBID2' => nil,
      'SUBID3' => nil,
      'SUBID4' => nil,
      'PATHID' => '1',
      'C' => nil,
      'CAMPAIGN_ID' => nil,
      'LANDING_PAGE_ID' => nil
    }
  end

end
