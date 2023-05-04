defmodule UpLearn.CrawlerTest do
  use ExUnit.Case, async: true
  import Mock

  alias UpLearn.Crawler

  @finch_request %Finch.Request{
    scheme: :https,
    host: "elixir-lang.org",
    port: 443,
    method: "GET",
    path: "/",
    headers: [],
    body: nil,
    query: nil,
    unix_socket: nil,
    private: %{}
  }

  @successfull_finch_response %Finch.Response{
    status: 200,
    body: File.read!("test/support/elixir.html"),
    headers: [
      {"connection", "keep-alive"},
      {"content-length", "25044"},
      {"server", "GitHub.com"},
      {"content-type", "text/html; charset=utf-8"},
      {"last-modified", "Wed, 26 Apr 2023 10:42:30 GMT"},
      {"access-control-allow-origin", "*"},
      {"etag", "\"64490016-61d4\""},
      {"expires", "Thu, 04 May 2023 12:46:58 GMT"},
      {"cache-control", "max-age=600"},
      {"x-proxy-cache", "MISS"},
      {"x-github-request-id", "E0B4:3E22:4A1483:4C998A:6453A6EA"},
      {"accept-ranges", "bytes"},
      {"date", "Thu, 04 May 2023 13:17:35 GMT"},
      {"via", "1.1 varnish"},
      {"age", "0"},
      {"x-served-by", "cache-vie6356-VIE"},
      {"x-cache", "HIT"},
      {"x-cache-hits", "1"},
      {"x-timer", "S1683206255.483487,VS0,VE105"},
      {"vary", "Accept-Encoding"},
      {"x-fastly-request-id", "4eebcb2c27fa8be5a17ad91c2814a69df10ac0dd"}
    ]
  }

  describe "fetch/1" do
    test_with_mock "successfully fetches website data", Finch,
      build: fn :get, "https://elixir-lang.org/" -> @finch_request end,
      request: fn _, _ -> {:ok, @successfull_finch_response} end do
      {:ok, website} = Crawler.fetch("https://elixir-lang.org/")

      assert website.url == "https://elixir-lang.org/"

      assert website.assets == [
               "/images/logo/logo.png",
               "/images/logo/eef.png"
             ]

      assert website.links == [
               "/",
               "/",
               "/install.html",
               "/learning.html",
               "/docs.html",
               "/getting-started/introduction.html",
               "/cases.html",
               "/blog/",
               "/getting-started/introduction.html",
               "/learning.html",
               "/cases.html",
               "/blog/2023/03/09/embedded-and-cloud-elixir-at-sparkmeter/",
               "/blog/2021/11/10/embracing-open-data-with-elixir-at-the-ministry-of-ecological-transition-in-france/",
               "/blog/2021/07/29/bootstraping-a-multiplayer-server-with-elixir-at-x-plane/",
               "/blog/2021/06/02/social-virtual-spaces-with-elixir-at-mozilla/",
               "/blog/2021/04/02/marketing-and-sales-intelligence-with-elixir-at-pepsico/",
               "/blog/2021/02/03/social-messaging-with-elixir-at-community/",
               "/blog/2021/01/13/orchestrating-computer-vision-with-elixir-at-v7/",
               "/blog/2020/12/10/integrating-travel-with-elixir-at-duffel/",
               "/blog/2020/11/17/real-time-collaboration-with-elixir-at-slab/",
               "/blog/2020/10/27/delivering-social-change-with-elixir-at-change.org/",
               "/blog/2020/10/08/real-time-communication-at-scale-with-elixir-at-discord/",
               "/blog/2020/09/24/paas-with-elixir-at-Heroku/",
               "/blog/2020/08/20/embedded-elixir-at-farmbot/",
               "https://github.com/elixir-nx/",
               "https://www.nerves-project.org/",
               "https://hexdocs.pm/ex_unit/",
               "https://github.com/elixir-ecto/ecto",
               "https://github.com/elixir-nx/nx",
               "https://hexdocs.pm/mix/",
               "https://hex.pm/",
               "https://hexdocs.pm/",
               "https://hexdocs.pm/iex/",
               "https://livebook.dev/",
               "https://www.whatsapp.com",
               "https://klarna.com",
               "/getting-started/introduction.html",
               "/docs.html",
               "/crash-course.html",
               "/blog/2022/09/01/elixir-v1-14-0-released/",
               "/development.html",
               "https://github.com/elixir-lang/elixir",
               "https://cult.honeypot.io/originals/elixir-the-documentary",
               "https://hex.pm",
               "https://twitter.com/elixirlang",
               "irc://irc.libera.chat/elixir",
               "http://elixirforum.com",
               "https://elixir-lang.slack.com/",
               "https://discord.gg/elixir",
               "https://www.meetup.com/topics/elixir/",
               "https://github.com/elixir-lang/elixir/wiki",
               "https://erlef.org/",
               "/trademarks"
             ]
    end

    test_with_mock "fails to fetch website data when 404", Finch,
      build: fn :get, "https://elixir-lang.org/page_not_exists" -> @finch_request end,
      request: fn _, _ -> {:ok, %{@successfull_finch_response | status: 404}} end do
      assert {:error, :invalid_status_code} =
               Crawler.fetch("https://elixir-lang.org/page_not_exists")
    end

    test_with_mock "fails when content header isn't supported", Finch,
      build: fn :get, "https://elixir-lang.org/" -> @finch_request end,
      request: fn _, _ ->
        {:ok,
         %{@successfull_finch_response | headers: [{"content-type", "unsupported content type"}]}}
      end do
      assert {:error, :unsupported_content_type} = Crawler.fetch("https://elixir-lang.org/")
    end

    test "fails when html page is malformed" do
      with_mocks [
        {Finch, [],
         [
           build: fn :get, "https://elixir-lang.org/" -> @finch_request end,
           request: fn _, _ ->
             {:ok, @successfull_finch_response}
           end
         ]},
        {Floki, [], parse_document: fn _ -> {:error, :malformed_html} end}
      ] do
        assert {:error, :malformed_html} = Crawler.fetch("https://elixir-lang.org/")
      end
    end
  end
end
