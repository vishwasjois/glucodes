# Defines Measurement.

# Represents an individual glucose measurement.
class Measurement < ActiveRecord::Base
  
  attr_accessible :at, :approximate_time, :value, :notes
  
  validates_presence_of :at, :value
  validates_uniqueness_of :at, :allow_blank => true
  validates_numericality_of :value, :greater_than => 0, :allow_blank => true
  validates_length_of :notes, :maximum => 255, :allow_blank => true
  
  before_save :set_adjusted_date_and_time_slot_and_skew
  
  default_scope :order => 'at DESC'
  
  def severity
    rounded_skew = skew.round(2)
    return nil       if (rounded_skew < 0.20)
    return :moderate if (0.20..0.40).include?(rounded_skew)
    :critical
  end
  
private
  
  def set_adjusted_date_and_time_slot_and_skew
    case self.at.hour
      when (0...5)
        self.time_slot = 'g'
        self.adjusted_date = at.yesterday.to_date
      when (5...8)
        self.time_slot = 'a'
        self.adjusted_date = at.to_date
      when (8...11)
        self.time_slot = 'b'
        self.adjusted_date = at.to_date
      when (11...14)
        self.time_slot = 'c'
        self.adjusted_date = at.to_date
      when (14...17)
        self.time_slot = 'd'
        self.adjusted_date = at.to_date
      when (17...20)
        self.time_slot = 'e'
        self.adjusted_date = at.to_date
      when (20...23)
        self.time_slot = 'f'
        self.adjusted_date = at.to_date
      else
        self.time_slot = 'g'
        self.adjusted_date = at.to_date
    end
    self.skew = 1.0 - ((value / 100.0) ** ((value <= 100.0) ? 1.0 : -1.0));
  end
  
end
