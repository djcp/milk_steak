class ErrorsController < ApplicationController
  layout 'errors'

  ERROR_PAGE_COPY = {
    400 => ['Bad request', 'The request could not be processed due to a client error.'],
    404 => ['Page not found',
            'The page you were looking for does not exist. It may have been moved, or the address may be mistyped.'],
    406 => ['Browser not supported',
            'Your browser is not supported. Please try a current version of Chrome, Firefox, Safari, or Edge.'],
    422 => ["That change didn't go through",
            'The request was understood, but the change you asked for could not be processed.'],
    500 => ['Something went wrong', 'An unexpected error occurred. Please try again in a moment.']
  }.freeze

  def show
    status = request.path_info[1..].to_i
    @status = ERROR_PAGE_COPY.key?(status) ? status : 500
    @title, @message = ERROR_PAGE_COPY.fetch(@status)
    render status: @status
  end
end
