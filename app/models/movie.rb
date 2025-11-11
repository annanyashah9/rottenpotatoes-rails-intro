class Movie < ApplicationRecord
  # All allowed ratings to show as checkboxes
  def self.all_ratings
    # Keep this in sync with your seeds/schema if needed
    %w[G PG PG-13 R NC-17]
  end

  # Return movies filtered by ratings_list (case-insensitive).
  # If ratings_list is nil/empty, return all movies.
  def self.with_ratings(ratings_list)
    return all if ratings_list.blank?

    # Case-insensitive match; ratings are short, this is fine.
    up = ratings_list.map(&:upcase)
    where('UPPER(rating) IN (?)', up)
  end
end
