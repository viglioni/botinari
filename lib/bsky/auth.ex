defmodule Bsky.Auth do
  import TypeClass.Monad
  import TypeClass.Functor

  alias TypeClass.Either

  @create_session_url "https://bsky.social/xrpc/com.atproto.server.createSession"
  @headers ["Content-Type": "application/json"]

  @spec auth_headers() :: Either.t()
  def auth_headers() do
    access_token()
    |> fmap(&add_token_to_headers/1)
  end

  @spec add_token_to_headers(String.t()) :: {:Authorization, String.t()}
  defp add_token_to_headers(token), do: {:Authorization, "Bearer #{token}"}

  @spec access_token() :: Either.t()
  defp access_token() do
    create_session_req_body()
    ~>> (&create_session/1)
    ~>> (&get_jwt(&1))
  end

  @spec get_jwt(any()) :: Either.t()
  defp get_jwt(body) do
    body
    |> Jason.decode()
    |> Either.to_either()
    |> fmap(fn body -> body["accessJwt"] end)
    |> map_error("Failed to get jwt")
  end

  @spec create_session(map()) :: Either.t()
  defp create_session(body) do
    Http.post_body(@create_session_url, body, @headers)
  end

  @spec create_session_req_body() :: Either.t()
  defp create_session_req_body() do
    with {:right, token} <- Env.get("TOKEN"),
         {:right, did} <- Env.get("DID") do
      %{identifier: did, password: token}
      |> Json.encode()
    end
  end
end
