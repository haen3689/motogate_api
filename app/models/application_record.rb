require "zlib"

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Serialises a read-then-write section across concurrent connections.
  #
  # Several places generate a human-readable running number (insurance
  # certificates, service-centre contracts) by reading the current maximum and
  # adding one, against a column that carries a unique index. Two requests —
  # or, for payment finalisation, the live PubNub callback and the reconcile
  # callback, which run on separate pubnub-owned threads — can read the same
  # maximum and collide.
  #
  # pg_advisory_xact_lock is held for the remainder of the surrounding
  # transaction and released on commit or rollback, so there is nothing to
  # unlock and no way to leak it. Called outside a transaction it degrades to
  # a no-op lock, which is no worse than not locking at all.
  def self.with_advisory_lock_on(name)
    return unless connection.adapter_name.to_s.downcase.include?("postgresql")

    # Signed 64-bit key derived from the name; CRC32 keeps it well inside range.
    key = Zlib.crc32(name.to_s)
    connection.execute("SELECT pg_advisory_xact_lock(#{key})")
  end
end
