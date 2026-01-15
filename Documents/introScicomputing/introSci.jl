### A Pluto.jl notebook ###
# v0.20.16

using Markdown
using InteractiveUtils

# ╔═╡ baf88246-01d1-11eb-3d35-1393445b1476
begin
using PlutoUI
using LinearAlgebra
using InteractiveUtils
import AbstractTrees
using BenchmarkTools
using StaticArrays
end

# ╔═╡ 3daaaca4-5704-4d1b-b035-2450fb219a91
using HypertextLiteral

# ╔═╡ ba776d72-160c-41b9-b4c8-4b693f41c280
html"""
<b> Advanced Topics from Scientific Computing<br>
    TU Berlin Winter 2022/23<br> 
    Notebook 03<br>
    
<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons Lizenzvertrag" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/80x15.png" /></a>
Jürgen Fuhrmann
</b> <br>
"""

# ╔═╡ 3f4a405b-ada1-45b6-ade7-efb57dd22d79
TableOfContents()

# ╔═╡ 1b221e84-01d2-11eb-3e46-67e2a59b03dc
md"""
Type system
===================
- Julia is a strongly typed language
- Knowledge about the layout of a value in memory is encoded in its type
- Prerequisite for performance
- There are concrete types and abstract types
- See the [Julia WikiBook](https://en.wikibooks.org/wiki/Introducing_Julia/Types) for more


## Concrete types
 - Every value in Julia has a concrete type
 - Concrete types correspond to computer representations of objects
 - Inquire type info using `typeof()`

#### Built-in types
 - Default types are deduced from concrete representations
"""

# ╔═╡ 13ccfef0-01d3-11eb-0be7-87721fe2c996
typeof(10)

# ╔═╡ 3b84bb40-01d3-11eb-1416-db63210faba4
typeof(10.0)

# ╔═╡ 7462dc44-01d3-11eb-310e-3f6d6b6a7a4f
typeof(3.0+3im)

# ╔═╡ 802e2ace-01d3-11eb-039a-fff2bbc9b2a3
typeof(π)

# ╔═╡ 45de6c76-01d3-11eb-0e9d-47f8108ba1b4
typeof(false)

# ╔═╡ 4c6a79ea-01d3-11eb-268e-c32f7a6c85cd
typeof("false")

# ╔═╡ c924835e-01d3-11eb-0fcb-0d7d4050b32c
typeof(Float16[1,2,3])

# ╔═╡ d2cca0be-01d3-11eb-017f-5f72d26f23ba
typeof(rand(Int,3,3))

# ╔═╡ fb556f26-01d2-11eb-0244-d353d4ae0c9d
md"""
- One can initialize a variable with an explicitely given fixed type.
"""

# ╔═╡ 641d35ca-94a0-4b5b-949d-2a5d66ea3148
i::Int8=10

# ╔═╡ 12459a17-4698-4638-8bb5-d1aac23631f6
typeof(i)

# ╔═╡ 0d84c424-cf0e-40d6-864f-8b124e15d1f7
x::Float16=5.0

# ╔═╡ 21062f0c-0c27-4c53-b67d-7b6833f2d768
typeof(x)

# ╔═╡ b0fd81fe-01d3-11eb-19da-190f2787d98a
md"""
## Structs
- Structs allow to define custom types
"""

# ╔═╡ f61a4092-01d3-11eb-3460-5b62b5dae5de
struct MyColor64
    r::Float64
    g::Float64
    b::Float64
end

# ╔═╡ 17711ea0-01d4-11eb-2428-53f6e3d61d05
c=MyColor64(0.1,0.2,0.3)

# ╔═╡ 9411e2dc-0e6f-4215-88c4-3d49c557277b
typeof(c)

# ╔═╡ 07a8b083-76a4-4b5b-b9ad-b7f57cf8e71f
sizeof(c)

# ╔═╡ 0d6f4dc2-61fe-412d-9579-f9f21261f487
c.r

# ╔═╡ 1ec3d61b-bc1c-4b1d-9c37-07ce2c7fa774
c.r=10

# ╔═╡ 692540ec-4a6b-4f7b-bf71-e836e8016fc7
md"""
Mutable structs allow changing fields
"""

# ╔═╡ 4bf7abbe-2a39-4ce8-8560-5dee78a56909
mutable struct MMyColor64
	 r::Float64
    g::Float64
    b::Float64
end

# ╔═╡ 23ca8150-3bd4-473c-acb3-ab685f0cb9b0
mc=MMyColor64(0.1,0.2,0.3)

# ╔═╡ a46cf05e-92ad-4a9f-9bfe-02faf012634f
mc.r=0.4

# ╔═╡ e49b4557-2a20-4eb5-b592-14f721466c6d
mc

# ╔═╡ b2263d55-4bf7-4d4f-a9e6-a872a5dad450
md"""
(note that in this case Pluto's reactivity is tricked out ...)
"""

# ╔═╡ 2eedb7dc-01d4-11eb-0cd6-c7ec9611e2bd
md"""
Structs  can be parametrized with types. This is similar to array types which are parametrized by their element types
"""

# ╔═╡ 372503d0-01d4-11eb-1211-b9395834842a
struct MyColor{T}
    r::T
    g::T
    b::T
end

# ╔═╡ 4ef772e8-01d4-11eb-314a-ed0d1c24da77
c2=MyColor{Int64}(4,25.0,233.0)

# ╔═╡ 774a8d8f-fd07-496b-bf7f-7f442721d346
typeof(c2)

# ╔═╡ a982f8af-68c1-4545-a351-7fde9e25d914
sizeof(c2)

# ╔═╡ 986ffa5d-62bf-48e0-bb4b-669377ba7237
c3=MyColor{UInt8}(4,25,233)

# ╔═╡ 7cb956ad-9f06-4c6e-ad7b-e7a1e086acbb
typeof(c3)

# ╔═╡ daf1c291-70ba-4028-8b91-ba57a17a2af0
sizeof(c3)

# ╔═╡ c2be228a-01d4-11eb-243f-cf35c0ec0164
md"""
## Functions,  Methods and Multiple Dispatch
- Functions can have different variants of their implementation depending
  on the types of parameters passed to them
- These variants are called __methods__
- All methods of a function `f` can be listed calling `methods(f)`
- The act of figuring out which method of a function to call depending on
  the type of parameters is called __multiple dispatch__

"""

