describe "MoveToFood" do
  let(:tol) { 0.0001 }
  let(:species) { TestFactory.species }
  let(:env) { TestFactory.env(100, 100, 3, 10) }
  let(:klass) { Skill::MoveToFood }
  let(:skill_id) { klass.id }

  it "TODO implement" do
    expect(true).to be false
  end
end