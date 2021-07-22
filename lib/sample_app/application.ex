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

  defp send_message(channel, counter \\ 1) do
    # every N requests we simulate an error
    name =
      if rem(counter, 5) == 0 do
        "fail_test" # server returns "not found" when receiving this
      else
        "rafa"
      end

    params = %GrpcPoc.HelloRequest{name: name}
    reply = GrpcPoc.HelloService.Stub.hello(channel, params)
    IO.inspect(reply, label: "reply")
    :timer.sleep(1000)
    send_message(channel, counter + 1)
  end
end
