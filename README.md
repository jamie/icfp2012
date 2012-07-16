Solution for the [2012 ICFP Programming Contest](http://icfpcontest2012.wordpress.com/)

### About This Solution

I'm trying to do the stupidest thing possible. Exhaustively enumerate
possible solutions, keeping track of past positions. Run until a
solution arrives at the exit, or until SIGINT is received.

Note that this brute force solution is highly unlikely to be successful
at scoring for anything, and doubly so on account of it being in Ruby.

### Notes

[Online solution verifier](http://www.undecidable.org.uk/~edwin/cgi-bin/weblifter.cgi)

### TODO

- Speed things the hell up.

- Once reasonably speedy (at least < 1 second for contest10.map), handle SIGINT to output highest-scoring interim solution.

- Get running inside debian VM, with all necessary setup in ./install and ./PACKAGES-TESTING.
