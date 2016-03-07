# Top-level class for all DB records
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
