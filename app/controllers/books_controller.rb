class BooksController < ApplicationController


  before_action :baria_user, only: [:edit, :update]

  def show
    @book = Book.find(params[:id])
    @newbook =Book.new
    @book_comment = BookComment.new
    impressionist(@book,nil)
  end

  def index
    @book = Book.new
    @rank_books = Book.order(impressions_count: "DESC") #アクセス数の多い順に並び替えるための記述
    if params[:sort_update]
      @books = Book.latest
    elsif params[:sort_star]
      @books = Book.star
    elsif params[:sort_impressions]
      @books = Book.impressions
    else
      to = Time.current.at_end_of_day
      from = (to - 6.day).at_beginning_of_day
      @books = Book.includes(:favorites_users).sort {|a,b|
      b.favorites_users.includes(:favorites).where(created_at: from...to).size <=>
      a.favorites_users.includes(:favorites).where(created_at: from...to).size
      }
    end
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    if @book.save
      redirect_to book_path(@book), notice: "You have created book successfully."
    else
      @books = Book.all
      render 'index'
    end
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to book_path(@book.id), notice: "You have updated book successfully."
    else
      render "edit"
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path
  end

  def search_book
    @books = Book.search(params[:keyword])
  end

  private

  def book_params
    params.require(:book).permit(:title, :body, :star, :category)
  end

  def baria_user
    unless Book.find(params[:id]).user.id == current_user.id
      redirect_to books_path
    end
  end
end
