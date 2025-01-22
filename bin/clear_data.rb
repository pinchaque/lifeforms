#!/usr/bin/env ruby

require 'sequel'
require '../lib/config'

DB.transaction do
    log("Removing existing data...")

    n = LifeformLoc.where(true).delete
    log("Deleted #{n} rows from lifeform_locs")

    n = Lifeform.where(true).delete
    log("Deleted #{n} rows from lifeforms")

    n = Environment.where(true).delete
    log("Deleted #{n} rows from environments")
end