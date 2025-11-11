class Movie < ApplicationRecord
  def self.all_ratings
    %w[G PG PG-13 R NC-17]
  end

  # Accepts an Array like ['G','PG'] OR a Hash/Parameters like {"G"=>"1","PG"=>"1"}.
  # Returns all movies if the input is blank.
  def self.with_ratings(ratings_list)
    return all if ratings_list.blank?

    list =
      if defined?(ActionController::Parameters) && ratings_list.is_a?(ActionController::Parameters)
        ratings_list.keys
      elsif ratings_list.respond_to?(:keys) && !ratings_list.is_a?(Array)
        ratings_list.keys
      else
        Array(ratings_list)
      end

    where(rating: list.map(&:to_s))
  end
end
