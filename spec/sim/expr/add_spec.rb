require File.dirname(__FILE__) + '/test_helper.rb'

describe "Expr::Add" do
  let(:tol) { 0.0001 }
  let(:ctx) { {} }

  context "Add" do
    it "20" do
      t_num(e_add(e_const(20.0)), 
        20.0, 
        "20.0",
        {c: "Add", v: [
          {c: "Const", v: 20},
        ]})
    end

    it "20 + 2 + 3.5" do
      t_num(e_add(e_const(20.0), e_const(2.0), e_const(3.5)), 
        25.5, 
        "(20.0 + 2.0 + 3.5)",
        {c: "Add", v: [
          {c: "Const", v: 20},
          {c: "Const", v: 2},
          {c: "Const", v: 3.5},
        ]})
    end
  end
end