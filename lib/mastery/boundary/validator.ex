defmodule Mastery.Boundary.Validator do
  def require(errors, fields, field_name, validator) do
    present = Map.has_key?(fields, field_name)
    check_required_field(present, errors, fields, field_name, validator)
  end

  def optional(errors, fields, field_name, validator) do
    if Map.has_key?(fields, field_name) do
      require(errors, fields, field_name, validator)
    else
      errors
    end
  end

  def check(true = _valid, _message), do: :ok
  def check(false = _valid, message), do: message

  defp check_required_field(true = _present, errors, fields, field_name, f) do
    valid = fields |> Map.fetch!(field_name) |> f.()
    check_field(valid, errors, field_name)
  end

  defp check_required_field(false = _present, errors, _fields, field_name, _f) do
    errors ++ [{field_name, "Is Required"}]
  end

  defp check_field(:ok, _errors, _field_name), do: :ok

  defp check_field({:error, message}, errors, field_name) do
    errors ++ [{field_name, message}]
  end

  defp check_field({:errors, messages}, errors, field_name) do
    errors ++ Enum.map(messages, &{field_name, &1})
  end
end
