# Packages
using JuMP
using DelimitedFiles
using Gurobi
using LinearAlgebra

    
# Read the files
smallInstance = readdlm("C:\\Users\\ANDREA\\Documents\\DO\\test_instance_small.txt", ' ')

# We have 71 columns and 8760 rows in the smallInstance file
nrows_small = size(smallInstance, 1 )
ncolumns_small = size(smallInstance, 2 )

# Given the different dimensions of the matrices defined in the files due to different weather conditions, we focus on one file
# Create the model for Small Instance file
modelSmall = Model()
set_optimizer(modelSmall, Gurobi.Optimizer)
set_optimizer_attribute(modelSmall, "TimeLimit", 100)
set_optimizer_attribute(modelSmall, "Presolve", 0)


# Define variables 

@variable(modelSmall, x[i=1:nrows_small], binary=true)
@variable(modelSmall, z[j=1:ncolumns_small], binary=true)
# Definition of the variable y with an expression 
@expression(modelSmall, y[j = 1:ncolumns_small], sum(smallInstance[i, j] * x[i] for i= 1:nrows_small)) 
@variable(modelSmall, 0 <= c ) 

# Define constraints
@constraint(modelSmall, c <= nrows_small/10)

for j = 1:ncolumns_small
    @constraint(modelSmall, y[j] >= c - 1000 * (1- z[j]))
end

# A constraint for the sum of x is added
@constraint(modelSmall, sum(x) <= nrows_small/10)

# Objective function 
# We write sum(z) + c so the vector x = 0 will not be an optimal solution

@objective(modelSmall,Max, sum(z) + c) 

# Another attempt

# for a = {0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1}
# We defined
# @objective(modelSmall,Max, a*sum(z) + (1-a)c) 


# Solve 
optimize!(modelSmall)
termination_status(modelSmall)

# Results
println("Value of sum(x) ", sum(value.(x)))
#println("Value of c ", value.(c))

println("Model with Small Instance file:")
return objective_value(modelSmall)
