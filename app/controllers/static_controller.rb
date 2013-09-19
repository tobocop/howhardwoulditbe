class StaticController < ApplicationController
  def faq
  end

  def terms
    @contest ||= ContestPresenter.new(contest: Plink::ContestRecord.current)
  end

  def privacy
  end

  def careers
  end

  def press
    @articles = plink_news_archive_service.news_articles
  end

  def about
  end

  private

  def plink_news_archive_service
    @plink_archive_service ||= Plink::NewsArticleService.new
  end
end
