describe "Scribe::Msg" do
  let(:str) { 'test log messsage' }
  let(:ctx) { { foo: 2, bar: "quux" } }

  def t(msg, level_exp, str_exp, ctx_exp) 
    expect(msg.level).to eq(level_exp)
    expect(msg.msg).to eq(str_exp)
    expect(msg.context).to eq(ctx_exp)
  end

  context ".initialize" do
    it "creates object without context" do
      msg = Scribe::Msg.new(Scribe::Level::INFO, str)
      t(msg, Scribe::Level::INFO, str, {})
    end
    
    it "creates object with context" do
      msg = Scribe::Msg.new(Scribe::Level::INFO, str, **ctx)
      t(msg, Scribe::Level::INFO, str, ctx)
    end
  end

  context "constructor helpers" do
    it ".error" do
      msg = Scribe::Msg.error(str, **ctx)
      t(msg, Scribe::Level::ERROR, str, ctx)
    end

    it ".warning" do
      msg = Scribe::Msg.warning(str, **ctx)
      t(msg, Scribe::Level::WARNING, str, ctx)
    end

    it ".info" do
      msg = Scribe::Msg.info(str, **ctx)
      t(msg, Scribe::Level::INFO, str, ctx)
    end

    it ".debug" do
      msg = Scribe::Msg.debug(str, **ctx)
      t(msg, Scribe::Level::DEBUG, str, ctx)
    end

    it ".trace" do
      msg = Scribe::Msg.trace(str, **ctx)
      t(msg, Scribe::Level::TRACE, str, ctx)
    end
  end
end