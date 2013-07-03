require 'spec_helper'

describe Plink::RemoteImagePath do
  it 'interpolates the given relative path with the image_base_url config option' do
    Plink::Config.any_instance.stub(:image_base_url) { 'http://www.example.com/' }
    Plink::RemoteImagePath.url_for('images/dunkin_donuts.png').should == 'http://www.example.com/images/dunkin_donuts.png'
  end

  it 'does not create double slashes after the domain name' do
    Plink::Config.any_instance.stub(:image_base_url) { 'http://www.example.com/' }
    Plink::RemoteImagePath.url_for('/images/dunkin_donuts.png').should == 'http://www.example.com/images/dunkin_donuts.png'
  end

  it 'does not create a url with no slash after the domain name' do
    Plink::Config.any_instance.stub(:image_base_url) { 'http://www.example.com' }
    Plink::RemoteImagePath.url_for('images/dunkin_donuts.png').should == 'http://www.example.com/images/dunkin_donuts.png'
  end

  it 'does not blow up if image is nil' do
    Plink::Config.any_instance.stub(:image_base_url) { 'http://www.example.com' }
    Plink::RemoteImagePath.url_for(nil).should == 'http://www.example.com/'
  end
end