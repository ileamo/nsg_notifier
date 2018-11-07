#! /usr/bin/env elixir

Process.sleep(3000)

<<i1::unsigned-integer-32, i2::unsigned-integer-32, i3::unsigned-integer-32>> =
  :crypto.strong_rand_bytes(12)

:rand.seed(:exsplus, {i1, i2, i3})

case Enum.random(1..3) do
  3 -> IO.puts("2010-01-01 00:10:33 FATAL Can't access module(connection refused)")
  _ -> IO.puts("OK")
end