# ╔═╡ f5cc25e6-0954-11eb-179b-eddff99dd392
test_dispatch(x)="general case: $(typeof(x)), x=$(x)";

# ╔═╡ 0468c2da-0955-11eb-271b-5d84d5d8343d
test_dispatch(x::Float64)="special case Float64, x=$(x)";

# ╔═╡ d5072353-eb7c-4991-b4a8-1ee8c6b2e5c4
test_dispatch(x::AbstractFloat )="special case Float, x=$(x)";

# ╔═╡ 0cc7808a-0955-11eb-0b4d-ff491af88cf5
test_dispatch(x::Int64)="special case Int64, x=$(x)";

# ╔═╡ 125f7b0e-01d5-11eb-28ed-772426c25218
test_dispatch(3)

# ╔═╡ 4c81312e-01d5-11eb-0fd8-3be89232486b
test_dispatch(false)

# ╔═╡ 625bfc6a-01d5-11eb-25cf-259a7943063d
test_dispatch(3.0)

# ╔═╡ a2181ff8-c7b4-46b4-8b1d-5b2ddb48531b
Float32<:AbstractFloat

# ╔═╡ edb66fd2-5a76-4547-b40a-22e2dd9198db
test_dispatch(Float32(3.0))

# ╔═╡ 6d712526-01d5-11eb-3feb-e74c800fa893
md"""
Here we defined a generic method which works for any variable passed. In the case of `Int64` or `Float64` parameters, special cases are handeld by different methods of the same function. The compiler decides which method to call. This approach allows to specialize implemtations dependent on data types, e.g. in order to optimize perfomance.

The `methods` function can be used to figure out which methods of a function exists.
"""

# ╔═╡ ec9abf90-01d5-11eb-257b-f3a2f681c7b9
methods(test_dispatch)

# ╔═╡ ec5288ec-01d5-11eb-2b09-a96fbe8fc00f
md"""
The function/method concept somehow corresponds to [C++14 generic lambdas](https://isocpp.org/wiki/faq/cpp14-language#generic-lambdas)
````
auto myfunc=[](auto  &y, auto &y)
{
  y=sin(x);
};
````
is equivalent to
````
function myfunc!(y,x)
    y=sin(x)
end
````
Many [generic programming](https://en.wikipedia.org/wiki/Generic_programming) approaches possible in C++ also work in Julia,

If not specified otherwise via parameter types, Julia functions are generic: "automatic auto"
"""

# ╔═╡ c7194b4a-01d7-11eb-0175-fda4e2b3947a
md"""
## Abstract types
 - Abstract types label concepts which work for a several
   concrete types without regard to their memory layout etc.
 - All variables with concrete types corresponding to a given
   abstract type (should) share a common interface
 - A common interface consists of a set of functions with methods working for all 
   types exhibiting this interface
 - The functionality of an abstract type is implicitely characterized
   by the methods working on it
 - This concept is close to ["duck typing"](https://en.wikipedia.org/wiki/Duck_typing):
   use the "duck test" — "If it walks like a duck and it quacks like a duck, then it must be a duck" —
   to determine if an object can be used for a particular purpose

- When trying to force a parameter to have an abstract type,it ends up with having a conrete type which is compatible with that abstract type
"""

# ╔═╡ d776bf38-01d8-11eb-2765-43dc1dbc3344
md"""
 ### The type tree
 - Types can have subtypes and a supertype
 - Concrete types are the leaves of the resulting type tree
 - Supertypes are necessarily abstract
 - There is only one supertype for every (abstract or concrete) type
 - Abstract types can have several subtypes
"""

# ╔═╡ fd9463d4-01d8-11eb-0a87-f7924aa63bda
subtypes(AbstractFloat)

# ╔═╡ 21d47428-01d9-11eb-1a5e-73de9310fc01
md"""
 - Concrete types have no subtypes
"""

# ╔═╡ 0ce950e0-01d9-11eb-0345-bd84b69b7e0a
subtypes(Float64)

# ╔═╡ 162c1737-553a-40bf-969e-3b019789c8e1
supertype(Float64)

# ╔═╡ 426b745c-7a30-4419-a8ab-9eeb8d73d7b1
subtypes(AbstractFloat)

# ╔═╡ 01c01d74-ea2f-4401-92a4-04417368c1b3
supertype(AbstractFloat)

# ╔═╡ 91b552cc-8172-42dd-bb38-7c659ac36d2a
supertype(Real)

# ╔═╡ c6834da2-2466-11eb-26a3-8b760d0bed2b
supertype(Number)

# ╔═╡ 49f559c2-01d9-11eb-3fb0-a9dc6c3ab515
md"""
- "Any" is the root of the type tree and has itself as supertype
"""

# ╔═╡ 327f7c32-01d9-11eb-0d80-69042308ae71
supertype(Any)

# ╔═╡ 910831ea-01d9-11eb-359d-996096e2641c
md"""
We can use the `AbstractTrees` package to visualize the type tree. We just need  to define what it means to have children for a type.
"""

# ╔═╡ c66752b2-01d9-11eb-3c0e-cfe0e76253fd
AbstractTrees.children(x::Type) = subtypes(x)

# ╔═╡ ddf7a328-01d9-11eb-21b9-79c484f01134
AbstractTrees.print_tree(Number)

# ╔═╡ 6a7e7916-01da-11eb-2857-3fff96092457
md"""
There are operators for testing type relationships
"""

# ╔═╡ 76efc16e-01da-11eb-3a78-bd1c99b5c79e
 Float64<: Number

# ╔═╡ 7d5c58e6-01da-11eb-1c79-a7b650bf3dc4
 Float64<: Integer

# ╔═╡ 3c243910-2463-11eb-1a37-8da1192a193e
isa(3,Float64)

# ╔═╡ 494294a0-2463-11eb-1fea-eff0f59ccfee
isa(3.0,Float64)

# ╔═╡ 8384fe94-01da-11eb-1c96-47c7cf183364
md"""
Abstract types can be used for method dispatch as well
"""

