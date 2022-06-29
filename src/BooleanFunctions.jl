module BooleanFunctions

include("Decision Trees/trees.jl")

export 

tree, node, init_tree_at_node, init_tree, same_level, not_left, not_right, different_ancestry, no_parent_node, 
get_next_left, get_next_right, get_next_right_final, get_next_left_final,
add_nodes_at!, get_node_string, print_tree_from_node




end # module
