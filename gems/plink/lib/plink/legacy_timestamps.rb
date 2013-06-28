module Plink::LegacyTimestamps
  def created_at
    self.created
  end

  def updated_at
    self.modified
  end

  private

  def timestamp_attributes_for_create
    super << :created
  end

  def timestamp_attributes_for_update
    super << :modified
  end
end