# ╔═╡ 8ef2b906-01da-11eb-1641-01ce9253d537
begin
	dispatch2(x::AbstractFloat)="$(typeof(x)) <:AbstractFloat, x=$(x)"
	dispatch2(x::Integer)="$(typeof(x)) <:Integer, x=$(x)"
end

# ╔═╡ d3cdc5ca-01da-11eb-3c3b-2bb31eb037ee
dispatch2(13)

# ╔═╡ da2d5e80-01da-11eb-1642-b519a74b2a87
dispatch2(Float16(3))

# ╔═╡ f113e434-01da-11eb-15d2-edf4d0e13b20
md"""
## The power of multiple dispatch
 - Multiple dispatch is one of the defining features of Julia
 - Combined with the  the hierarchical type system it allows for
   powerful generic program design
 - New datatypes (different kinds of numbers, differently stored arrays/matrices) work with existing code
   once they implement the same interface as existent ones.
 - In some respects C++ comes close to it, but for the price of more  and less obvious code

"""

# ╔═╡ 9e651b5d-9d57-4887-ae02-0b4c95bf0f57
md"""
 Julia: just-in-time compilation and Performance
 ========================================
"""

# ╔═╡ a54ff08f-180a-481f-bfad-0562b6bd9a96
md"""

## The JIT
 - Just-in-time compilation is another feature setting Julia apart, as it was developed with this possibility in mind. 
 - Julia uses the tools from the [The LLVM Compiler Infrastructure Project](https://llvm.org) to organize on-the-fly compilation  of Julia code to machine code
 - Tradeoff: startup time for code execution in interactive situations
 - Multiple steps: Parse the code, analyze data types etc.
 - Intermediate results can be inspected using a number of macros (blue color in the diagram below) 

"""

# ╔═╡ 93fef7f4-1ef1-4c85-a23c-363184c85d13
html"""
 <img src="https://wias-berlin.de/people/fuhrmann/blobs/julia_introspect.png" width=600 valign=center/><br>

 <font size=-3> From <a href="https://docs.google.com/viewer?a=v&pid=sites&srcid=ZGVmYXVsdGRvbWFpbnxibG9uem9uaWNzfGd4OjMwZjI2YTYzNDNmY2UzMmE">Introduction to Writing High Performance Julia</a> by D. Robinson </font>

"""

# ╔═╡ d5da3d6f-8610-4b1f-8d0d-b23e59cb5f71
md"""
### An example
"""

# ╔═╡ 2c750c8c-c0f4-4800-bdab-cbaf17b55bb7
g(x,y)=x+y

# ╔═╡ df008f72-bc3a-464f-bf46-2403a781c7d1
md"""
Call with integer parameter:
"""

# ╔═╡ 10312972-571d-4181-8a5b-698c18c92f48
g(2,3)

# ╔═╡ ee8e1ebd-6f6b-49ff-b2bc-112571343d51
md"""
Call with floating point parameter:
"""

# ╔═╡ 5f8f3958-72b8-4ddc-8a14-e9972d5cb3f6
g(2.0,3.0)

# ╔═╡ 81fd1d8d-fee0-4c98-912b-b7ab4a7d87fd
md"""
 The macro `@code_lowered` describes the abstract syntax tree behind the code
"""

# ╔═╡ 3b36e468-da61-4b52-b1a6-f140d18c3575
@code_lowered g(2,3)

# ╔═╡ 924c6d42-174c-4a53-97e7-5d88b30c78d1
@code_lowered g(2.0,3.0)

# ╔═╡ fd028da6-dea6-4875-85e5-61244df020af
md"""
 `@code_warntype` (with output to terminal) provides the result of type inference  (detection ot the parameter types and coorsponding choice of the translation strategy) according to the input:
"""

# ╔═╡ e0489718-c01a-438f-9631-b15df4e2a14f
@code_warntype g(2,3)

# ╔═╡ 6af34b5d-5a1d-456f-b089-aea438a9d52d
@code_warntype g(2.0,3.0)

# ╔═╡ 68b45006-25c9-4816-a685-0f4c9a79909f
md"""
 `@code_llvm` prints the LLVM intermediate byte code representation:
"""

# ╔═╡ f3ced291-9749-42cd-ad0b-dfe95eb59655
@code_llvm g(2,3)

# ╔═╡ 8a88b912-7588-449b-964d-5e1cba3ae8a1
@code_llvm g(2.0,3.0)

# ╔═╡ 42283839-aa77-4fb3-a628-89185575d639
md"""
 Finally, `@code_native` prints the assembler code generated, which is a close match to the machine code sent to the CPU:
"""

# ╔═╡ 5eb898be-929a-4154-876b-f60c8a190fd3
@code_native g(2,3)

# ╔═╡ 5691be67-eb79-435b-81c1-433e263c3985
@code_native g(2.0,3.0)

# ╔═╡ 8e53a5f1-1643-4cfa-ae29-03792108c5cb
md"""
We see that for the very same function, Julia creates different variants of executable code depending on the data types of the parameters passed. In certain sense, this extends the multiple dispatch paradigm to the lower level by automatically created methods.

"""

# ╔═╡ e87f9f70-c209-41b6-9518-7a3c09c289ee
md"""
## Performance measurment
- Julia provides a number of macros to support performance testing.

- Performance measurement of the first invocation of a function includes the compilation step. If in doubt, measure timing twice.

- Pluto has the nice feature to indicate the execution time used below the lower right corner of a cell. There seems to be also some overhead hidden in the pluto cell handling which is however not measured.
"""


# ╔═╡ 32ad954d-d4ab-466a-b6f2-3ad28364be56
md"""
`@elapsed`: wall clock time used returned as a number.
"""


# ╔═╡ eccf10f2-9c21-492b-a424-cdb0e9f3dda9
f(n1,n2)= mapreduce(x->norm(x,2),+,[rand(n1) for i=1:n2])


# ╔═╡ 80ddb551-1908-4e9f-9fae-1fc32fe7d930
f(1000,1000)

# ╔═╡ 3645aad9-fcae-4f79-b040-4edf5305e3af
function f_loop(n1, n2)
    total = 0.0                     # accumulator
    for i in 1:n2                    # loop over n2 vectors
        v = rand(n1)                 # generate random vector of length n1
        total += norm(v, 2)          # compute 2-norm and add to total
    end
    return total
end

# ╔═╡ e371bee0-a252-468d-aa26-b6052b95c862
@elapsed f_loop(1000,1000)

