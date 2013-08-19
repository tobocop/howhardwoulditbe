module AccountHelper

  def show_change_link_for_provider(provider)
    if provider == :organic
      Haml::Engine.new("%a{data: {'toggleable-selector' => '.change'}} Change").render
    end
  end

end
