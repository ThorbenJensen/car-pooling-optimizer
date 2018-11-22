# CAR POOLING SOLVER

library(lpSolveAPI)
library(assertthat)


# SOLUCTION SPACE ----
lprec <- make.lp(nrow = 2, ncol = 4 + 4)
set.type(lprec, columns = 1:8, type = "binary")


# DATA ----
budget <- c(19, 19, 0, 1)
cap_total <- c(2, 2, 2, 2)
cap_other <- cap_total - 1

dist_join <- 0.6
dist <- c(1, 1, dist_join, dist_join)
dist_full <- dist == max(dist)

W <- matrix(c(1, 0,
              1, 0,
              1, 0,
              1, 0), nrow = 4, byrow = TRUE)

H <- matrix(c(1, 0,
              1, 0,
              1, 0,
              1, 0), nrow = 4, byrow = TRUE)


# VALIDATE DATA ----
# matrices W and H
assert_that(all(apply(W, 1, sum) %in% c(0, 1)),
            msg = "Row sum incorrect.")
assert_that(all(apply(H, 1, sum) %in% c(0, 1)),
            msg = "Row sum incorrect.")
assert_that(all(apply(W, 1, sum) == apply(H, 1, sum)),
            msg = "Row sums inconsistent")


# CONSTRAINTS ----
# for last strech of journey:
# per time slot, total_capacity of drivers at least the number of drivers
add.constraint(lprec,
               W[, 1] * cap_total, '>=', sum(W[, 1]), indices = 1:4)
add.constraint(lprec,
               W[, 2] * cap_total, '>=', sum(W[, 2]), indices = 1:4)
add.constraint(lprec,
               H[, 1] * cap_total, '>=', sum(H[, 1]), indices = 1:4)
add.constraint(lprec,
               H[, 2] * cap_total, '>=', sum(H[, 2]), indices = 1:4)
# for first strech of journey:
# per time slot, enough capacity for those with full distance
add.constraint(lprec,
               W[, 1] * cap_total, '>=', sum(W[, 1]),
               indices = 5:8)
add.constraint(lprec,
               W[, 2] * cap_total, '>=', sum(W[, 2]),
               indices = 5:8)
add.constraint(lprec,
               H[, 1] * cap_total, '>=', sum(H[, 1]),
               indices = 5:8)
add.constraint(lprec,
               H[, 2] * cap_total, '>=', sum(H[, 2]),
               indices = 5:8)
# late joiners cannot drive first strech
add.constraint(lprec, rep(1, 2), '=', 0, indices = 3:4)
# if not a late joiner, driving second strech requires driving the first one
add.constraint(lprec, c(1, -1), '>=', 0, indices = c(1, 5))
add.constraint(lprec, c(1, -1), '>=', 0, indices = c(2, 6))


# OBJECTIVE FUNCTION ----
lp.control(lprec, sense = "min")
fair_w <- 0.1
set.objfn(lprec,
          c(dist - dist_join, rep(dist_join, 4)) +
          c(fair_w * budget, fair_w * budget))

# SOLVE ----
lprec
solve(lprec)
get.objective(lprec)
get.constraints(lprec)
get.variables(lprec)
