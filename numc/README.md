# numc

### Provide answers to the following questions for each set of partners.
- How many hours did you spend on the following tasks?

I have no clue how many hours I exactly spent on this project, but I spent a lot. You can take a look at my Github commit history for reference.
  - Task 1 (Matrix functions in C): ~2 hours
  - Task 2 (Writing the Python-C interface): ~48 hours (a lot of it was spent waiting for a response on Ed because I didn't know why AG says my code isn't compiling). Probably around 5-10 hours of actual research/coding (and implementing error cases later)
  - Task 3 (Speeding up matrix operations): ~12 hours of ~~suffering~~ thinking/coding/working
- Was this project interesting? What was the most interesting aspect about it?
  - <b>This project was pretty painful but interesting and rewarding. I enjoyed optimizing multiplication and squeezing out every bit of performance out of it. The best moment of this project was when I was struggling, trying to figure out how I can reach 90x multiply speedup when I only had ~18x speedup, and then I suddenly realized that transposition would resolve the memory access issue associated with normal loop order matrix multiplication and save me a bunch of intrinsic store operations.</b>
- What did you learn?
  - <b>I learned to re-arrange loop order in order to optimize memory access (although I didn't use this design in the end since it wasn't optimal), I learned to store pointers so I don't have to do arrow accesses inside of loops. I also learned to move pointers with addition as much as possible instead of calculating the offset with multiply and add each time. </b>
- Is there anything you would change?
  - <b>Regarding my code, I wish it wasn't as messy but I don't really know how to clean it up and make it more structured. Regarding the project specs, I would change it so that the numc code is already provided to us, because I had a lot of trouble figuring out how to deal with Python stuff, when the Python stuff involved is not the actual focus of the project.</b>