# ╔═╡ 4f27c7a1-813b-49d5-a646-8fe14216b9da
@elapsed f(1000,1000)


# ╔═╡ 91e50256-c03d-4314-a876-014eff843fe4
A = [rand(2) for i=1:3]

# ╔═╡ 295b66c6-f956-4908-a5ba-4fcb8e5b0aa4
A[1]

# ╔═╡ 11e5c0d6-8982-4fd2-9b9b-1c7ffcac7ebb
f(2,3)

# ╔═╡ 7cabdaef-e3b4-4caa-84d3-c3fb70f7c457
norm([3.0, 4.0],2.0)

# ╔═╡ 89528c0f-ed7d-4e8a-b962-7d3bf921050f
fs(n1,n2)= [norm([rand(n1)],2) for i=1:n2]

# ╔═╡ 20f02b0f-3101-4c59-a95e-358a352de252
fs(2,3)

# ╔═╡ de9665f7-e7c3-4321-b9ad-167d79e9e555
md"""
- `@allocated`: sum of memory allocated (including temporary) during the excution of the code. For storing intermediate and final calculation results, computer languages request memory from the operating system. This process is called allocation. Allocations as a rule are linked with lots of bookkeeping, so they can slow down code.
"""


# ╔═╡ 993d5f75-e5ac-4155-b1a3-f35475b5892b
@allocated f(1000,1000)

# ╔═╡ 4a0571f5-67d7-401b-906d-76fab33a51a9
md"""
`@time`: `@elapsed` and `@allocated` together, with output to the terminal.
   Be careful to time at least twice in order to take into account compilation time.
   In addition, the number of allocations is printed along with time spent for garbage    collection. Garbage collection is the process of returning unused (temporary)     memory to the system.
"""

# ╔═╡ 2a56a207-2a0c-4ac1-9394-6ac7a51449e7
@time f(1000,1000)

# ╔═╡ 1b1d875a-31ef-41ce-9790-3a746bf01f20
md"""
`@benchmark` from `BenchmarkTools.jl` creates a statistic over multiple samples in order to give a more reliable estimate.
"""


# ╔═╡ bb66ec1f-3b7a-4e60-9f91-a2682cbef934
@benchmark f(1000,1000)

# ╔═╡ 4203e018-d233-4a36-b43e-9b4c2bced17a
md"""
## Some performance gotchas

In order to write efficient Julia code, a number recommendations should be followed.
!!! link to marginalia
### Gotcha #1: global variables
"""


# ╔═╡ 8759c63c-fea4-498a-a52a-5992cb941f52
myvec=ones(Float64,1_000_000)

# ╔═╡ 864e0651-7db6-4c3a-b1ed-7e0d150f94a4
@elapsed sum(myvec)

# ╔═╡ 96d5ab54-0842-4518-b63f-e7095c09ba0b
function mysum(v)
    x=0.0
    for i=1:length(v)
        x=x+v[i]
	end
    return x
end;

# ╔═╡ 25ccbb02-0907-45e4-97cb-31e6e800ae35
@elapsed mysum(myvec)

# ╔═╡ f1775706-8f61-4ef1-8c2e-beaecf8c0f50
@elapsed begin
	x1=0.0
    for i=1:length(myvec)
        x1=x1+myvec[i]
    end
end

# ╔═╡ ea56d8c3-1f71-4f84-9d4a-c0b09fc57f89
md"""
- Observation: both the begin/end block and the function do the same operation and calculate the same value. However the function is faster.

- The code within the begin/end clause works in the _global context_, whereas in `myfunc`, it works in the scope of  a function. Julia is unable to dispatch on variable types in the global scope as they can change their type anytime. In the global context it has to put all variables into "boxes" tagged with type information allowing to dispatch on their type at runtime (this is by the way the default mode of Python). In functions, it has a chance to generate specific code for known types.

- This situation als occurs in the REPL.
		
- Conclusion: __Avoid  [Julia Gotcha #1](http://www.stochasticlifestyle.com/7-julia-gotchas-handle/) by wrapping time critical code into functions and avoiding the use of global variables.__

- In fact it is anyway good coding style to separate out pieces of code into functions

"""


# ╔═╡ af35b74a-6d9c-4599-a4a6-ea24ca1063f6
md"""
### Gotcha #2: type instabilities
"""


# ╔═╡ fb908ace-f097-440e-822b-f6bc974ceb4f
function f1(n)
  x=1
  for i = 1:n
    x = x/2 
  end
	x
end


# ╔═╡ 4963f0ba-6361-4235-b351-e5946d2d4da2
function f2(n)
  x=1.0
  for i = 1:n
    x = x/2.0
  end
x
end


# ╔═╡ a9899c50-6444-45f9-b2fb-7ce233cb5043
@benchmark f1(100)

# ╔═╡ b6bd3ca7-313b-4cfd-8536-b0043118f2b3
@benchmark f2(100)

# ╔═╡ 2aa7b09e-fe55-4be2-9d1f-d45acc8c46cb
md""" 
Observation: function `f2` is faster than `f1` for the same operations.
(the difference was larger in older versions of Julia...)
"""

# ╔═╡ 0796ad6e-e5cf-442e-abcf-60b886e0fc07
@code_warntype f1(10)

# ╔═╡ 6761f93d-a882-4b9f-9c94-87cb4a2b77d7
@code_warntype f2(10)

# ╔═╡ 14cfa08d-384b-4d77-b4b3-ab85e34bb37f
md"""
- Extra care has to be taken to handle x: in `f1()` it changes its type from Int64 to Float64. We see this with the union type for x in @code_warntype
	
- Conclusion: __Avoid  [Julia Gotcha #2](http://www.stochasticlifestyle.com/7-julia-gotchas-handle/) by ensuring variables keep their type also in functions__.
"""


# ╔═╡ 3887588a-d725-4bf7-a3ef-2cda792a5abe
md"""
### Gotcha #6: allocations
"""


# ╔═╡ 0cf5223b-3c6b-43e1-9ac9-fc3b9c700fdf
mymat=rand(10,100_000)

# ╔═╡ a85a8c75-721d-4ba8-8a39-f8706e24657e
md"""
- Define three different ways of summing of squares of matrix columns:
"""


