defmodule SampleApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = []

    {:ok, channel} = GRPC.Stub.connect("localhost:50051")
    send_message(channel)

    # # See https://hexdocs.pm/elixir/Supervisor.html
    # # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SampleApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp send_message(channel) do
    params = %GrpcPoc.HelloRequest{name: "Rafa"}
    {:ok, reply} = GrpcPoc.HelloService.Stub.hello(channel, params)
    IO.inspect(reply, label: "reply")
    :timer.sleep(1000)
    send_message(channel)
  end
end
