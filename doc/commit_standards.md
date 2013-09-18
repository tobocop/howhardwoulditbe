Good commit messages serve at least three important purposes:

* To speed up the reviewing process.

* To help us write a good release note.

* To help the future maintainers of Plink

Structure your commit message like this:

<pre>
Summarize clearly in one line what the commit is about

Describe the problem the commit solves or the use
case for a new feature. Justify why you chose
the particular solution.

Finishes [ Commit # ]
</pre>

h2. DO

* Write the summary line and description of what you have done in the imperative mode, that is as if you were commanding someone. Write "fix", "add", "change" instead of "fixed", "added", "changed".

* Always leave the second line blank.

* Line break the commit message (to make the commit message readable without having to scroll horizontally in @gitk@).

* If applicable, add 'Finishes [Commit #]' to update Tracker

h2. DON'T

* Don't end the summary line with a period.

h2. Tips

* If it seems difficult to summarize what your commit does, it may be because it includes several logical changes or bug fixes, and are better split up into several commits using @git add -p@.

