"""
Computes the maximum multiroute flow (for an integer number of routes)
between the source and target vertexes in a flow graph using the
[Kishimoto algorithm](http://dx.doi.org/10.1109/ICCS.1992.255031).
Returns the value of the multiroute flow as well as the final flow matrix,
along with a multiroute cut if Boykov-Kolmogorov is used as a subroutine.
Use a default capacity of 1 when the capacity matrix isn\'t specified.
Requires arguments:
- flow_graph::DiGraph                    # the input graph
- source::Int                            # the source vertex
- target::Int                            # the target vertex
- capacity_matrix::AbstractArray{T,2}    # edge flow capacities
- flow_algorithm::AbstractFlowAlgorithm, # keyword argument for algorithm
- routes::Int                            # keyword argument for routes
"""

# Kishimoto algorithm
function kishimoto{T<:AbstractFloat}(
  flow_graph::DiGraph,                   # the input graph
  source::Int,                           # the source vertex
  target::Int,                           # the target vertex
  capacity_matrix::AbstractArray{T,2},   # edge flow capacities
  flow_algorithm::AbstractFlowAlgorithm, # keyword argument for algorithm
  routes::Int                            # keyword argument for routes
  )
  if flow_algorithm ≠ BoykovKolmogorovAlgorithm()
    # Initialisation 1
    flow, F = maximum_flow(flow_graph, source, target,
           capacity_matrix, algorithm = flow_algorithm)
    restriction = flow / routes

    flow, F = maximum_flow(flow_graph, source, target, capacity_matrix,
            algorithm = flow_algorithm, restriction = restriction)

    # Loop 1
    i = 1
    while flow ≉ routes * restriction && flow < routes * restriction
      restriction = (flow - i * restriction) / (routes - i)
      i = i + 1
      flow, F = maximum_flow(flow_graph, source, target, capacity_matrix,
                algorithm = flow_algorithm, restriction = restriction)
    end

    # End 1
    return flow, F
  else
    # Initialisation 2
    flow, F, labels = maximum_flow(flow_graph, source, target,
           capacity_matrix, algorithm = flow_algorithm)
    restriction = flow / routes

    flow, F, labels = maximum_flow(flow_graph, source, target, capacity_matrix,
            algorithm = flow_algorithm, restriction = restriction)

    # Loop 2
    i = 1
    while flow ≉ routes * restriction && flow < routes * restriction
      restriction = (flow - i * restriction) / (routes - i)
      i = i + 1
      flow, F, labels = maximum_flow(flow_graph, source, target, capacity_matrix,
                algorithm = flow_algorithm, restriction = restriction)
    end

    # End 2
    return flow, F, labels
  end
end
