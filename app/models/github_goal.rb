class GithubGoal < ActiveRecord::Base
  belongs_to :user

  def get_the_json
    response =  Faraday.get("https://api.github.com/users/#{self.user
                                                              .oauth_accounts
                                                              .find_by(provider: 'github')
                                                              .nickname}/events?client_id=#{ENV['github_key']}&client_secret=#{ENV['github_secret']}")
    JSON.parse(response.body)
  end

  def push_events
    get_the_json.select { |event| event["type"] == "PushEvent" }
  end

  def daily_events
    push_events.select { |event| Date.parse(event["created_at"]) == Date.today }
  end

  def daily_commits
    daily_events.map { |event| event["payload"]["commits"] }
  end

  def current_users_commits
    daily_commits.flatten.select { |commit| commit['author']['name'] == self.user.oauth_accounts.find_by(provider: 'github').name }
  end

  def daily_commit_count
    current_users_commits.count
  end

  def daily_progress
    if daily_commit_count > commit_goal
      100
    else
      (daily_commit_count.to_f/commit_goal.to_f) * 100
    end
  end

  def start_date
    Date.today # this gets called the day they sign up
  end

  def self.check_daily_goal
    self.all.each do |github_goal|
      if github_goal.daily_commit_count >= github_goal.commit_goal
        # this sets the current streak to add one to the current streak
        github_goal.streak += 1
        github_goal.set_longest_streak
        github_goal.save
      else
        # this sets the current streak to 0
        github_goal.streak = 0
        github_goal.save
      end
      # we may need to call github_goal.save here....not sure
    end
  end

  def set_longest_streak
    if streak > self.longest_streak
      self.longest_streak = streak
    end
  end

end
