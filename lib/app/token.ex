defmodule MainModule.Token do
  use Joken.Config
  
  def token_config, do: default_claims(default_exp: 15 * 60) # 15 dakika
end
