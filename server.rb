require 'sinatra'
require 'json'

class Question

	# Constructor
	def initialize(from, to)
		@from = from
		@to = to
		generate_answer()
		generate_question()
		generate_incorrect_answers()
	end

	# Get an answer in range specified by the user
	def generate_answer()
		@correct_answer = rand(@to - @from + 1) + @from
	end

	# Get terms for the question based on the correct answer
	def generate_question()
		first = rand(@correct_answer)
		second = @correct_answer - first
		@question = first.to_s + " + " + second.to_s
	end

	# Generate incorrect answers for the question
	def generate_incorrect_answers()
		# We could also make the array smaller if we didn't want to repeat answers for small ranges e.g. for range from 10 to 12
		@incorrect_answers = Array.new(3)

		for i in 0..2
			incorrect_answer = rand(@to - @from + 1) + @from

			# If range is greater or equal to 3, make all the answers different from each other
			# This can definitely be made to work more efficiently
			if @to - @from >= 3
				while incorrect_answer == @correct_answer or @incorrect_answers.include?(incorrect_answer) do
					incorrect_answer = rand(@to - @from + 1) + @from
				end
			# If range is either 1 or 2, do not care about the answers being different
			else
				while incorrect_answer == @correct_answer do
					incorrect_answer = rand(@to - @from + 1) + @from
				end
			end

			@incorrect_answers[i] = incorrect_answer
		end

		@incorrect_answers
	end

	# Return question, correct answer and all answers in JSON format
	def show()
		answers = @incorrect_answers
		answers.insert(rand(3), @correct_answer)
		{"question" => @question,
			"correct_answer" => @correct_answer,
			"answers" => answers}.to_json()
	end
end

get '/question' do
	content_type :json
	# Retrieve parameters
	from, to = params['from'].to_i, params['to'].to_i

	# Input sanitation
	if from >= to or from < 0 or to > 1000000
		halt 400, "Incorrect arguments ('from' should be non-negative and smaller than 'to' which should, in turn, be smaller than 1000000)"
	end

	# Return JSON if input correct
	question = Question.new(from, to)
	question.show()
end