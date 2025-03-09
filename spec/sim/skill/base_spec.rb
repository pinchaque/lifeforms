include Skill


describe "Base" do
  let(:id1) { :test_param_1 }
  let(:min) { 50.0 }
  let(:max) { 90.0 }
  let(:desc) { "Test description" }

  class TestSkill < Skill::Base
    define_param :test_param_1 do |prm|
      prm.desc = "Test description"
      prm.value_min = 50.0
      prm.value_max = 90.0
      prm.distrib = DistribLinear.new(50.0, 90.0)
    end
  end

  context "defs" do
    let(:s) { TestSkill }

    it "has param definitions" do
      prms = s.param_defs
      expect(prms.count).to eq(1)
      expect(prms.key?(id1)).to be true
      
      [prms[id1], s.param_def(id1)].each do |pd|
        expect(pd.id).to eq(id1)
        expect(pd.desc).to eq(desc)
        expect(pd.value_min).to eq(min)
        expect(pd.value_max).to eq(max)
      end
    end
  end
end