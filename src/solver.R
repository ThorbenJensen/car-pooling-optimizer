# CAR POOLING SOLVER

library(lpSolveAPI)
library(assertthat)

sprintf_ <- function(...) print(sprintf(...))

# INPUT DATA ----
N <- 5
J <- 2
budget <- c(19, 18, 0, 1, 5)
no_car <- c(0, 0, 0, 1, 1)
cap_total <- c(3, 3, 5, 3, 4)

W <- matrix(c(1, 0,
              0, 1,
              0, 1,
              0, 1,
              0, 1), nrow = N, byrow = TRUE)

H <- matrix(c(1, 0,
              1, 0,
              0, 1,
              0, 1,
              1, 0), nrow = N, byrow = TRUE)

# VALIDATE INPUT DATA ----
# consistent length of input data
assert_that(length(budget) == N, msg = "inconsistent length.")
assert_that(length(no_car) == N, msg = "inconsistent length.")
assert_that(length(cap_total) == N, msg = "inconsistent length.")
assert_that(nrow(W) == N, msg = "inconsistent length.")
assert_that(nrow(H) == N, msg = "inconsistent length.")
# same numver of columns between matrices
assert_that(ncol(W) == ncol(H), msg = "inconsistent length.")
# matrices W and H have consitent row sums
assert_that(all(apply(W, 1, sum) %in% c(0, 1)),
            msg = "Row sum incorrect.")
assert_that(all(apply(H, 1, sum) %in% c(0, 1)),
            msg = "Row sum incorrect.")
assert_that(all(apply(W, 1, sum) == apply(H, 1, sum)),
            msg = "Row sums inconsistent")

# SOLUTION SPACE ----
lprec <- make.lp(nrow = J, ncol = N)
set.type(lprec, columns = 1:N, type = "binary")

# CONSTRAINTS ----
# per time slot, total_capacity of drivers at least the number of drivers
cap_other <- cap_total - 1
for (A in list(W, H)) {
  for (j in 1:J) {
    add.constraint(lprec, A[, j] * cap_total, '>=', sum(A[, j]))
  }
}
# only who has a car can be driver
add.constraint(lprec, no_car, '=', 0)


# OBJECTIVE FUNCTION ----
lp.control(lprec, sense = "min")
fairness_weight <- 0.1
set.objfn(lprec, rep(1, N) + c(fairness_weight * budget))

# SOLVE ----
lprec
solve(lprec)
get.objective(lprec)
get.constraints(lprec)
get.variables(lprec)

# MAKE SCHEDULE ---
all_drivers <- get.variables(lprec)[1:N]
sprintf_("Total number of drivers: %i", length(all_drivers[all_drivers == 1]))

for (A in list(W, H)) {
  for (j in 1:J) {

    # get drivers
    drivers <- which(all_drivers & A[, j])
    if (length(drivers) == 0) next
    direction <- ifelse(all(A == W), "work", "home")
    sprintf_("Towards '%s' at time slot %i:", direction, j)
    sprintf_("Drivers: %s", paste(drivers, collapse = " "))
    # get passengers
    passengers <- setdiff(which(A[, j] == 1), drivers)
    if (length(passengers) == 0) next
    # test that there is enough capacity
    assert_that(sum(cap_other[drivers]) >= length(passengers),
                msg = "no capacity.")
    # assign passengers to drivers
    cap_pool <- rep(drivers, cap_other[drivers])
    assignment <- sample(cap_pool, length(passengers), replace = FALSE)
    # report
    sprintf_("Passenger %s rides with driver %s", passengers, assignment)
  }
}
