class MoviesController < ApplicationController
  before_action :set_movie, only: %i[show edit update destroy]

  # GET /movies
  def index
    @all_ratings = Movie.all_ratings

    # Was the Refresh button used (explicit submit)?
    submitted = params[:commit].present?

    # Decide ratings to show:
    # - If ratings were sent, use them.
    # - If user clicked Refresh with none checked, treat as "show all".
    # - Else fall back to session or default.
    ratings =
      if params[:ratings].present?
        params[:ratings].is_a?(Hash) ? params[:ratings].keys : Array(params[:ratings])
      elsif submitted
        @all_ratings
      else
        session[:ratings] || @all_ratings
      end

    # Decide sorting:
    sort_by =
      if params[:sort_by].present?
        params[:sort_by]
      else
        session[:sort_by]
      end

    # If user just landed here without params but we have session state,
    # redirect to the canonical RESTful URL that includes the params.
    redirect_needed =
      !submitted && (
        (params[:ratings].blank? && session[:ratings].present?) ||
        (params[:sort_by].blank?  && session[:sort_by].present?)
      )

    if redirect_needed
      redirect_to movies_path(
        ratings: ratings.to_h { |r| [r, '1'] },
        sort_by: sort_by
      ) and return
    end

    # Persist current choices into session
    session[:ratings] = ratings
    session[:sort_by] = sort_by

    # Expose to view
    @ratings_to_show = ratings
    @sort_by = %w[title release_date].include?(sort_by) ? sort_by : nil

    # Query
    @movies = Movie.with_ratings(@ratings_to_show)
    @movies = @movies.order(@sort_by => :asc) if @sort_by.present?
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
