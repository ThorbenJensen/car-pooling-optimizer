# Car pooling, solved linearly

## Problem statement

N persons want to share rides.
They can leave and return at 2 time slots for both the trip to work and the return trip home.
Each day, a person either brings a car or not.
In that case, both the trip to work and the return trip are offered by her.
The maximum number of persons per car is 5 (incl. the driver).

## Decision space

Each of $P$ persons either brings a car, or not.
This is formalized as an P-dimensional binary vector $a$.
If person $p$ brings a car, $a_p$ is 1, else 0.

## Available information

At which time slot a person wants to ride to work, is known from matrix $W$ of size $p x s$.
When she wants to return home is known from table $H$, of size $p x s$.
If person $p$ wants to ride at slot $s$, $W_{ps} == 1$, else 0. 


## Constraints

1. At each time slot of trips 'to work' and 'to home', enough persons offer their car (i.e. at least 1 in 5).

2. The number of people bringing their cars should be minimal.

