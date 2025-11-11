class MoviesController < ApplicationController
  before_action :set_movie, only: %i[show edit update destroy]

  # GET /movies
  def index
    # all possible ratings for the checkboxes
    @all_ratings = Movie.all_ratings

    # which ratings should be shown (default = all)
    @ratings_to_show =
      if params[:ratings].present?
        params[:ratings].keys
      else
        @all_ratings
      end

    # which column to sort by (optional)
    @sort_by = params[:sort_by].presence

    # base scope filtered by ratings
    @movies = Movie.with_ratings(@ratings_to_show)

    # apply sort if valid
    if %w[title release_date].include?(@sort_by)
      @movies = @movies.order(@sort_by => :asc)
    end
  end

  def show; end

  def new
    @movie = Movie.new
  end

  def edit; end

  def create
    @movie = Movie.new(movie_params)
    if @movie.save
      redirect_to @movie, notice: "Movie was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @movie.update(movie_params)
      redirect_to @movie, notice: "Movie was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @movie.destroy!
    redirect_to movies_path, status: :see_other, notice: "Movie was successfully destroyed."
  end

  private

  def set_movie
    @movie = Movie.find(params[:id])
  end

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
