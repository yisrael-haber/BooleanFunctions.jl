module BooleanFunctions

# If it is giving you issues with github run "export JULIA_PKG_USE_CLI_GIT=true" from terminal, and then run from julia 
# 

include("Decision Trees/binary_trees.jl")

export 

tree, node, init_tree_at_node, init_tree, same_level, not_left, not_right, different_ancestry, no_parent_node, 
get_next_left, get_next_right, get_next_right_final, get_next_left_final,
add_nodes_at!, get_node_string, print_tree_from_node, get_root, evaluate_tree_at_vec, print_tree_at_root, get_and_update_max_var!

end # module
