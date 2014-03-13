class ReturnToPresenter
  attr_reader :session_path, :contest

  def initialize(session_path)
    @session_path = session_path
    @contest = Plink::ContestRecord.current
  end

  def show?
    true
  end

  def description
    "You'll now earn 5X entries every time you enter a contest."
  end

  def link_text
    'Go to ' + contest.description
  end

  def path
    session_path + '?card_linked=true'
  end
end
