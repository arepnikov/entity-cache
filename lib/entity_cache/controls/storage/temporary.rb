class EntityCache
  module Controls
    module Storage
      module Temporary
        def self.example
          Example.new
        end

        class Example < EntityCache::Store::Temporary
          def records
            @records ||= {}
          end

          def put?(id, record=nil)
            if record.nil?
              records.key?(id)
            else
              records[id] == record
            end
          end
        end
      end
    end
  end
end
