require_relative '../../../bench_init'

context "Exclusive scoped volatile storage" do
  id = Controls::ID.get
  entity = EntityCache::Controls::Entity.example
  version = EntityCache::Controls::Version.example

  store = EntityCache::Storage::Volatile::Scope::Exclusive.build :some_subject

  store.put id, entity, version

  test "Entities stored in one cache are not shared with other caches" do
    other_store = EntityCache::Storage::Volatile::Scope::Exclusive.build :some_subject

    cached_record = other_store.get id

    assert cached_record == nil
  end

  test "Different entities are stored separately according to their ID" do
    other_id = 'other-id'
    other_entity = EntityCache::Controls::Entity.example

    store.put other_id, other_entity, version

    assert store.get(id).entity == entity
    assert store.get(other_id).entity == other_entity
  end
end
