mutable struct node 
    final::Bool
    variable::Int64
    children::Vector{node}
    code::String
end

mutable struct tree 
    nodes::Dict{String, node}
    depth::Int64
    size::Int64
    max_var::Int64
end

init_tree_at_node(vertex::node) = if vertex.code == "" tree(Dict(vertex.code=>vertex), 1, 1, vertex.variable) else println("Can't init tree with non-trivial code"); return false end

init_tree() = init_tree_at_node(node(false, 1, node[], ""))

same_level(vertex1::node, vertex2::node) = (length(vertex1.code) != length(vertex2.code))

not_left(vertex::node) = (last(vertex.code) != '0')

not_right(vertex::node) = (last(vertex.code) != '1')

different_ancestry(vertex1::node, vertex2::node) = (vertex1.code[1:length(vertex1.code)-1] != vertex2.code[1:length(vertex2.code)-1])

no_parent_node(binaryTree::tree, vertex::node) = (vertex.code[1:length(vertex.code)-1] ∉ keys(binaryTree.nodes))

get_next_left(vertex::node, var::Int64) = node(false, var, node[], string(vertex.code, '0'))

get_next_right(vertex::node, var::Int64) = node(false, var, node[], string(vertex.code, '1'))

get_next_left_final(vertex::node, var::Int64) = node(true, var, node[], string(vertex.code, '0'))

get_next_right_final(vertex::node, var::Int64) = node(true, var, node[], string(vertex.code, '1'))

function get_next_nodes(vertex::node, var1::Int64, final1::Bool, var2::Int64, final2::Bool)   
    if final1 left = get_next_left_final(vertex, var1) else left = get_next_left(vertex, var1) end
    if final2 right = get_next_right_final(vertex, var2) else right = get_next_right(vertex, var2) end
    return left, right
end

get_root(binaryTree::tree) = binaryTree.nodes[""]

get_untrivial_nodes(binaryTree::tree) = filter(x->length(x.children)>0, collect(values(binaryTree.nodes)))

get_var(veccy::Vector{node}) = map(x->x.variable, veccy)

get_and_update_max_var!(binaryTree::tree) = (binaryTree.max_var = maximum(get_var(get_untrivial_nodes(binaryTree))))

function update_size_and_depth!(binaryTree::tree, vertex::node) 
    if length(vertex.code) == binaryTree.depth binaryTree.depth += 1 end
    binaryTree.size += 1
end

function vertex_check(vertex::node)
    if vertex.final println("Cannot add nodes: the value is final, change node state and retry"); return false end
    if length(vertex.children) != 0 println("Cannot add nodes: children already exist, try changing the children"); return false end
    return true
end

function add_nodes_at!(binaryTree::tree, vertex::node, var1::Int64, final1::Bool, var2::Int64, final2::Bool)
    if !vertex_check(vertex) return false end
    left, right = get_next_nodes(vertex, var1, final1, var2, final2)
    vertex.children = [left, right]
    update_size_and_depth!(binaryTree, vertex)
    binaryTree.nodes[left.code]= left; binaryTree.nodes[right.code]= right 
    get_and_update_max_var!(binaryTree)
    return true
end

function add_nodes_at!(binaryTree::tree, vertex::String, var1::Int64, final1::Bool, var2::Int64, final2::Bool)
    add_nodes_at!(binaryTree, binaryTree.nodes[vertex], var1, final1, var2, final2)
end

function add_nodes_at!(binaryTree::tree, vertex::node, node1::Tuple{Int64, Bool}, node2::Tuple{Int64, Bool}) 
    add_nodes_at!(binaryTree, vertex, node1[1], node1[2], node2[1], node2[2])
end

function add_nodes_at!(binaryTree::tree, vertex::String, node1::Tuple{Int64, Bool}, node2::Tuple{Int64, Bool}) 
    add_nodes_at!(binaryTree, binaryTree.nodes[vertex], node1[1], node1[2], node2[1], node2[2])
end

function get_node_string(binaryTree::tree, vertex::node, currStr::String, tab_num::Int64, par_var::String)
    if vertex.final return string(currStr,"\t"^(tab_num), "$(par_var) || final value of path == $(vertex.variable) ||\n") end
    currStr = string(currStr, "\t"^(tab_num),"$(par_var)-- x$(vertex.variable) |\n")
    if length(vertex.children) == 0 return string(currStr[1:length(currStr)-1], "\t", " NO FINAL VALUE FOR THIS PATH CURRENTLY\n") 
    else
        next_left = get_node_string(binaryTree, vertex.children[1], "", tab_num + 1, "(x$(vertex.variable)==0) ")
        next_right = get_node_string(binaryTree, vertex.children[2], "", tab_num + 1, "(x$(vertex.variable)==1) ")
        currStr = string(currStr, next_left, next_right)
    end
    return currStr
end

function print_tree_from_node(binaryTree::tree, vertex::node)
    println("printing tree from node with code -$(vertex.code)-, if empty printing full tree")
    println(get_node_string(binaryTree, binaryTree.nodes[vertex.code], "", 0, ""))
end

print_tree_at_root(binaryTree::tree) = print_tree_from_node(binaryTree, get_root(binaryTree))

function evaluate_tree_at_vec(binaryTree::tree, vec::Tuple)
    if length(vec) < binaryTree.max_var println("Error: vector doesn't have enough values for the tree, not enough variables to evaluate function."); return false end
    curr_node = get_root(binaryTree)
    while true
        if curr_node.final return curr_node.variable end
        if length(curr_node.children)==0 println("Error: no final value for this path yet"); return false end
        if vec[curr_node.variable]==0 curr_node = curr_node.children[1] else curr_node = curr_node.children[2] end
    end
end