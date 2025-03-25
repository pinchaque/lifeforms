describe "Scribe::Formatter" do

  let(:fmt) { Scribe::Formatter.new }
  let(:time) { DateTime.new(2024, 2, 3, 4, 5, 6) }
  let(:time_exp) { "2024-02-03 04:05:06" }
  let(:level) { Scribe::Level::INFO }
  let(:ctx) { {} }
  let(:str) { 'test log messsage' }
  let(:msg) { 
    m = Scribe::Msg.new(level, str, **ctx)
    m.time = time
    m
  }

  context ".fmt_time" do
    it "formats time" do
      expect(fmt.fmt_time(time)).to eq(time_exp)
    end
  end
  
  context ".fmt_context" do
    it "formats empty context" do
      ctx = {}
      exp = ""
      expect(fmt.fmt_context(ctx)).to eq(exp)
    end

    it "formats single context" do
      ctx = {foo: "bar"}
      exp = "foo:bar"
      expect(fmt.fmt_context(ctx)).to eq(exp)
    end

    it "formats single context" do
      ctx = {foo: "bar", quack: "duck 123", moo: ""}
      exp = "foo:bar, moo:, quack:duck 123"
      expect(fmt.fmt_context(ctx)).to eq(exp)
    end
  end

  context ".format" do
    def t(msg, exp)
      expect(fmt.format(msg)).to eq(exp)
    end

    context "without context" do
      let(:ctx) { {} }
      it "formats log message" do
        t(msg, "[#{time_exp}] #{str}")
      end
    end

    context "with context" do
      let(:ctx) { {foo: "bar", quack: "duck 123", moo: ""} }
      it "formats log message" do
        ctx_exp = fmt.fmt_context(ctx)
        t(msg, "[#{time_exp}] #{str} [#{ctx_exp}]")
      end
    end
  end
end