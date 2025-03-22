describe "EnvEnergyAbsorb" do
  let(:tol) { 0.0001 }
  let(:species) { TestFactory.species }
  let(:env_energy_rate) { 10.0 }
  let(:env) { TestFactory.env(100, 100, 3, env_energy_rate) }
  let(:klass) { Obs::EnvEnergy }

  context "energy calcs" do

    def add_lf(x, y, size, energy)
      l = TestFactory.lifeform(env, species) 
      l.x = x
      l.y = y
      l.size = size
      l.energy = energy
      l.save
      l
    end

    it "single lifeform" do
      lf = add_lf(10.0, 10.0, 1.0, 20.0)
      ctx = lf.context

      # sanity-check
      expect(lf.env.energy_rate).to be_within(tol).of(10.0)
      expect(lf.energy).to be_within(tol).of(20.0)
      expect(lf.size).to be_within(tol).of(1.0)
      expect(lf.radius).to be_within(tol).of(0.5)
      expect(lf.area).to be_within(tol).of(0.7853981633974483)

      exp_egy = 7.853981633974483 # env_energy_rate * area
      exp_loss = 0.0 # one lifeform => no overlaps
      expect(klass.env_gross(ctx)).to be_within(tol).of(exp_egy)
      expect(klass.overlap_loss(ctx)).to be_within(tol).of(exp_loss)
      expect(klass.energy_net(ctx)).to be_within(tol).of(exp_egy - exp_loss)
      expect(klass.calc(ctx)).to be_within(tol).of(klass.energy_net(ctx))
    end

    it "two lifeforms, no overlap" do
      lf0 = add_lf(10.0, 10.0, 1.0, 20.0)
      lf1 = add_lf(20.0, 10.0, 1.0, 20.0)
      ctx0 = lf0.context
      ctx1 = lf1.context

      exp_egy = 7.853981633974483
      exp_loss = 0.0

      expect(klass.env_gross(ctx0)).to be_within(tol).of(exp_egy)
      expect(klass.overlap_loss(ctx0)).to be_within(tol).of(exp_loss)
      expect(klass.energy_net(ctx0)).to be_within(tol).of(exp_egy - exp_loss)      
      expect(klass.calc(ctx0)).to be_within(tol).of(klass.energy_net(ctx0))

      expect(klass.env_gross(ctx1)).to be_within(tol).of(exp_egy)
      expect(klass.overlap_loss(ctx1)).to be_within(tol).of(exp_loss)
      expect(klass.energy_net(ctx1)).to be_within(tol).of(exp_egy - exp_loss)      
      expect(klass.calc(ctx1)).to be_within(tol).of(klass.energy_net(ctx1))
    end

    it "two lifeforms, overlap" do
      lf0 = add_lf(0.0, 0.0, 2.0, 20.0)
      lf1 = add_lf(1.0, 0.0, 2.0, 20.0)
      ctx0 = lf0.context
      ctx1 = lf1.context
      
      overlap_area = circle_area_intersect(0, 0, 1, 1, 0, 1)

      exp_egy = Math::PI * env_energy_rate
      exp_loss = env_energy_rate * overlap_area / 2.0

      # sanith-check with hard-coded values
      expect(overlap_area).to be_within(tol).of(1.2283696986087564)
      expect(exp_egy).to be_within(tol).of(31.41592653589793)
      expect(exp_loss).to be_within(tol).of(6.141848493043782)
      expect(env_energy_rate).to be_within(tol).of(10.0)

      expect(klass.env_gross(ctx0)).to be_within(tol).of(exp_egy)
      expect(klass.overlap_loss(ctx0)).to be_within(tol).of(exp_loss)
      expect(klass.energy_net(ctx0)).to be_within(tol).of(exp_egy - exp_loss)    
      expect(klass.env_gross(ctx0)).to be >= 0.0  
      expect(klass.overlap_loss(ctx0)).to be >= 0.0  
      expect(klass.energy_net(ctx0)).to be >= 0.0  
      expect(klass.calc(ctx0)).to be_within(tol).of(klass.energy_net(ctx0))

      expect(klass.env_gross(ctx1)).to be_within(tol).of(exp_egy)
      expect(klass.overlap_loss(ctx1)).to be_within(tol).of(exp_loss)
      expect(klass.energy_net(ctx1)).to be_within(tol).of(exp_egy - exp_loss)      
      expect(klass.calc(ctx1)).to be_within(tol).of(klass.energy_net(ctx1))
      expect(klass.env_gross(ctx1)).to be >= 0.0  
      expect(klass.overlap_loss(ctx1)).to be >= 0.0  
      expect(klass.energy_net(ctx1)).to be >= 0.0  
    end

    it "many lifeforms with overlap" do
      lf0 = add_lf(0.0, 0.0, 2.0, 20.0)
      lf1 = add_lf(1.0, 0.0, 2.0, 20.0)
      lf2 = add_lf(0.5, 0.5, 2.0, 20.0)
      lf3 = add_lf(0.6, 0.6, 2.0, 20.0)
      lf4 = add_lf(0.4, 0.4, 2.0, 20.0)
    
      exp_egy = Math::PI * env_energy_rate

      [lf0, lf1, lf2, lf3, lf4].each do |lf|
        ctx = lf.context
        expect(klass.env_gross(ctx)).to be_within(tol).of(exp_egy)
        expect(klass.overlap_loss(ctx)).to be >= 0.0  
        expect(klass.energy_net(ctx)).to be_within(tol).of(0.0)
        expect(klass.calc(ctx)).to be_within(tol).of(klass.energy_net(ctx))

      end
    end
  end
end