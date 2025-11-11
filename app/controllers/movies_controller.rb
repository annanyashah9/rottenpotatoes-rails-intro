def index
  # All possible ratings
  @all_ratings = Movie.all_ratings

  # Ratings selected (default = all)
  if params[:ratings].present?
    @ratings_to_show = params[:ratings].keys
  else
    @ratings_to_show = @all_ratings
  end

  # Sorting selected (default = nil)
  @sort_by = params[:sort_by]

  # Query the movies
  @movies = Movie.with_ratings(@ratings_to_show)

  # Apply sorting if provided
  @movies = @movies.order(@sort_by) if @sort_by.present?
end
