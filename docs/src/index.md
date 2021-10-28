```@meta
CurrentModule = Bonobo
```

# Bonobo

Bonobo is a general branch and bound framework at a very early stage. 
The idea is to make it very customizable and provide useful methods regarding branching strategies and cuts. 

The following three functions need to be implemented to start the process.

- [`initialize`](@ref)
  - For initializing the framework itself and setting options. 
- [`set_root!`](@ref)
  - Setting the information for the root node which will be evaluated first with [`evaluate_node!`](@ref)
- [`optimize!`](@ref)
  - The optimization function calls several branch and bound functions in a loop. Check the docstring for detailed information.

A couple of methods need to be implemented by you to apply it to your need. 
When you call the above methods some warnings might pop up in the terminal which specify which functions need to be implemented by you.