# ╔═╡ 5b8021aa-0cf4-41bf-9b6e-d9de0dfee7d0
function g1(a)
	y=0.0
	for j=1:size(a,2)
		for i=1:size(a,1)
			y=y+a[i,j]^2
		end
	end
	y
end

# ╔═╡ df50db60-f371-481a-9f2c-72e401683bcf
function g2(a)
    y=0.0
	for j=1:size(a,2)
		y=y+mapreduce(z->z^2,+,a[:,j])
	end
	y
end

# ╔═╡ 41051bef-f6fd-445d-a505-b5451fa68703
function g3(a)
    y=0.0
	for j=1:size(a,2)
		@views y=y+mapreduce(z->z^2,+,a[:,j])
	end
	y
end


# ╔═╡ 963413ac-01b5-433d-8e81-b0b8c219a236
g1(mymat)≈ g2(mymat) && g2(mymat)≈ g3(mymat)

# ╔═╡ 183ea00a-c501-480e-a3f6-0a53a87d9e11
@benchmark g1(mymat)

# ╔═╡ 095c3969-2fe1-4380-a969-9d7b495a9c3a
@benchmark g2(mymat)

# ╔═╡ aeb75809-b8f0-43d7-87f0-6943d54cd0b9
@benchmark g3(mymat)

# ╔═╡ d611e703-8bd1-43c5-8069-dfdd4d632bed
md"""
- Observation: g3 is the fastest implemetation, then comes g1 and then g2.

- The difference between g2 and g1  is that each time we use a matrix slice `a[:,i]`,
  memory is allocated and data copied. Only then the mapreduce is employed, and the
  intermediate memory is garbage collected.
- The difference between g2 and g1 lies in the use of the `@views` macro which allows to  avoid the creation of intermediae memory for matrix rows.

- Conclusion: avoid [Gotcha #6](http://www.stochasticlifestyle.com/7-julia-gotchas-handle/) __by carefully checking your code for allocations__ and avoiding the use of temporary memory.
"""


# ╔═╡ a71343c6-7a8b-4936-a926-7ff04223051a
md"""
# Memory handling: allocations and all that

All variable data of running computer code is stored in the main memory (RAM).
This is true for almost any computer language.

There are however details of the way data is stored which have  a heavy impact on code performance and flexibility of code design.
"""


# ╔═╡ 944906b9-2b5b-4407-8c59-01cd0e7d8ab8
md"""
## The stack

- The stack is a memory region created when a program starts, which is implicitely passed to all functions subsequently called, providing memory space for storing local variables 

- The name comes from the data structure behind. Besides of the memory it is characterized by a _stack pointer_ which separated the unused space from the used one. 
   - When putting data on the stack, these are copied to the position indicated by the stack pointer, and its value is increased accordingly
   - Removing data from the stack just amounts to decreasing the stack pointer

-  Any time a function is called, the current position in the  instruction stream is stored in the stack as the return address, and the called function is allowed to work with the stack space following  this storage location

"""


# ╔═╡ 53ef8115-4040-4655-b25c-7764ff26ae4c
htl"""
<div>
<div style= "width: 300px; display: inline-block;">




<pre>
function DrawLine(x0,y0,x1,y1)
  ... perform some drawing ... 
end




function DrawSquare(x0,y0,a)
   xa=x0+a
   ya=y0+a
   DrawLine(x0,y0,xa,y0)
   DrawLine(xa,y0,xa,ya)
   DrawLine(xa,ya,x0,ya)
   DrawLine(x0,ya,x0,y0)
end




</pre>
</div>
<div style= "width: 350px;  display: inline-block;">
$(Resource("https://upload.wikimedia.org/wikipedia/commons/d/d3/Call_stack_layout.svg"))
<font size=-2> Drawing by R. S. Shaw, Public Domain</font>
</div>
</div>
"""


# ╔═╡ 873836d1-00c5-49ca-bc5a-8f3a0d29fd72
md"""
- `DrawSquarw` takes space from the stack to store its local variables `xa` and `ya`.
- In the four calls to `DrawLine`, each time, the parameters are copied on the stack, and  current pointer in the instruction stream is stored on the stack as the address to return to after finishing the call
- During execution, `DrawLine` ma put its own local variables on the stack and call other functions
- After returning from the call, everything on top of the local data of `DrawSquare` is "forgotten"

"""


# ╔═╡ 00b9f9af-eac4-40c6-82d9-a414a3eac91c
function euler_sum_stack(n; e=BigFloat(1.0),k=1,kfac=BigFloat(1.0))
	if k<n
		kfac=kfac*k
		euler_sum_stack(n,e=e+1/kfac,k=k+1,kfac=kfac)
	else
		e
	end
end


# ╔═╡ 5f95d9d7-4529-4412-b24c-98ca887e7957
md"""
Did we do the right thing ?
"""

# ╔═╡ d8d915de-1e71-4ebc-96de-f5a155c184aa
abs(euler_sum_stack(10)-ℯ)

# ╔═╡ d5c83967-1f80-44fb-91fe-ac5fb40b33e1
md"""
Now let us try to  become more accurate:
"""

# ╔═╡ 098ba97b-3126-4423-a50f-239e6e854edc
euler_sum_stack(100_000)

# ╔═╡ 6d80bed8-8083-48bf-9e58-525885d5a712
md"""
### Stack space is scarce!

When a program starts, it obtains from the system a fixed amount of memory for its stack. During program run it cannot be increased. It's size however can be configured before the program  starts.
"""


# ╔═╡ a0f122cc-343d-4805-a2bc-aff4918a226d
md"""
## The heap - the place for large amounts of data

- Chunks from free system memory can be reserved --  "allocated" -- on demand in order to provide memory space for data
- Unlike the handling of the stack pointer, allocating memory is connected with lots of bookkeeping, so it is quite expensive
- In languages like C, C++, this is an explicit operation (`malloc`, `new`)
- In Julia, the placement depends on the data type, though in principle the compiler could  optimize allocations away if it knows that this is save
   - heap: Arrays, Dicts, mutable structs
   - stack: Numbers, Tuples, structs, Arrays from [StaticArrays.jl](https://github.com/JuliaArrays/StaticArrays.jl), array views  
   - also see this [Discourse thread](https://discourse.julialang.org/t/a-nice-explanation-of-memory-stack-vs-heap/53915/2)
"""


