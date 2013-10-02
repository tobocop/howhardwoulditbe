class ContestPresenter

  attr_reader :contest

  def initialize(attributes = {})
    @contest = attributes.fetch(:contest)
  end

  delegate :description, :end_time, :id, :image, :prize, :start_time, :terms_and_conditions,
    :started?, :ended?, :finalized?, to: :contest

  def start_date
    start_time.strftime('%_m/%-d/%y')
  end

  def end_date
    end_time.strftime('%_m/%-d/%y')
  end

end
