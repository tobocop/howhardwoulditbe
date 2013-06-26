module ApplicationHelper
  def class_for_nav_tab(current_tab, tab)
    current_tab == tab ? 'selected' : ''
  end
end
