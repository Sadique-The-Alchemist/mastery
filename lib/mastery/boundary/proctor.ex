defmodule Mastery.Boundary.Proctor do
  use GenServer
  require Logger
  alias Mastery.Boundary.{QuizManager, QuizSession}

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(quizzes) do
    {:ok, quizzes}
  end

  def schedule_quiz(proctor \\ __MODULE__, quiz, templates, starts_at, ends_at) do
    quiz = %{
      field: quiz,
      templates: templates,
      starts_at: starts_at,
      ends_at: ends_at
    }

    GenServer.call(proctor, {:schedule_quiz, quiz})
  end

  def handle_call({:schedule_quiz, quiz}, _from, quizzes) do
    now = DateTime.utc_now()

    orderd_quizzes =
      [quiz | quizzes]
      |> start_quizzes(now)
      |> Enum.sort(fn a, b -> date_time_less_than_or_equal?(a.starts_at, b.starts_at) end)

    build_reply_with_timeout({:reply, :ok}, orderd_quizzes, now)
  end

  def handle_info({:end_quiz, title}, quizzes) do
    QuizManager.remove_quiz(title)

    title
    |> QuizSession.active_session_for()
    |> QuizSession.end_session()

    Logger.info("Quiz ended #{title}....")
    handle_info(:timeout, quizzes)
  end

  def handle_info(:timeout, quizzes) do
    now = DateTime.utc_now()
    remaining_quizzes = start_quizzes(quizzes, now)
    build_reply_with_timeout({:noreply}, remaining_quizzes, now)
  end

  defp build_reply_with_timeout(reply, quizzes, now) do
    reply
    |> append_state(quizzes)
    |> maybe_append_timeout(quizzes, now)
  end

  defp append_state(reply, quizzes) do
    Tuple.append(reply, quizzes)
  end

  defp maybe_append_timeout(reply, [], _), do: reply

  defp maybe_append_timeout(reply, quizzes, now) do
    timeout =
      quizzes
      |> hd
      |> Map.fetch!(:started_at)
      |> DateTime.diff(now, :millisecond)

    Tuple.append(reply, timeout)
  end

  defp start_quizzes(quizzes, now) do
    {ready, not_ready} =
      Enum.split_while(quizzes, fn quiz -> date_time_less_than_or_equal?(quiz.starts_at, now) end)

    Enum.each(ready, &start_quiz(&1, now))
    not_ready
  end

  defp start_quiz(quiz, now) do
    Logger.info("Starting quiz: #{quiz.field.title}....")
    QuizManager.build_quiz(quiz.field)
    Enum.each(quiz.templates, &QuizManager.add_template(quiz.field.title, &1))
    timeout = DateTime.diff(quiz.ends_at, now, :millisecond)
    Process.send_after(self(), {:end_quiz, quiz.field.title}, timeout)
  end

  defp date_time_less_than_or_equal?(a, b) do
    DateTime.compare(a, b) in ~w[lt eq]a
  end
end
