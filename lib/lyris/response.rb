require 'active_support/core_ext/hash/conversions'

module Lyris
  class Response
    attr_reader :lyris_response_hash

    def initialize(response_xml)
      xml_doc = Nokogiri::XML(response_xml)
      @lyris_response_hash = Hash.from_xml(xml_doc.to_s)
    end

    def successful?
      lyris_response_hash["DATASET"]["TYPE"] == 'success'
    end

    def data
      lyris_response_hash["DATASET"]["DATA"]
    end
  end
end
