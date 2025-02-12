# Compares two hashes with arbitary keys and numeric values
def cmp_hash_vals(act, exp, tol)
    expect(act.keys.sort).to eq(exp.keys.sort)
    expect(act.values.sum).to be_within(tol).of(exp.values.sum)
    act.each do |k, v|
        expect(v).to be_within(tol).of(exp[k])
    end
end