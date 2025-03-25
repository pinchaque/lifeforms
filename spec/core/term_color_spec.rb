describe "TermColor" do

  let(:tc) { TermColor.new }

  def t(tc, exp_s)
    expect(tc.to_s).to eq(exp_s)
    #puts("The #{exp_s}quick brown fox#{"\033[0m"} jumped over the lazy dogs.")
  end

  context ".fg" do
    it "renders" do
      t(tc.fg(255, 128, 64), "\033[38;2;255;128;64m")
    end
  end

  context ".bg" do
    it "renders" do
      t(tc.bg(50, 60, 70), "\033[48;2;50;60;70m")
    end
  end

  context ".bold" do
    it "renders" do
      t(tc.bold, "\033[1m")
    end
  end

  context ".underline" do
    it "renders" do
      t(tc.underline, "\033[4m")
    end
  end

  context "predefined colors" do
    it "black" do
      t(tc.black, "\033[30m")
    end

    it "white" do
      t(tc.white, "\033[97m")
    end

    it "red" do
      t(tc.red, "\033[91m")
    end

    it "green" do
      t(tc.green, "\033[92m")
    end

    it "yellow" do
      t(tc.yellow, "\033[93m")
    end

    it "cyan" do
      t(tc.cyan, "\033[96m")
    end

    it "magenta" do
      t(tc.magenta, "\033[95m")
    end

    it "blue" do
      t(tc.blue, "\033[94m")
    end

    it "grey" do
      t(tc.grey, "\033[38;2;128;128;128m")
    end
  end

  context "chained commands" do
    it "colors + formatting" do
      t(tc.blue.bg(64, 64, 64).bold.underline, "\033[94;48;2;64;64;64;1;4m")
    end

    it "duplicate foreground" do
      t(tc.blue.red, "\033[94;91m")      
    end

    it "reset in the middle" do
      t(tc.blue.bold.reset.red.underline, "\033[0;91;4m")      
    end
  end

  context ".reset" do
    it "renders" do
      t(tc.reset, "\033[0m")
    end
  end
end