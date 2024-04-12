class EntityCache
  module Store
    class Internal
      include TemplateMethod
      include Log::Dependency

      attr_accessor :subject

      def self.build(subject)
        instance = new
        instance.subject = subject
        instance
      end

      def self.configure(receiver, subject, scope: nil, attr_name: nil)
        attr_name ||= :internal_store

        instance = Build.(subject, scope: scope)
        receiver.public_send("#{attr_name}=", instance)
        instance
      end

      template_method! :records

      def get(id)
        logger.trace { "Getting Entity (ID: #{id.inspect})" }

        record = records[id]

        logger.debug { "Get entity done (ID: #{id.inspect}, #{Record::LogText.get(record)})" }

        record
      end

      def put(record)
        id = record.id

        logger.trace { "Putting entity (ID: #{id.inspect}, #{Record::LogText.get(record)})" }

        records[id] = record

        logger.trace { "Put entity done (ID: #{id.inspect}, #{Record::LogText.get(record)})" }

        record
      end

      def delete(id)
        records.delete(id)
      end

      def count
        records.count
      end
      alias :length :count

      def empty?
        records.empty?
      end
    end
  end
end
