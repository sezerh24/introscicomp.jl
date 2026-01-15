using Flux
predict(W, b, x) = W*x .+b 

function loss(W, b, x, y)
    ŷ = predict(W,b,x)
    return sum((y .- ŷ).^2)
end

x, y = rand(5), rand(2) # dummy data

W = rand(2,5)
b = rand(2)

loss(W,b,x,y)

dW, db = gradient((W,b)-> loss(W,b,x,y), W, b)

## Building layers 
W1 = rand(3,5)
b1 = rand(3)

layer1(x) = W1*x .+ b1

W2 = rand(2,3)
b2 = rand(2)
layer2(x) = W2*x .+ b2

model(x) = layer2(sigmoid.(layer1(x)))

model(rand(5))

#=
This works but is fairly unwieldy, with a lot of repetition – especially as we add more layers. 
One way to factor this out is to create a function that returns linear layers.
=#

function linear(in, out)
    W = randn(out, in)
    b = randn(out)
    x -> W * x .+ b
  end
  
  linear1 = linear(5, 3) # we can access linear1.W etc
  linear2 = linear(3, 2)
  
  model(x) = linear2(sigmoid.(linear1(x)))
  
  model(rand(5)) # => 2-element vector

#  Another (equivalent) way is to create a struct that explicitly represents the affine layer
struct Affine
    W
    b
  end

  Affine(in::Integer, out::Integer) = Affine(randn(out, in), zeros(out))

# Overload call, so the object can be used as a function
(m::Affine)(x) = m.W * x .+ m.b

a = Affine(10, 5)

a(rand(10))



# Initialize variables
ii = 1
current_layer = 1  # Assuming you have already defined this
Layer_Numb = 10

# Loop until current_layer exceeds Layer_Numb
while current_layer <= Layer_Numb
    ii += 1  # Increment ii
    current_layer += 1  # Update current_layer to avoid infinite loop
end

# Print the final value of ii
println("Final value of ii: $ii")


