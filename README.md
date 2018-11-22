# Car pooling, solved linearly

## Problem statement

N persons want to share rides.
They can leave and return at 2 time slots for both the trip to work and the return trip home.
Each day, a person either brings a car or not.
Some people do not have cars.
Each car has a given capacity.

## Decision space

Each of N is either a driver, or a passenger.
This is formalized as an P-dimensional binary vector $a$.
If person $i$ brings a car, $a_i$ is 1, else 0.

## Available information

1. At which time slot a person wants to ride to work,
is known from matrix $W$ of size $i x j$.
When she wants to return home is known from table $H$, of size $i x j$.
If person $i$ wants to ride at slot $j$, $W_{ij} = 1$, else $0$.
Either is person is riding both to work and back, or not at all.
Thus, the row sums in $W$ and $H$ are each $0$ or $2$.

2. Driving others adds distance to a budget, from which riding in someone else's car is deduced.
These budgets are held in vector $b$, $b_i$ being the budget of person $i$.
Distance budgets can be any positive or negative number.
These budgets should be updated after each time a schedule is taken out.

## Optimization target

The main target is to minimize the number of cars used in a day.
At lower priority -- for fairness -- prioritize driver with higher mileage budget.
minimize $\sum a_i + 0.1 b_i a_i$

## Constraints

1. At each *requested* time slot of trips 'to work' and 'to home', enough persons offer their car.

2. Prople who cannot brang a car, cannot be drivers.

## TODOs

* Automate data ingestion
