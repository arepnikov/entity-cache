require_relative '../automated_init'

context "Build" do
  context "Internal Store" do
    subject = Controls::Subject.example

    context "No Scope" do
      entity_cache = nil

      default_scope_class = nil

      Fixtures::Environment.() do
        entity_cache = EntityCache.build(subject)

        default_scope_class = EntityCache::Store::Internal::Build.default_scope_class
      end

      internal_store = entity_cache.internal_store

      test "Default scope is selected" do
        assert(internal_store.instance_of?(default_scope_class))
      end

      test "Subject" do
        assert(internal_store.subject == subject)
      end
    end

    context "Scope" do
      entity_cache = Fixtures::Environment.() do
        EntityCache.build(subject, scope: :exclusive)
      end

      internal_store = entity_cache.internal_store

      test "Specified scope is chosen" do
        scope_class = EntityCache::Store::Internal::Scope::Exclusive

        assert(internal_store.instance_of?(scope_class))
      end

      test "Subject" do
        assert(internal_store.subject == subject)
      end
    end
  end
end
