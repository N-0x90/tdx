defmodule MSQL do
  def cmd(args) do
    params = [
      "-U",
      "sa", #params[:username],
      "-P",
      "sa!Passw0rd", #params[:password],
      "-S",
      "10.0.3.222", #params[:hostname],
      "-Q",
      ~s(#{args}) # | args
    ]

    {output, status} = System.cmd("sqlcmd", params, stderr_to_stdout: true)

    if status != 0 do
      IO.puts("""
      Command:

      sqlcmd #{Enum.join(args, " ")}

      error'd with:

      #{output}

      Please verify the user "sa" exists and it has permissions to
      create databases and users. If not, you need create a new user
      """)

      System.halt(1)
    end

    output
  end
  
  # def vsn do
  #   vsn_select = cmd(["-c", "SELECT version();"])
  #   [_, major, minor] = Regex.run(~r/PostgreSQL (\d+).(\d+)/, vsn_select)
  #   {String.to_integer(major), String.to_integer(minor)}
  # end

  # def supports_sockets? do
  #   otp_release = :otp_release |> :erlang.system_info() |> List.to_integer()
  #   unix_socket_dir = System.get_env("PG_SOCKET_DIR") || "/tmp"
  #   port = System.get_env("PGPORT") || "5432"
  #   unix_socket_path = Path.join(unix_socket_dir, ".s.PGSQL.#{port}")
  #   otp_release >= 20 and File.exists?(unix_socket_path)
  # end
end
  
  # pg_version = PSQL.vsn()
  # unix_exclude = if PSQL.supports_sockets?(), do: [], else: [unix: true]
  # notify_exclude = if pg_version == {8, 4}, do: [requires_notify_payload: true], else: []
  
  # version_exclude =
  #   [{8, 4}, {9, 0}, {9, 1}, {9, 2}, {9, 3}, {9, 4}, {9, 5}, {10, 0}]
  #   |> Enum.filter(fn x -> x > pg_version end)
  #   |> Enum.map(fn {major, minor} -> {:min_pg_version, "#{major}.#{minor}"} end)
  
# excludes = version_exclude ++ notify_exclude ++ unix_exclude
ExUnit.start(assert_receive_timeout: 1000)
# {:ok, _} = Application.ensure_all_started(:crypto)

sql_test = """
USE [tdx_test]
GO
CREATE USER [tdx_cleartext_pw] FOR LOGIN [tdx_cleartext_pw]
GO
USE [tdx_test]
GO
ALTER ROLE [db_owner] ADD MEMBER [tdx_cleartext_pw]
GO

CREATE TABLE [altering] ([a] int)
CREATE TABLE [composite1] ([a] int, [b] text)
CREATE TABLE [composite2] ([a] int, [b] int, [c] int)
CREATE TABLE [uniques] ([id] int NOT NULL, CONSTRAINT UIX_uniques_id UNIQUE([id]))
"""

# sql_test_with_schemas = """
# DROP SCHEMA IF EXISTS test;
# CREATE SCHEMA test;
# """
sql_create_database = """
IF EXISTS(SELECT * FROM sys.databases where name = 'tdx_test')
DROP DATABASE [tdx_test]
GO
CREATE DATABASE [tdx_test]
GO
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'tdx_cleartext_pw')
DROP USER [tdx_cleartext_pw]
GO
CREATE LOGIN [tdx_cleartext_pw] WITH PASSWORD=N'ECHBAvvxIBMIdyp3IYjuN5qybOmHZbsC7hsWYcBr/DQ=', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
"""
MSQL.cmd([sql_create_database])
# PSQL.cmd(["-c", "DROP DATABASE IF EXISTS postgrex_test_with_schemas;"])

# PSQL.cmd([
#   "-c",
#   "CREATE DATABASE postgrex_test TEMPLATE=template0 ENCODING='UTF8' LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8';"
# ])

# PSQL.cmd([
#   "-c",
#   "CREATE DATABASE postgrex_test_with_schemas TEMPLATE=template0 ENCODING='UTF8' LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8';"
# ])

MSQL.cmd([sql_test])
# PSQL.cmd(["-d", "postgrex_test_with_schemas", "-c", sql_test_with_schemas])

# cond do
#   pg_version >= {9, 1} ->
#     PSQL.cmd([
#       "-d",
#       "postgrex_test_with_schemas",
#       "-c",
#       "CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA test;"
#     ])

#     PSQL.cmd(["-d", "postgrex_test", "-c", "CREATE EXTENSION IF NOT EXISTS hstore;"])

#   pg_version == {9, 0} ->
#     pg_path = System.get_env("PGPATH")
#     PSQL.cmd(["-d", "postgrex_test", "-f", "#{pg_path}/contrib/hstore.sql"])

#   pg_version < {9, 0} ->
#     PSQL.cmd(["-d", "postgrex_test", "-c", "CREATE LANGUAGE plpgsql;"])

#   true ->
#     :ok
# end

# defmodule Postgrex.TestHelper do
#   defmacro query(stat, params, opts \\ []) do
#     quote do
#       case Postgrex.query(var!(context)[:pid], unquote(stat), unquote(params), unquote(opts)) do
#         {:ok, %Postgrex.Result{rows: nil}} -> :ok
#         {:ok, %Postgrex.Result{rows: rows}} -> rows
#         {:error, err} -> err
#       end
#     end
#   end

#   defmacro prepare(name, stat, opts \\ []) do
#     quote do
#       case Postgrex.prepare(var!(context)[:pid], unquote(name), unquote(stat), unquote(opts)) do
#         {:ok, %Postgrex.Query{} = query} -> query
#         {:error, err} -> err
#       end
#     end
#   end

#   defmacro prepare_execute(name, stat, params, opts \\ []) do
#     quote do
#       case Postgrex.prepare_execute(
#              var!(context)[:pid],
#              unquote(name),
#              unquote(stat),
#              unquote(params),
#              unquote(opts)
#            ) do
#         {:ok, %Postgrex.Query{} = query, %Postgrex.Result{rows: rows}} -> {query, rows}
#         {:error, err} -> err
#       end
#     end
#   end

#   defmacro execute(query, params, opts \\ []) do
#     quote do
#       case Postgrex.execute(var!(context)[:pid], unquote(query), unquote(params), unquote(opts)) do
#         {:ok, %Postgrex.Query{}, %Postgrex.Result{rows: nil}} -> :ok
#         {:ok, %Postgrex.Query{}, %Postgrex.Result{rows: rows}} -> rows
#         {:error, err} -> err
#       end
#     end
#   end

#   defmacro stream(query, params, opts \\ []) do
#     quote do
#       Postgrex.stream(var!(conn), unquote(query), unquote(params), unquote(opts))
#     end
#   end

#   defmacro close(query, opts \\ []) do
#     quote do
#       case Postgrex.close(var!(context)[:pid], unquote(query), unquote(opts)) do
#         :ok -> :ok
#         {:error, err} -> err
#       end
#     end
#   end

#   defmacro transaction(fun, opts \\ []) do
#     quote do
#       Postgrex.transaction(var!(context)[:pid], unquote(fun), unquote(opts))
#     end
#   end
# end
