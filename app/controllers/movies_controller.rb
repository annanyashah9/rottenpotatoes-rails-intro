class MoviesController < ApplicationController
  before_action :set_movie, only: %i[show edit update destroy]

  # GET /movies
  def index
    @all_ratings = Movie.all_ratings

    # ---- ratings_to_show (array of strings) ----
    if params[:ratings].present?
      @ratings_to_show =
        if params[:ratings].respond_to?(:keys)
          params[:ratings].keys
        else
          Array(params[:ratings]).map(&:to_s)
        end
      session[:ratings] = @ratings_to_show
    elsif session[:ratings].present?
      @ratings_to_show = Array(session[:ratings]).map(&:to_s)
    else
      @ratings_to_show = @all_ratings
    end

    # ---- sort_by (string) ----
    if params[:sort_by].present?
      @sort_by = params[:sort_by]
      session[:sort_by] = @sort_by
    elsif session[:sort_by].present?
      @sort_by = session[:sort_by]
    else
      @sort_by = nil
    end

    # ---- canonical redirect: if params missing but we have session, redirect to RESTful URL ----
    must_redirect = false
    redirect_params = {}

    if params[:ratings].blank? && session[:ratings].present?
      redirect_params[:ratings] = session[:ratings].index_with { '1' } # {"G"=>"1", ...}
      must_redirect = true
    end
    if params[:sort_by].blank? && session[:sort_by].present?
      redirect_params[:sort_by] = session[:sort_by]
      must_redirect = true
    end

    if must_redirect
      return redirect_to movies_path(redirect_params)
    end

    # ---- fetch records ----
    @movies = Movie.with_ratings(@ratings_to_show)
    if %w[title release_date].include?(@sort_by)
      @movies = @movies.order(@sort_by => :asc)
    end
  end

  def show; end
  def new;  @movie = Movie.new; end
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