# ╔═╡ 539c11d2-a8db-4ae9-8caf-f17626ebf3c8
md"""
### Allocations are expensive!
"""


# ╔═╡ e921e547-7f51-4501-b022-eb7f31df8bc4
function normal_array()
    arr = [1.,2.0,3.0]
    return arr.^2
end

# ╔═╡ 28e5c6f3-f351-4698-9072-48e05bf748ec
function static_array()
    arr = StaticArrays.SVector(1.,2,3)
    return arr.^2
end


# ╔═╡ 46d134b5-1d99-4b1f-bca9-4c405997172c
@benchmark normal_array()

# ╔═╡ 0714047e-af7e-4275-9d8a-4b001e287887
@benchmark static_array()

# ╔═╡ 92a170eb-b547-475e-9a3e-88727a7c3296
md"""
- We see a significant increase of runtime: an allocation can be several hundred times more expensive than a floating point operation
- Avoiding allocations is an important step when optimizing Julia code
- One strategy is to work with tuples and SVectors which however must have their size fixed at compile time
- Alternatively, turn functions into mutating functions which work on space passed to them which has been allocated before
"""


# ╔═╡ da83fada-6e7d-4635-9b05-a6aa3861466a
a=rand(1000)

# ╔═╡ 03f9b25d-277a-45a0-bfac-64a44c4b34a5
function functional_function(a)
	return a.^2
end

# ╔═╡ 06e216f8-1dce-4c04-a373-f4d40122710f
function mutating_function!(result,a)
	result.=a.^2
	result
end

# ╔═╡ ced7343f-e27b-4718-9df6-2fd8f3209888
@benchmark functional_function(a)

# ╔═╡ 611d13c5-580d-4c75-bb15-5ccf76cad4d8
result=similar(a)

# ╔═╡ 1ba0d265-fe96-4a15-9ca6-253561d6b3a4
functional_function(a)≈mutating_function!(result,a)

# ╔═╡ f1b018cb-0121-46f1-b48b-8ec7ce47b52b
@benchmark mutating_function!(result,a)

# ╔═╡ 2072f5d3-0a67-4267-8cae-a51b0351d3e7
md"""
This pattern shows how to avoid allocations in some often called function by pre-allocating memory for the result.
"""

# ╔═╡ 0a6d37cb-949f-4bb1-a33a-b5a4cc87ec04
md"""
## How to release allocated memory ?

- In languages like C and C++,  there are explicit statements for releasing memory allocated at the heap (`free`, `delete`)
- Julia has a _Garbage Collector_ (GC) which keeps track of memory usage and frees memory once it is not needed anymore. It automatically runs between statements.
"""


# ╔═╡ 0681a974-4ad5-4535-8dc0-ae2dc49592f9
html"""<hr>"""

