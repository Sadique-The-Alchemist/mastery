defmodule Mastery do
  @moduledoc """
  Documentation for `Mastery`.
  """
  alias Mastery.Boundary.{QuizManager, QuizSession, TemplateValidator, QuizValidator}

  alias Mastery.Core.Quiz

  def build_quiz(fields) do
    with :ok <- QuizValidator.errors(fields),
         :ok <- GenServer.call(QuizManager, {:build_quiz, fields}) do
      :ok
    else
      errors -> errors
    end
  end

  def add_template(title, fields) do
    with :ok <- TemplateValidator.errors(fields),
         :ok <- GenServer.call(QuizManager, {:add_template, title, fields}) do
      :ok
    else
      errors -> errors
    end
  end

  def take_quiz(title, email) do
    with %Quiz{} = quiz <- QuizManager.lookup_quiz_by_title(QuizManager, title),
         {:ok, session} <- QuizSession.take_quiz(quiz, email) do
      session
    else
      error -> error
    end
  end

  def select_question(session) do
    GenServer.call(session, :select_question)
  end

  def answer_question(session, answer) do
    GenServer.call(session, {:answer_question, answer})
  end
end
