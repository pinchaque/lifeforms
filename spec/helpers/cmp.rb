# Compares two hashes with arbitary keys and numeric values
def cmp_hash_vals(act, exp, tol)
    expect(act.keys.sort).to eq(exp.keys.sort)
    expect(act.values.sum).to be_within(tol).of(exp.values.sum)
    act.each do |k, v|
      expect(v).to be_within(tol).of(exp[k])
    end
    # TODO it would be really helpful if this printed out the details of which
    # key didn't match
end

def cmp_objects(act, exp)
  expect(act.count).to eq(exp.count)
  act_ids = act.map { |o| o.id }.sort
  exp_ids = exp.map { |o| o.id }.sort
  expect(act_ids).to eq(exp_ids)
end