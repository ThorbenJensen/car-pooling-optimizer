# Car pooling, solved linearly

## Problem statement

N persons want to share rides.
They can leave and return at 2 time slots for both the trip to work and the return trip home.
Each day, a person either brings a car or not.
In that case, both the trip to work and the return trip are offered by her.
The maximum number of persons per car is 5 (incl. the driver).

## Decision space

Each of N persons either brings a car, or not.
This is formalized as an P-dimensional binary vector $a$.
If person $i$ brings a car, $a_i$ is 1, else 0.

## Available information

1. At which time slot a person wants to ride to work,
is known from matrix $W$ of size $i x j$.
When she wants to return home is known from table $H$, of size $i x j$.
If person $i$ wants to ride at slot $s$, $W_{ij} = 1$, else $0$.
Either is person is riding both to work and back, or not at all.
Thus, the row sums in $W$ and $H$ are each $0$ or $2$.

2. The distance between a person's home and work is provided in vector $d_i$.
For simplification, $d_i$ can be 1 for each person $i$.

3. Driving others adds distance to a budget, from which riding in someone else's car is deduced.
These budgets are held in vector $b$, $b_i$ being the budget of person $i$.
Distance budgets can be any positive or negative number.
These budgets should be updated after each time a schedule is taken out.

## Optimization target

The main target is to minimize the number of cars used in a day.
At lower priority -- for fairness -- prioritize driver with higher mileage budget.
minimize $\sum a_i + 0.1 b_i a_i$

## Constraints

1. At each *requested* time slot of trips 'to work' and 'to home', enough persons offer their car (i.e. at least 1 in 5):

For each column in W: $W_11 a_1 + ... + W_1m a_i) > 1/6 * (W_11 + ... + W_1n)$

For each column in H: $H_11 a_1 + ... + H_1m a_i) > 1/6 * (H_11 + ... + H_1n)$

## TODOs

* Test/validate current solver
* Automate data ingestion
* Create reports
