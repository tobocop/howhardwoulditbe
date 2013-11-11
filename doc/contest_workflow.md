Contest Workflow
================


1. Wait for contest to end

2. Run Rake task to trigger prize level creation (on production box)

    `RAILS_ENV=production bundle exec rake contest:create_prize_levels_for_contest[contest_id]`
3. Run rake task to select winners for selected contest

    `RAILS_ENV=production bundle exec rake contest:select_winners_for_contest[contest_id]`

4. Via the admin, manually reject & select winners. Accept Winners & Validate on front end

5. Run rake task to post on the winner`s behalf
    `RAILS_ENV=production bundle exec rake contest:post_on_winners_behalf[contest_id]`

6. Push the contest setup branch that contains the next contest`s updated rake task and messaging
