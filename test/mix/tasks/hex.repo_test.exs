defmodule Mix.Tasks.Hex.RepoTest do
  use HexTest.Case

  @public_key """
  -----BEGIN PUBLIC KEY-----
  MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApqREcFDt5vV21JVe2QNB
  Edvzk6w36aNFhVGWN5toNJRjRJ6m4hIuG4KaXtDWVLjnvct6MYMfqhC79HAGwyF+
  IqR6Q6a5bbFSsImgBJwz1oadoVKD6ZNetAuCIK84cjMrEFRkELtEIPNHblCzUkkM
  3rS9+DPlnfG8hBvGi6tvQIuZmXGCxF/73hU0/MyGhbmEjIKRtG6b0sJYKelRLTPW
  XgK7s5pESgiwf2YC/2MGDXjAJfpfCd0RpLdvd4eRiXtVlE9qO9bND94E7PgQ/xqZ
  J1i2xWFndWa6nfFnRxZmCStCOZWYYPlaxr+FZceFbpMwzTNs4g3d4tLNUcbKAIH4
  0wIDAQAB
  -----END PUBLIC KEY-----
  """

  test "add" do
    in_tmp fn ->
      Hex.State.put(:home, System.cwd!)

      File.write!("public_key.pem", @public_key)
      Mix.Tasks.Hex.Repo.run(["add", "reponame", "url", "public_key.pem"])
      assert ["$repos": %{"reponame" => %{auth_key: nil, public_key: "-----BEGIN PUBLIC KEY" <> _, url: "url"}}] =
             Hex.Config.read

      File.write!("foo.pem", "INVALID PUBLIC KEY")
      assert_raise Mix.Error, fn ->
        Mix.Tasks.Hex.Repo.run(["add", "reponame", "url", "foo.pem"])
      end
    end
  end

  test "remove" do
    in_tmp fn ->
      Hex.State.put(:home, System.cwd!)

      Mix.Tasks.Hex.Repo.run(["add", "reponame", "url"])
      Mix.Tasks.Hex.Repo.run(["remove", "reponame"])
      assert ["$repos": %{}] = Hex.Config.read
    end
  end

  test "set" do
    in_tmp fn ->
      Hex.State.put(:home, System.cwd!)

      Mix.Tasks.Hex.Repo.run(["add", "reponame", "url"])
      Mix.Tasks.Hex.Repo.run(["set", "url", "reponame", "other_url"])
      assert ["$repos": %{"reponame" => %{url: "other_url"}}] = Hex.Config.read
    end
  end
end
