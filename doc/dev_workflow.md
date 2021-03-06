Plink Development Workflow
==========================

Development & QA
----------------

1. Start the story in Tracker.

2. Create a branch for the feature if one does not already exist:

    `git checkout -b feature_name`

3. Make your code changes; put a finishes statement with the Pivotal
Tracker story ID as the last statement in the commit message, like so:

    `[Finishes #55933758]`

4. Refresh the repository metadata:

    `git fetch`

5. Bring in the current master:

    `git rebase origin/master`

6. Run the build

    `./build.sh`

7. Push the branch to a remote branch (if remote branch doesn't already exist.), notify Matt that new feature has been pushed

    `git push origin feature_name`

8. Manually change config/deploy.rb:

    `set :branch, 'feature_name'`

9. Deploy the code to the review server:

    `bundle exec cap review deploy:update`

10. Restart unicorn:

    `bundle exec cap review unicorn:restart`

11. Mark the story as Delivered.

12. Repeat 2-10 as needed to address defects found during testing.



Deployment
---

1. Do a git fetch from your feature branch
    `git fetch`

2. Make sure you have the most recent changes from master in your branch
    `git rebase origin/master`

3. If anything was added to your branch, Run the build
    `./build.sh`

4. Once you have a green build, checkout master
    `git checkout master`

2. Merge your branch using one of the following methods, making sure to
add the finishes statement (the Pivotal Tracker story ID) as the last line
of the commit if it's not already there:

    * `git merge --squash feature_name`
    Use this method if you'd like all your commits to be condensed to one

    * `git merge`
    Use this if you'd like all the commit messages from the branch

3. Push to github.

    `git push origin master`

4. Wait for green build on CI.

5. Fix any issues from CI and rebuild if necessary.

6. Remove the branch from Semaphore and Github when complete.




Production
----------

1. Create a Release Marker in Tracker outlining what is covered in the current release.

2. Deploy to production and restart unicorn

    * `bundle exec cap production deploy:update`
    * `bundle exec cap production unicorn:restart`

3. Accept stories, and apply the following tags to all released stories and release marker:
    * deployed
    * Release Timestamp ID (ex: 20130904181659)

4. Notify staff of release


Production Rollback
-------------------
1. If the release needs to be rolled back:

    * `bundle exec cap production deploy:rollback`
