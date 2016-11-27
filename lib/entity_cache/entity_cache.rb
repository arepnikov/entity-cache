class EntityCache
  Error = Class.new(RuntimeError)

  include Log::Dependency

  configure :cache

  attr_accessor :persist_interval

  dependency :clock, Clock::UTC
  dependency :persistent_store, Storage::Persistent
  dependency :temporary_store, Storage::Temporary

  def self.build(subject, persistent_store: nil, persist_interval: nil, session: nil)
    unless persistent_store.nil? == persist_interval.nil?
      raise Error, "Must specify both the persistent store and persist interval, or neither"
    end

    persistent_store ||= Defaults.persistent_store

    instance = new
    instance.persist_interval = persist_interval

    Clock::UTC.configure instance
    Storage::Temporary.configure instance, subject

    persistent_store.configure(instance, subject, session: session)

    instance
  end

  def get(id)
    logger.trace { "Reading cache (ID: #{id.inspect})" }

    record = temporary_store.get id
    record ||= restore id

    if record.nil?
      logger.info { "Cache miss (ID: #{id.inspect})" }
      return nil
    end

    logger.info { "Cache hit (ID: #{id.inspect}, Entity Class: #{record.entity.class.name}, Version: #{record.version.inspect}, Time: #{record.time})" }

    record
  end

  def put(id, entity, version, persisted_version=nil, persisted_time=nil, time: nil)
    time ||= clock.iso8601(precision: 5)

    logger.trace { "Writing cache (ID: #{id}, Entity Class: #{entity.class.name}, Version: #{version.inspect}, Time: #{time}, Persistent Version: #{persisted_version.inspect}, Persistent Time: #{persisted_time.inspect})" }

    record = Record.new id, entity, version, time, persisted_version, persisted_time

    put_record record

    logger.info { "Cache written (ID: #{id}, Entity Class: #{record.entity.class.name}, Version: #{record.version.inspect}, Time: #{record.time}, Persistent Version: #{persisted_version.inspect}, Persistent Time: #{persisted_time.inspect})" }

    record
  end

  def put_record(record)
    if persist_interval && record.versions_since_persisted >= persist_interval
      persisted_time = clock.iso8601(precision: 5)

      persistent_store.put record.id, record.entity, record.version, persisted_time

      record.persisted_version = record.version
      record.persisted_time = persisted_time
    end

    temporary_store.put record
  end

  def restore(id)
    entity, persisted_version, persisted_time = persistent_store.get id

    return nil if entity.nil?

    version = persisted_version
    time = persisted_time

    put id, entity, version, persisted_version, persisted_time, time: time
  end
end
