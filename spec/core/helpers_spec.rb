describe "Helpers" do  
  let(:tol) { 0.000001 }
  context "perc" do
    it "handles negative numbers" do
      [-0.000001, -0.001, -0.1, -1.0001, -1.1, -2.0, -100, -10000.0].each do |p|
        expect(perc(p)).to be_within(tol).of(0.0)
      end 
    end

    it "handles numbers > 1.0" do
      [1.0001, 1.1, 2.0, 100, 10000.0, 100000.0].each do |p|
        expect(perc(p)).to be_within(tol).of(1.0)  
      end
    end

    it "handles numbers in 0.0 .. 1.0" do
      [0.0, 0.0001, 0.1, 0.3, 0.8, 0.9, 0.99999, 0.9999999, 1.0].each do |p|
        expect(perc(p)).to be_within(tol).of(p)  
      end
    end
  end

  context "camel_to_snake" do
    def t(s, exp)
      expect(camel_to_snake(s)).to eq(exp)
    end

    it "converts as expected" do
      t("CamelCase", "camel_case")
      t("FooBarQuux", "foo_bar_quux")
      t("FooBarQQuux", "foo_bar_q_quux")
      t("Foo123Bar456", "foo123_bar456")
      t("Skill::Base", "skill_base")
    end
  end

  context "class_from_name" do
    class Bar
      def self.print
        "bare class"
      end  
    end

    module Foo
      class Bar
        def self.print
          "nested class"
        end  
      end

      class Quux
        class Bar
          def self.print
            "double nested class"
          end  
        end
      end
    end

    it "handles bare class" do
      klass = class_from_name("Bar")
      expect(klass.name).to eq("Bar")
      expect(klass.print).to eq("bare class")
    end

    it "handles nested class" do
      klass = class_from_name("Foo::Bar")
      expect(klass.name).to eq("Foo::Bar")
      expect(klass.print).to eq("nested class")
    end

    it "handles double-nested class" do
      klass = class_from_name("Foo::Quux::Bar")
      expect(klass.name).to eq("Foo::Quux::Bar")
      expect(klass.print).to eq("double nested class")
    end
  end

  context "is_numeric?" do
    [
      [1, true],
      [1.234, true],
      [-1.234, true],
      [nil, false],
      ["", false],
      ["foobar", false],
      ["123.0badbad", false],
      ["123", true],
      [5.808185577559548e+114-0.015059394552572046i, false],
    ].each do |ex|
      it "is_numeric?(#{ex[0]})" do
        expect(is_numeric?(ex[0])).to be ex[1]
      end
    end
  end
end