# ╔═╡ ebe622af-2850-4af2-b1ea-d11daf728526
begin
     
    highlight(mdstring,color)= htl"""<blockquote style="padding: 10px; background-color: $(color);">$(mdstring)</blockquote>"""
	
	macro important_str(s)	:(highlight(Markdown.parse($s),"#ffcccc")) end
	macro definition_str(s)	:(highlight(Markdown.parse($s),"#ccccff")) end
	macro statement_str(s)	:(highlight(Markdown.parse($s),"#ccffcc")) end
		
		
    html"""
    <style>
     h1{background-color:#dddddd;  padding: 10px;}
     h2{background-color:#e7e7e7;  padding: 10px;}
     h3{background-color:#eeeeee;  padding: 10px;}
     h4{background-color:#f7f7f7;  padding: 10px;}

	pluto-log-dot-sizer { max-width: 655px;}
     pluto-log-dot.Stdout {
	 background: #002000;
     color: #10f080;
     border: 6px solid #b7b7b7;
     min-width: 18em;
     max-height: 300px;
     width: 675px;
     overflow: auto;
	}
	
    </style>
"""
end


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AbstractTrees = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
InteractiveUtils = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[compat]
AbstractTrees = "~0.4.2"
BenchmarkTools = "~1.3.1"
HypertextLiteral = "~0.9.4"
PlutoUI = "~0.7.44"
StaticArrays = "~1.5.9"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.0"
manifest_format = "2.0"
project_hash = "40881df9602a7b2dab646f8ee430f5f13ea23e0d"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.AbstractTrees]]
git-tree-sha1 = "5c0b629df8a5566a06f5fef5100b53ea56e465a0"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "4c10eee4af024676200bc7752e536f858c6b8f93"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.1"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+1"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+2"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "6c01a9b494f6d2a9fc180a08b182fcb06f0958a0"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "6e33d318cf8843dade925e35162992145b4eb12f"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.44"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "f86b3a049e5d05227b10e15dbb315c5b90f14988"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.9"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╟─ba776d72-160c-41b9-b4c8-4b693f41c280
# ╠═baf88246-01d1-11eb-3d35-1393445b1476
# ╠═3f4a405b-ada1-45b6-ade7-efb57dd22d79
# ╟─1b221e84-01d2-11eb-3e46-67e2a59b03dc
# ╠═13ccfef0-01d3-11eb-0be7-87721fe2c996
# ╠═3b84bb40-01d3-11eb-1416-db63210faba4
# ╠═7462dc44-01d3-11eb-310e-3f6d6b6a7a4f
# ╠═802e2ace-01d3-11eb-039a-fff2bbc9b2a3
# ╠═45de6c76-01d3-11eb-0e9d-47f8108ba1b4
# ╠═4c6a79ea-01d3-11eb-268e-c32f7a6c85cd
# ╠═c924835e-01d3-11eb-0fcb-0d7d4050b32c
# ╠═d2cca0be-01d3-11eb-017f-5f72d26f23ba
# ╟─fb556f26-01d2-11eb-0244-d353d4ae0c9d
# ╠═641d35ca-94a0-4b5b-949d-2a5d66ea3148
# ╠═12459a17-4698-4638-8bb5-d1aac23631f6
# ╠═0d84c424-cf0e-40d6-864f-8b124e15d1f7
# ╠═21062f0c-0c27-4c53-b67d-7b6833f2d768
# ╟─b0fd81fe-01d3-11eb-19da-190f2787d98a
# ╠═f61a4092-01d3-11eb-3460-5b62b5dae5de
# ╠═17711ea0-01d4-11eb-2428-53f6e3d61d05
# ╠═9411e2dc-0e6f-4215-88c4-3d49c557277b
# ╠═07a8b083-76a4-4b5b-b9ad-b7f57cf8e71f
# ╠═0d6f4dc2-61fe-412d-9579-f9f21261f487
# ╠═1ec3d61b-bc1c-4b1d-9c37-07ce2c7fa774
# ╟─692540ec-4a6b-4f7b-bf71-e836e8016fc7
# ╠═4bf7abbe-2a39-4ce8-8560-5dee78a56909
# ╠═23ca8150-3bd4-473c-acb3-ab685f0cb9b0
# ╠═a46cf05e-92ad-4a9f-9bfe-02faf012634f
# ╠═e49b4557-2a20-4eb5-b592-14f721466c6d
# ╟─b2263d55-4bf7-4d4f-a9e6-a872a5dad450
# ╟─2eedb7dc-01d4-11eb-0cd6-c7ec9611e2bd
# ╠═372503d0-01d4-11eb-1211-b9395834842a
# ╠═4ef772e8-01d4-11eb-314a-ed0d1c24da77
# ╠═774a8d8f-fd07-496b-bf7f-7f442721d346
# ╠═a982f8af-68c1-4545-a351-7fde9e25d914
# ╠═986ffa5d-62bf-48e0-bb4b-669377ba7237
# ╠═7cb956ad-9f06-4c6e-ad7b-e7a1e086acbb
# ╠═daf1c291-70ba-4028-8b91-ba57a17a2af0
# ╟─c2be228a-01d4-11eb-243f-cf35c0ec0164
# ╠═f5cc25e6-0954-11eb-179b-eddff99dd392
# ╠═0468c2da-0955-11eb-271b-5d84d5d8343d
# ╠═d5072353-eb7c-4991-b4a8-1ee8c6b2e5c4
# ╠═0cc7808a-0955-11eb-0b4d-ff491af88cf5
# ╠═125f7b0e-01d5-11eb-28ed-772426c25218
# ╠═4c81312e-01d5-11eb-0fd8-3be89232486b
# ╠═625bfc6a-01d5-11eb-25cf-259a7943063d
# ╠═a2181ff8-c7b4-46b4-8b1d-5b2ddb48531b
# ╠═edb66fd2-5a76-4547-b40a-22e2dd9198db
# ╟─6d712526-01d5-11eb-3feb-e74c800fa893
# ╠═ec9abf90-01d5-11eb-257b-f3a2f681c7b9
# ╟─ec5288ec-01d5-11eb-2b09-a96fbe8fc00f
# ╟─c7194b4a-01d7-11eb-0175-fda4e2b3947a
# ╟─d776bf38-01d8-11eb-2765-43dc1dbc3344
# ╠═fd9463d4-01d8-11eb-0a87-f7924aa63bda
# ╟─21d47428-01d9-11eb-1a5e-73de9310fc01
# ╠═0ce950e0-01d9-11eb-0345-bd84b69b7e0a
# ╠═162c1737-553a-40bf-969e-3b019789c8e1
# ╠═426b745c-7a30-4419-a8ab-9eeb8d73d7b1
# ╠═01c01d74-ea2f-4401-92a4-04417368c1b3
# ╠═91b552cc-8172-42dd-bb38-7c659ac36d2a
# ╠═c6834da2-2466-11eb-26a3-8b760d0bed2b
# ╟─49f559c2-01d9-11eb-3fb0-a9dc6c3ab515
# ╠═327f7c32-01d9-11eb-0d80-69042308ae71
# ╟─910831ea-01d9-11eb-359d-996096e2641c
# ╠═c66752b2-01d9-11eb-3c0e-cfe0e76253fd
# ╠═ddf7a328-01d9-11eb-21b9-79c484f01134
# ╟─6a7e7916-01da-11eb-2857-3fff96092457
# ╠═76efc16e-01da-11eb-3a78-bd1c99b5c79e
# ╠═7d5c58e6-01da-11eb-1c79-a7b650bf3dc4
# ╠═3c243910-2463-11eb-1a37-8da1192a193e
# ╠═494294a0-2463-11eb-1fea-eff0f59ccfee
# ╟─8384fe94-01da-11eb-1c96-47c7cf183364
# ╠═8ef2b906-01da-11eb-1641-01ce9253d537
# ╠═d3cdc5ca-01da-11eb-3c3b-2bb31eb037ee
# ╠═da2d5e80-01da-11eb-1642-b519a74b2a87
# ╟─f113e434-01da-11eb-15d2-edf4d0e13b20
# ╟─9e651b5d-9d57-4887-ae02-0b4c95bf0f57
# ╠═a54ff08f-180a-481f-bfad-0562b6bd9a96
# ╠═93fef7f4-1ef1-4c85-a23c-363184c85d13
# ╟─d5da3d6f-8610-4b1f-8d0d-b23e59cb5f71
# ╠═2c750c8c-c0f4-4800-bdab-cbaf17b55bb7
# ╟─df008f72-bc3a-464f-bf46-2403a781c7d1
# ╠═10312972-571d-4181-8a5b-698c18c92f48
# ╟─ee8e1ebd-6f6b-49ff-b2bc-112571343d51
# ╠═5f8f3958-72b8-4ddc-8a14-e9972d5cb3f6
# ╟─81fd1d8d-fee0-4c98-912b-b7ab4a7d87fd
# ╠═3b36e468-da61-4b52-b1a6-f140d18c3575
# ╠═924c6d42-174c-4a53-97e7-5d88b30c78d1
# ╟─fd028da6-dea6-4875-85e5-61244df020af
# ╠═e0489718-c01a-438f-9631-b15df4e2a14f
# ╠═6af34b5d-5a1d-456f-b089-aea438a9d52d
# ╠═68b45006-25c9-4816-a685-0f4c9a79909f
# ╠═f3ced291-9749-42cd-ad0b-dfe95eb59655
# ╠═8a88b912-7588-449b-964d-5e1cba3ae8a1
# ╠═42283839-aa77-4fb3-a628-89185575d639
# ╠═5eb898be-929a-4154-876b-f60c8a190fd3
# ╠═5691be67-eb79-435b-81c1-433e263c3985
# ╟─8e53a5f1-1643-4cfa-ae29-03792108c5cb
# ╟─e87f9f70-c209-41b6-9518-7a3c09c289ee
# ╟─32ad954d-d4ab-466a-b6f2-3ad28364be56
# ╠═eccf10f2-9c21-492b-a424-cdb0e9f3dda9
# ╠═80ddb551-1908-4e9f-9fae-1fc32fe7d930
# ╠═3645aad9-fcae-4f79-b040-4edf5305e3af
# ╠═e371bee0-a252-468d-aa26-b6052b95c862
# ╠═4f27c7a1-813b-49d5-a646-8fe14216b9da
# ╠═91e50256-c03d-4314-a876-014eff843fe4
# ╠═295b66c6-f956-4908-a5ba-4fcb8e5b0aa4
# ╠═11e5c0d6-8982-4fd2-9b9b-1c7ffcac7ebb
# ╠═7cabdaef-e3b4-4caa-84d3-c3fb70f7c457
# ╠═89528c0f-ed7d-4e8a-b962-7d3bf921050f
# ╠═20f02b0f-3101-4c59-a95e-358a352de252
# ╟─de9665f7-e7c3-4321-b9ad-167d79e9e555
# ╠═993d5f75-e5ac-4155-b1a3-f35475b5892b
# ╟─4a0571f5-67d7-401b-906d-76fab33a51a9
# ╠═2a56a207-2a0c-4ac1-9394-6ac7a51449e7
# ╟─1b1d875a-31ef-41ce-9790-3a746bf01f20
# ╠═bb66ec1f-3b7a-4e60-9f91-a2682cbef934
# ╟─4203e018-d233-4a36-b43e-9b4c2bced17a
# ╠═8759c63c-fea4-498a-a52a-5992cb941f52
# ╠═864e0651-7db6-4c3a-b1ed-7e0d150f94a4
# ╠═96d5ab54-0842-4518-b63f-e7095c09ba0b
# ╠═25ccbb02-0907-45e4-97cb-31e6e800ae35
# ╠═f1775706-8f61-4ef1-8c2e-beaecf8c0f50
# ╟─ea56d8c3-1f71-4f84-9d4a-c0b09fc57f89
# ╟─af35b74a-6d9c-4599-a4a6-ea24ca1063f6
# ╠═fb908ace-f097-440e-822b-f6bc974ceb4f
# ╠═4963f0ba-6361-4235-b351-e5946d2d4da2
# ╠═a9899c50-6444-45f9-b2fb-7ce233cb5043
# ╠═b6bd3ca7-313b-4cfd-8536-b0043118f2b3
# ╟─2aa7b09e-fe55-4be2-9d1f-d45acc8c46cb
# ╠═0796ad6e-e5cf-442e-abcf-60b886e0fc07
# ╠═6761f93d-a882-4b9f-9c94-87cb4a2b77d7
# ╟─14cfa08d-384b-4d77-b4b3-ab85e34bb37f
# ╟─3887588a-d725-4bf7-a3ef-2cda792a5abe
# ╠═0cf5223b-3c6b-43e1-9ac9-fc3b9c700fdf
# ╟─a85a8c75-721d-4ba8-8a39-f8706e24657e
# ╠═5b8021aa-0cf4-41bf-9b6e-d9de0dfee7d0
# ╠═df50db60-f371-481a-9f2c-72e401683bcf
# ╠═41051bef-f6fd-445d-a505-b5451fa68703
# ╠═963413ac-01b5-433d-8e81-b0b8c219a236
# ╠═183ea00a-c501-480e-a3f6-0a53a87d9e11
# ╠═095c3969-2fe1-4380-a969-9d7b495a9c3a
# ╠═aeb75809-b8f0-43d7-87f0-6943d54cd0b9
# ╟─d611e703-8bd1-43c5-8069-dfdd4d632bed
# ╟─a71343c6-7a8b-4936-a926-7ff04223051a
# ╟─944906b9-2b5b-4407-8c59-01cd0e7d8ab8
# ╟─53ef8115-4040-4655-b25c-7764ff26ae4c
# ╟─873836d1-00c5-49ca-bc5a-8f3a0d29fd72
# ╠═00b9f9af-eac4-40c6-82d9-a414a3eac91c
# ╟─5f95d9d7-4529-4412-b24c-98ca887e7957
# ╠═d8d915de-1e71-4ebc-96de-f5a155c184aa
# ╟─d5c83967-1f80-44fb-91fe-ac5fb40b33e1
# ╠═098ba97b-3126-4423-a50f-239e6e854edc
# ╟─6d80bed8-8083-48bf-9e58-525885d5a712
# ╟─a0f122cc-343d-4805-a2bc-aff4918a226d
# ╟─539c11d2-a8db-4ae9-8caf-f17626ebf3c8
# ╠═e921e547-7f51-4501-b022-eb7f31df8bc4
# ╠═28e5c6f3-f351-4698-9072-48e05bf748ec
# ╠═46d134b5-1d99-4b1f-bca9-4c405997172c
# ╠═0714047e-af7e-4275-9d8a-4b001e287887
# ╟─92a170eb-b547-475e-9a3e-88727a7c3296
# ╠═da83fada-6e7d-4635-9b05-a6aa3861466a
# ╠═03f9b25d-277a-45a0-bfac-64a44c4b34a5
# ╠═06e216f8-1dce-4c04-a373-f4d40122710f
# ╠═1ba0d265-fe96-4a15-9ca6-253561d6b3a4
# ╠═ced7343f-e27b-4718-9df6-2fd8f3209888
# ╠═611d13c5-580d-4c75-bb15-5ccf76cad4d8
# ╠═f1b018cb-0121-46f1-b48b-8ec7ce47b52b
# ╟─2072f5d3-0a67-4267-8cae-a51b0351d3e7
# ╟─0a6d37cb-949f-4bb1-a33a-b5a4cc87ec04
# ╠═0681a974-4ad5-4535-8dc0-ae2dc49592f9
# ╠═3daaaca4-5704-4d1b-b035-2450fb219a91
# ╠═ebe622af-2850-4af2-b1ea-d11daf728526
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
