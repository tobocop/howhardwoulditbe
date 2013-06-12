shared_examples_for(:legacy_timestamps) do
  it "sets the created field on create (to mirror created_at)" do
    subject.created_at.should be_nil
    subject.save!
    subject.created_at.should be_a Time
  end

  it "sets the modified field (to mirror updated_at)" do
    subject.updated_at.should be_nil
    subject.save!
    subject.updated_at.should be_a Time
  end

  it "does not update the created time on update" do
    subject.save!
    created_at = subject.created_at
    subject.touch
    subject.created_at.should == created_at
  end

  it "does update the modified time on update" do
    subject.save!
    updated_at = subject.created_at
    subject.touch
    subject.updated_at.should_not == updated_at
  end
end