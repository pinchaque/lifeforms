

class TestOutputter
  attr_accessor :str
  def initialize
    @str = ''
  end

  def <<(s)
    @str += s
  end
end

describe "TestOuputter" do
  it "Appends" do
    t = TestOutputter.new
    expect(t.str).to eq("")
    t << "foo"
    expect(t.str).to eq("foo")
    t << "bar 123 $$$$"
    expect(t.str).to eq("foobar 123 $$$$")
  end
end


describe "Logger" do
  let(:tout) { TestOutputter.new }
  let(:level) { Logger::INFO }
  let(:logger) { Logger.new(level, tout) }
  let(:time_re) { '\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}' }

  context ".fmt_time" do
    it "formats time as YYYY-MM-DD HH:mm:ss" do
      expect(logger.fmt_time).to match /^#{time_re}$/
    end
  end

  context ".fmt_context" do
    it "formats empty context" do
      ctx = {}
      exp = ""
      expect(logger.fmt_context(ctx)).to eq(exp)
    end

    it "formats single context" do
      ctx = {foo: "bar"}
      exp = "foo:bar"
      expect(logger.fmt_context(ctx)).to eq(exp)
    end

    it "formats single context" do
      ctx = {foo: "bar", quack: "duck 123", moo: ""}
      exp = "foo:bar, moo:, quack:duck 123"
      expect(logger.fmt_context(ctx)).to eq(exp)
    end
  end

  context ".log_str" do
    let(:msg) { 'this is the log message' }

    it "formats log message without context" do
      ctx = {}
      act = logger.log_str(msg, ctx)
      exp = /^\[#{time_re}\] #{msg}$/
      expect(act).to match exp
    end

    it "formats log message with context" do
      ctx = {foo: "bar", quack: "duck 123", moo: ""}
      act = logger.log_str(msg, ctx)
      exp = /^\[#{time_re}\] #{msg} \[#{logger.fmt_context(ctx)}\]$/
      expect(act).to match exp
    end
  end

  context ".log" do
    let(:msg) { 'the message' }
    let(:ctx) { {} }

    context "logger set to INFO" do
      let(:level) { Logger::INFO }
      let(:exp) { /^\[#{time_re}\] #{msg}$/ }

      it "adds error message" do
        expect(tout.str).to eq("")
        logger.log(Logger::ERROR, msg)
        expect(tout.str).to match exp
      end

      it "adds warning message" do
        expect(tout.str).to eq("")
        logger.log(Logger::WARNING, msg)
        expect(tout.str).to match exp
      end

      it "adds info message" do
        expect(tout.str).to eq("")
        logger.log(Logger::INFO, msg)
        expect(tout.str).to match exp
      end

      it "ignores debug message" do
        expect(tout.str).to eq("")
        logger.log(Logger::DEBUG, msg)
        expect(tout.str).to eq("")
      end

      it "ignores trace message" do
        expect(tout.str).to eq("")
        logger.log(Logger::TRACE, msg)
        expect(tout.str).to eq("")
      end
    end

    context "logger set to DEBUG, with context" do
      let(:level) { Logger::DEBUG }
      let(:ctx) { { foo: "bar" } }
      let(:exp) { /^\[#{time_re}\] #{msg} \[foo:bar\]$/ }

      it "adds error message" do
        expect(tout.str).to eq("")
        logger.error(msg, ctx)
        expect(tout.str).to match exp
      end

      it "adds warning message" do
        expect(tout.str).to eq("")
        logger.warning(msg, ctx)
        expect(tout.str).to match exp
      end

      it "adds info message" do
        expect(tout.str).to eq("")
        logger.info(msg, ctx)
        expect(tout.str).to match exp
      end

      it "ignores debug message" do
        expect(tout.str).to eq("")
        logger.debug(msg, ctx)
        expect(tout.str).to match exp
      end

      it "ignores trace message" do
        expect(tout.str).to eq("")
        logger.trace(msg, ctx)
        expect(tout.str).to eq("")
      end
    end
  end
end