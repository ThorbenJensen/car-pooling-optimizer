""" Linear program with PULP """

import pandas as pd
import pulp

# INPUT DATA
drivers = pd.read_csv("data/drivers.csv", index_col=["driver_id"])
schedule = pd.read_csv("data/schedule.csv", index_col=["driver_id"])
FAIRNESS_FACTOR = 0.001

# derived data
drivers_schedule = drivers.join(schedule, on=["driver_id"])

# Setup model
driver_drives = pulp.LpVariable.dicts(
    name="car pooling", indexs=drivers.index, cat="Binary",
)
model = pulp.LpProblem("Car_pooling_problem", pulp.LpMinimize)

# Target function
model += pulp.lpSum(
    [
        # minimize the number of driving drivers:
        driver_drives[driver_id] +
        # prioritze the drivers with higher social_score:
        driver_drives[driver_id] * FAIRNESS_FACTOR * drivers.loc[driver_id].seat_balance
        for driver_id in drivers.index
    ]
)


# Constraints
# capacity at all 'starting times' meets demand:
times_start = schedule.timeslot_start.unique()
for time in times_start:
    drivers_timeslot = drivers_schedule.query("timeslot_start == @time").index
    demand_timeslot = len(drivers_timeslot)
    model += (
        sum(
            [
                driver_drives[driver_id] * drivers.loc[driver_id].seats
                for driver_id in drivers_timeslot
            ]
        )
        >= demand_timeslot
    )

# capacity at all 'end times' meets demand:
times_end = schedule.timeslot_end.unique()
for time in times_end:
    drivers_timeslot = drivers_schedule.query("timeslot_end == @time").index
    demand_timeslot = len(drivers_timeslot)
    model += (
        sum(
            [
                driver_drives[driver_id] * drivers.loc[driver_id].seats
                for driver_id in drivers_timeslot
            ]
        )
        >= demand_timeslot
    )

# Solve
model.solve()
print(f"Status of solver: {pulp.LpStatus[model.status]}")
model.writeLP("model.txt")


# print solution
solution = [bool(driver_drives[driver_id].varValue) for driver_id in drivers.index]
chosen_drivers = list(drivers.index[solution])
print(f"chosen drivers: {chosen_drivers}")
