class ContestPresenter

  attr_reader :contest

  def initialize(attributes = {})
    @contest = attributes.fetch(:contest)
  end

  delegate :description, :end_time, :ended?, :finalized?, :id, :image, :non_linked_image,
    :prize, :start_time, :started?, :terms_and_conditions, to: :contest

  def start_date
    start_time.strftime('%_m/%-d/%y')
  end

  def end_date
    end_time.strftime('%_m/%-d/%y')
  end

end
