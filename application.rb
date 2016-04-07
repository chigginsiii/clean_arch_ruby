# not really much of a need for a Request superclass...

#
# this lets us set up callbacks that get called inside the
# use-case:
#
class UseCaseResponse
  # dsl to set up callbacks:
  def self.respond
    response = new
    yield response
    response
  end

  # set failure callback
  def on_failure(&block)
    @failure = block
  end

  # set success callback
  def on_success(&block)
    @success = block
  end

  # call the failure with the exception or error msg
  def failure(e)
    @failure.call(e)
  end

  # call the success callback with an optional arg
  def success(result)
    @success.call(result)
  end
end

#
# Not much to the UseCase superclass either...
#
class UseCase
  attr_accessor :request, :response

  def initialize(request:, response:)
    @request = request
    @response = response
  end

  def perform
    fail "Must subclass!"
  end
end

#
# ...here we go...
#
class PayEmployeeRequest
  attr_reader :employee_id
  def initialize(employee_id:)
    @employee_id = employee_id
  end
end

# this doesn't have to be subclassed, but to make the point:
class PayEmployeeResponse < UseCaseResponse
end

#
# super simple use case...
# 
class PayEmployee < UseCase
  def perform
    if request.employee_id.to_i < 3
      response.success "paid employee #{request.employee_id}"
    else
      raise "Illegal employee number!"
    end
  rescue => e
    response.failure e
  end
end

#
# and here it is called from the web framework:
#
require 'sinatra'
require 'json'


set :port, 5678
get '/pay/:employee_id' do

  #
  # set up the request...
  #
  request = PayEmployeeRequest.new(employee_id: params[:employee_id])
  
  #
  # This is the key part: the use-case is dependent on response's #success/#failure,
  #   but the implementation is a detail. So if we use the use case from
  #   a rake task or from inside another use-case, we'd set up the 
  #   success/failure callbacks for that delivery-method. This is web, so
  #   we return json and statuses.
  #
  response = PayEmployeeResponse.respond do |r|
    r.on_success { |msg| { success: msg }.to_json }
    r.on_failure { |e| halt 404, { failure: "could not find #{params[:employee_id]}: #{e}"}.to_json }
  end

  #
  # and then this fires the use-case itself
  #
  PayEmployee.new(request: request, response: response).perform

  #
  # Look ma! No application logic in the controller!
  #
end
