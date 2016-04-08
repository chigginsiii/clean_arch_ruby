# clean_arch_ruby

example of use-case architecture with Ruby and Sinatra. It doesn't go all the way to defining entities and repositories, but it demonstrates the basic idea of encapsulating application logic and making sure all the dependencies point in the same direction.

## UseCase, Request, Response

The request is just data coming into the use-case, and the use-case depends on it. There's not much of a reason for a superclass, it's just the incoming data the use-case expects.

The response provides a small DSL to set up success/failure callbacks from the delivery framework (eq: web, rake task).

The use-case gets input from the request, defines `#perform` which does the work, and returns the results through `#success(msg)` and `#failure(exception)`.

In `application.rb`:

* The `UseCase` and `UseCaseResponse` base classes define the common methods.
* `PayEmployee` subclasses UseCase, takes input from `PayEmployeeRequest` and defines `#perform` to do the work.
* `PayEmployeeRequest` doesn't implement any methods, it just holds on to the callback blocks, but it's there to demonstrate.
* in the Sinatra route, `PayEmployeeResponse` defines the success/failure callbacks. The controller is entirely concerned with adapting HTTP params to the Request, and adapting the response into json and HTTP status codes. All that's left is to run the use-case and perform the work.

## running it:

    > bundle
    > ruby application.rb

## testing it:

make requests to

    http://localhost:5678/pay/1
    http://localhost:5678/pay/6

