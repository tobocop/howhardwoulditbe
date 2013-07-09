RSpec::Matchers.define :have_image do |expected|
  match do |actual|
    actual.has_xpath?("//img[contains(@src,\"#{expected}\")]")
  end

  failure_message_for_should do |actual|
    "expected that #{actual.html} to have image #{expected}"
  end
end