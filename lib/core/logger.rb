
def log(s)
    d = DateTime.now.strftime("%F %T")
    puts "[#{d}] #{s}"
end


def logf(*args)
    log(sprintf(*args))
end