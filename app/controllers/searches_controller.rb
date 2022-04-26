class SearchesController < ApplicationController
  before_action :authenticate_user!
  def search
    @range = params[:range]
    @search = params[:search]
    @word = params[:word]
    
    if @range == 'User'
      @records = User.looks(@search, @word)
    else
      @records = Book.looks(@search, @word)
    end
  end
end
