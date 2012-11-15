require 'sunspot'
require 'sunspot/rails'

module Sunspot
  module Mongo
    def self.included(base)
      base.class_eval do
        extend Sunspot::Rails::Searchable::ActsAsMethods
        extend Sunspot::Mongo::Finders
        Sunspot::Adapters::DataAccessor.register(DataAccessor, base)
        Sunspot::Adapters::InstanceAdapter.register(InstanceAdapter, base)
      end
    end

    module Finders
      def sunspot_find(id)
        find(id)
      end

      def sunspot_find_all(ids)
        find(ids)
      end
    end

    class InstanceAdapter < Sunspot::Adapters::InstanceAdapter
      def id
        @instance.id
      end
    end

    class DataAccessor < Sunspot::Adapters::DataAccessor
      def load(id)
        @clazz.sunspot_find(id)
      end

      def load_all(ids)
        @clazz.sunspot_find_all(ids)
      end
    end
  end
end
