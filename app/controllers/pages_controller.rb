require 'octokit'

class PagesController < ApplicationController
  def home
  end

  def scoreboard
    username = params[:username]
    password = params[:password]
    repo = params[:repo]

    # authentication
    client = Octokit::Client.new(login: username, password: password)

    # repository
    repo = repo

    # get last 100 pull requests
    pulls = client.pull_requests(repo, state: 'all', per_page: 100)

    # filter by those created in past week
    start_date = Date.today - 7
    pulls = pulls.select { |pull| Date.parse(pull.created_at.to_s) > start_date }

    # get comments and reviews for each pull request
    comments = Array.new
    reviews = Array.new
    pulls.each do |pull| 
      comments.concat(client.pull_request_comments(repo, pull.number, per_page: 100))
      reviews.concat(client.pull_request_reviews(repo, pull.number, per_page: 100))
    end

    # scoreboard with login names and points
    scoreboard = Hash.new

    # populate the scoreboard
    pulls.each do |pull|
      if scoreboard.key?(pull.user.login)
        scoreboard[pull.user.login] += 12
      else
        scoreboard[pull.user.login] = 12
      end
    end

    comments.each do |comment|
      if scoreboard.key?(comment.user.login)
        scoreboard[comment.user.login] += 1
      else
        scoreboard[comment.user.login] = 1
      end
    end

    reviews.each do |review|
      if scoreboard.key?(review.user.login)
        scoreboard[review.user.login] += 3
      else
        scoreboard[review.user.login] = 3
      end
    end

    # sort the scoreboard
    @scoreboard = scoreboard.sort_by { |k, v| v }.reverse.to_h
  end
end
