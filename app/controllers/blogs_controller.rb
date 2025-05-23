# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show
    @blog = Blog.visible(current_user).find(params[:id])
  end

  def new
    @blog = Blog.new
  end

  def edit
    @blog = current_user.blogs.find(params[:id])
  end

  def create
    @blog = current_user.blogs.new(blog_params)
    @blog.random_eyecatch = false unless @blog.user.premium

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @blog = current_user.blogs.find(params[:id])
    permitted_params = blog_params
    permitted_params.delete(:random_eyecatch) unless @blog.user.premium

    if @blog.update(permitted_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog = current_user.blogs.find(params[:id])
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def blog_params
    params.require(:blog).permit(:title, :content, :secret, :random_eyecatch)
  end
end
