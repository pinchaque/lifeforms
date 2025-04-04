# Compares two hashes with arbitary keys and a mix of value types. If the 
# expected values are numeric then they are compared with a tolerance
# to allow for small floating point differences.
def cmp_hash(act, exp, tol = 0.00001)
  expect(act).to satisfy("have the keys #{exp.keys.sort}") do |act_keys|
    act.keys.all? { |k| exp.key?(k) } &&
    exp.keys.all? { |k| act.key?(k) }
  end

  act.each do |k, v_act|
    v_exp = exp[k]

    if is_numeric?(v_exp)
      s = sprintf("be within %f of #{v_exp}", tol)
      expect("actual[#{k}] = #{v_act}").to satisfy(s) do |str|
        (v_exp - v_act).abs <= tol
      end
    else
      expect("actual[#{k}] = #{v_act}").to satisfy("be #{v_exp}") do |str|
        v_act == v_exp
      end
    end
  end
end

# Compares two lists of objects with IDs.
def cmp_objects(act, exp)
  expect(act.count).to eq(exp.count)
  act_ids = act.map { |o| o.id }.sort
  exp_ids = exp.map { |o| o.id }.sort
  expect(act_ids).to eq(exp_ids)
end