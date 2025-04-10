describe "Spawner" do
  let(:tol) { 0.0001 }
  let(:num_iter) { 200 }
  let(:env) { TestFactory.env }
  let(:species) { TestFactory.species }
  let(:p_spawn) { 0.5 }
  let(:min_lifeforms) { nil }
  let(:max_lifeforms) { nil }
  let(:spawn) { Spawner.new(
    environment_id: env.id, 
    species_id: species.id,
    p_spawn: p_spawn,
    min_lifeforms: min_lifeforms,
    max_lifeforms: max_lifeforms) }

  def add_lf(species_id:, **attrs)
    TestFactory.lifeform(environment_id: env.id, species_id: species_id, **attrs)
  end

  context ".count_species" do
    let(:species2) { TestFactory.species(name: "another species") }

    it "counts living lifeforms of this species only" do
      add_lf(species_id: species.id)
      add_lf(species_id: species.id)
      add_lf(species_id: species2.id)
      add_lf(species_id: species2.id, died_step: 1)
      add_lf(species_id: species.id, died_step: 1)
      expect(spawn.count_lifeforms).to eq(2)
    end
  end

  context ".run" do
    context "below min" do
      let(:min_lifeforms) { 5 }
      let(:max_lifeforms) { 100 }
      let(:p_spawn) { 1.0 }

      it "replenishes up to min but not more" do
        expect(spawn.count_lifeforms).to eq(0)
        expect(spawn.run).to eq(5)
        expect(spawn.count_lifeforms).to eq(5)
      end
    end

    context "above max" do
      let(:min_lifeforms) { 0 }
      let(:max_lifeforms) { 3 }
      let(:p_spawn) { 1.0 }
      
      it "won't generate above max" do
        expect(spawn.count_lifeforms).to eq(0)
        (1..max_lifeforms).each do |i|
          add_lf(species_id: species.id)
        end
        expect(spawn.count_lifeforms).to eq(3)
        expect(spawn.run).to eq(0)
        expect(spawn.count_lifeforms).to eq(3)
      end
    end

    context "p=0" do
      let(:p_spawn) { 0.0 }
      let(:min_lifeforms) { 0 }
      let(:max_lifeforms) { 3 }

      it "doesn't ever generate" do
        expect(spawn.count_lifeforms).to eq(0)
        add_lf(species_id: species.id)
        expect(spawn.count_lifeforms).to eq(1)

        (1..num_iter).each do |i|
          expect(spawn.run).to eq(0)
          expect(spawn.count_lifeforms).to eq(1)
        end     
      end
    end

    context "p=1" do
      let(:p_spawn) { 1.0 }
      let(:min_lifeforms) { 0 }
      let(:max_lifeforms) { nil }

      it "always generates (no max)" do
        expect(spawn.count_lifeforms).to eq(0)
        add_lf(species_id: species.id)
        expect(spawn.count_lifeforms).to eq(1)

        (1..num_iter).each do |i|
          expect(spawn.run).to eq(1)
          expect(spawn.count_lifeforms).to eq(1 + i)
        end     
      end
    end

    context "p=0.5" do
      let(:p_spawn) { 0.5 }

      it "sometimes generates" do
        expect(spawn.count_lifeforms).to eq(0)

        tot_gen = 0
        (1..num_iter).each do |i|
          n = spawn.run
          expect(n).to eq(0).or eq(1)
          tot_gen += n
          expect(spawn.count_lifeforms).to eq(tot_gen)
        end
        # given p = 0.5 we should havce gotten at least 1 but not all
        expect(tot_gen).to be > 0
        expect(tot_gen).to be < num_iter
      end
    end
  end
end