
# Helper class that just appends strings so we can test if outputter
# is getting called as expected.
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

# Mock formatter than just returns the string
class TestFormatter
  def format(msg)
    msg.msg
  end
end

describe "Scribe::Router" do
  let(:max_level) { Scribe::Level::INFO }
  let(:outputter) { TestOutputter.new }
  let(:router) { Scribe::Router.new(max_level, TestFormatter.new, outputter) }

  context ".initialize" do
    it "sets data members" do
      expect(router.max_level).to eq(max_level)
      expect(router.formatter.class).to eq(TestFormatter)
      expect(router.outputter.class).to eq(TestOutputter)
    end
  end

  context ".send" do
    let(:str) { "test message" }
    let(:level) { Scribe::Level::INFO }
    let(:msg) { Scribe::Message.new(level, str)}

    context "multiple messages" do
      it "sends to outputter" do
        router.send(msg)
        expect(outputter.str).to eq(str)
        router.send(msg)
        expect(outputter.str).to eq(str + str)
      end
    end

    context "debug message" do
      let(:level) { Scribe::Level::DEBUG }
      it "doesn't get output" do
        router.send(msg)
        expect(outputter.str).to eq("")         
      end
    end

    context "error message" do
      let(:level) { Scribe::Level::ERROR }
      it "gets output" do
        router.send(msg)
        expect(outputter.str).to eq(str)         
      end
    end
  end
end