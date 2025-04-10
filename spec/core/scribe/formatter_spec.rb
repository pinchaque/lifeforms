describe "Scribe::Formatter" do

  let(:colorize) { false }
  let(:fmt) { Scribe::Formatter.new(colorize) }
  let(:time) { DateTime.new(2024, 2, 3, 4, 5, 6) }
  let(:time_exp) { "2024-02-03 04:05:06" }
  let(:level) { Scribe::Level::INFO }
  let(:ctx) { {} }
  let(:str) { 'test log messsage' }
  let(:msg) { 
    m = Scribe::Message.new(level, str, **ctx)
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
      exp = "foo:bar, quack:duck 123, moo:"
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
        t(msg, "[#{time_exp}] INFO #{str}\n")
      end
    end

    context "with context" do
      let(:ctx) { {foo: "bar", quack: "duck 123", moo: ""} }
      it "formats log message" do
        ctx_exp = fmt.fmt_context(ctx)
        t(msg, "[#{time_exp}] INFO #{str} [#{ctx_exp}]\n")
      end
    end
  end

  context ".extract_id" do
    let(:ctx) { {foo: "bar", quack: "duck 123", moo: ""} }
    let(:env) { TestFactory.env }
    let(:lf) { TestFactory.lifeform(environment_id: env.id) }
    let(:objs) { {
      env: Environment,
      lf: Lifeform
    }}
    let(:fmt) { 
      f = Scribe::Formatter.new(colorize) 
      f.objs = objs
      f
    }

    it "nothing to extract" do
      id, ret = fmt.extract_id(ctx)
      expect(id).to be_nil
      expect(ret).to eq(ctx)
    end

    it "lifeform id only" do
      ctx2 = ctx.merge({lf: lf})
      id, ret = fmt.extract_id(ctx2)
      expect(id).to eq(fmt.obj_name(lf))
      expect(ret).to eq(ctx)
    end

    it "env id only" do
      ctx2 = ctx.merge({env: env})
      id, ret = fmt.extract_id(ctx2)
      expect(id).to eq(fmt.obj_name(env))
      expect(ret).to eq(ctx)      
    end

    it "multiple ids" do
      ctx2 = ctx.merge({lf: lf, env: env})
      id, ret = fmt.extract_id(ctx2)

      id_exp = fmt.obj_name(env) + " > " + fmt.obj_name(lf)

      expect(id).to eq(id_exp)
      expect(ret).to eq(ctx)
    end
  end
end