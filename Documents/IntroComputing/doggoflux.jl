using Flux
using MLDatasets
using Images
using Plots

using LinearAlgebra, Random, Statistics

x_train_raw, y_train_raw = MLDatasets.MNIST.traindata(Float32)
x_test_raw, y_test_raw = MLDatasets.MNIST.testdata(Float32)

# view training input 
x_train_raw 

img = x_train_raw[:,:,1];
colorview(Gray, img')

y_train_raw[1]

x_test_raw 
img = x_test_raw[:,:,1]
colorview(Gray, img')

# flatten input data 
x_train = Flux.flatten(x_train_raw);
x_test = Flux.flatten(x_test_raw);

y_train = onehotbatch(y_train_raw,0:9);
y_test = onehotbatch(y_test_raw,0:9);

model = Chain(
    Dense(28*28,20,σ), Dense(20,10), softmax
)

loss(x,y) = Flux.logitcrossentropy(model(x),y)
ps = Flux.params(model)
#[model[1].weight, model[1].bias]

learning_rate = 0.1
opt = Descent(learning_rate)

# train model 

loss_history = []

epochs = 500 

for epoch in 1:epochs
    Flux.train!(loss, ps, [(x_train, y_train)],opt)
    train_loss = loss(x_train,y_train)
    push!(loss_history,train_loss)
    println("Epoch = $epoch: Training Loss = $train_loss")
end

y_hat_raw = model(x_test)
y_hat = onecold(y_hat_raw).-1

y= y_test_raw

mean(y_hat .== y)

# check any misclassification 
check = [y_hat[i] == y[i] for i in 1:length(y)]
index = collect(1:length(y))

check_display = [index y_hat y check]

gr(size = (600,600))

p_l_curve = plot(1:epochs, loss_history,
xlabel = "Epochs",
ylabel = "Loss",
title = "Learning Curve",
legend = false,
color = :blue,
linewidth = 2
)